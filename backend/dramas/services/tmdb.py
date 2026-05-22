"""TMDB API client and drama sync helpers."""

from __future__ import annotations

import time
from datetime import datetime
from typing import Any

import requests
from django.conf import settings

TMDB_BASE = 'https://api.themoviedb.org/3'
ONGOING_STATUS = 'Returning Series'
YEAR_MIN = 2020
YEAR_MAX = 2026


class TMDBClient:
    def __init__(self, api_key: str | None = None):
        self.api_key = api_key or settings.TMDB_API_KEY
        if not self.api_key:
            raise ValueError('TMDB_API_KEY is not configured')

    def _get(self, path: str, params: dict | None = None) -> dict[str, Any]:
        query = {'api_key': self.api_key, 'language': 'en-US'}
        if params:
            query.update(params)
        response = requests.get(f'{TMDB_BASE}{path}', params=query, timeout=30)
        response.raise_for_status()
        return response.json()

    def discover_korean_dramas(self, page: int = 1, year: int | None = None) -> dict[str, Any]:
        params = {
            'with_origin_country': 'KR',
            'first_air_date.gte': f'{YEAR_MIN}-01-01',
            'first_air_date.lte': f'{YEAR_MAX}-12-31',
            'sort_by': 'popularity.desc',
            'page': page,
        }
        if year is not None:
            params['first_air_date_year'] = year
        return self._get('/discover/tv', params)

    def tv_details(self, tmdb_id: int) -> dict[str, Any]:
        return self._get(
            f'/tv/{tmdb_id}',
            {'append_to_response': 'credits,keywords'},
        )

    def tv_genre_list(self) -> list[dict[str, Any]]:
        return self._get('/genre/tv/list').get('genres', [])


def poster_url(path: str | None) -> str:
    if not path:
        return ''
    return f'{settings.TMDB_IMAGE_BASE}{path}'


def parse_year(first_air_date: str | None) -> int:
    if not first_air_date:
        return YEAR_MIN
    try:
        return datetime.strptime(first_air_date, '%Y-%m-%d').year
    except ValueError:
        return YEAR_MIN


def extract_main_cast(credits: dict[str, Any], limit: int | None = None) -> list[dict[str, Any]]:
    limit = limit or settings.MAIN_CAST_LIMIT
    cast = credits.get('cast', [])
    sorted_cast = sorted(cast, key=lambda c: c.get('order', 999))
    return sorted_cast[:limit]


def extract_tags(keywords: dict[str, Any], max_tags: int = 5) -> list[str]:
    items = keywords.get('results', keywords.get('keywords', []))
    names = [k.get('name', '') for k in items if k.get('name')]
    return names[:max_tags]


def rate_limit_pause(seconds: float = 0.08) -> None:
    time.sleep(seconds)
