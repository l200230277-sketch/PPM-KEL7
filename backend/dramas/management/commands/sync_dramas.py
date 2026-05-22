"""Fetch Korean dramas (2020-2026, all statuses) from TMDB into the database."""

from django.conf import settings
from django.core.management.base import BaseCommand
from django.db import transaction

from dramas.models import Drama, DramaCast, Genre, Person
from dramas.services.tmdb import (
    ONGOING_STATUS,
    TMDBClient,
    YEAR_MAX,
    YEAR_MIN,
    extract_main_cast,
    extract_tags,
    parse_year,
    rate_limit_pause,
)


class Command(BaseCommand):
    help = 'Sync Korean TV dramas 2020-2026 (all statuses) from TMDB'

    def add_arguments(self, parser):
        parser.add_argument(
            '--max-pages',
            type=int,
            default=30,
            help='Max pages per year (20 results per page)',
        )

    def handle(self, *args, **options):
        client = TMDBClient()
        self.stdout.write('Syncing TV genres from TMDB...')
        self._sync_genres(client)

        max_pages = options['max_pages']
        seen_ids: set[int] = set()
        synced = 0

        for year in range(YEAR_MIN, YEAR_MAX + 1):
            self.stdout.write(f'Year {year}...')
            for page in range(1, max_pages + 1):
                data = client.discover_korean_dramas(page=page, year=year)
                results = data.get('results', [])
                if not results:
                    break

                for item in results:
                    tmdb_id = item['id']
                    if tmdb_id in seen_ids:
                        continue
                    seen_ids.add(tmdb_id)
                    try:
                        if self._sync_drama(client, tmdb_id):
                            synced += 1
                    except Exception as exc:
                        self.stderr.write(
                            self.style.WARNING(
                                f'Skip {tmdb_id} ({item.get("name")}): {exc}'
                            )
                        )
                    rate_limit_pause()

                if page >= data.get('total_pages', page):
                    break

        self.stdout.write(
            self.style.SUCCESS(
                f'Synced {synced} dramas ({len(seen_ids)} unique IDs discovered)'
            )
        )

    def _sync_genres(self, client: TMDBClient) -> None:
        for g in client.tv_genre_list():
            Genre.objects.update_or_create(
                tmdb_id=g['id'],
                defaults={'name': g['name']},
            )

    @transaction.atomic
    def _sync_drama(self, client: TMDBClient, tmdb_id: int) -> Drama | None:
        detail = client.tv_details(tmdb_id)
        year = parse_year(detail.get('first_air_date'))
        if year < YEAR_MIN or year > YEAR_MAX:
            Drama.objects.filter(tmdb_id=tmdb_id).delete()
            return None

        status = detail.get('status', '')
        is_ongoing = status == ONGOING_STATUS

        drama, _ = Drama.objects.update_or_create(
            tmdb_id=tmdb_id,
            defaults={
                'title': detail.get('name', detail.get('original_name', '')),
                'year': year,
                'rating': round(float(detail.get('vote_average') or 0), 1),
                'synopsis': detail.get('overview', '') or '',
                'poster_path': detail.get('poster_path') or '',
                'first_air_date': detail.get('first_air_date') or None,
                'status': status,
                'is_ongoing': is_ongoing,
                'tags': extract_tags(detail.get('keywords', {})),
            },
        )

        genre_ids = []
        for g in detail.get('genres', []):
            genre, _ = Genre.objects.get_or_create(
                tmdb_id=g['id'],
                defaults={'name': g['name']},
            )
            genre_ids.append(genre.pk)
        drama.genres.set(genre_ids)

        DramaCast.objects.filter(drama=drama).delete()
        credits = detail.get('credits', {})
        for cast in extract_main_cast(credits):
            person, _ = Person.objects.update_or_create(
                tmdb_id=cast['id'],
                defaults={
                    'name': cast.get('name', ''),
                    'profile_path': cast.get('profile_path') or '',
                },
            )
            DramaCast.objects.create(
                drama=drama,
                person=person,
                character_name=cast.get('character', ''),
                cast_order=cast.get('order', 999),
            )

        return drama
