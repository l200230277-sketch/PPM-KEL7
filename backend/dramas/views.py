from django.conf import settings
from django.db.models import Prefetch, Q
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Drama, DramaCast, Genre, UserDrama
from .serializers import DramaDetailSerializer, DramaListSerializer


def _year_filtered_qs():
    return Drama.objects.filter(
        year__gte=settings.DRAMA_YEAR_MIN,
        year__lte=settings.DRAMA_YEAR_MAX,
    )


def _apply_search(qs, search: str):
    if not search:
        return qs
    return qs.filter(
        Q(title__icontains=search)
        | Q(cast_entries__person__name__icontains=search)
    ).distinct()


def _apply_category(qs, category: str):
    if not category or category.lower() == 'all':
        return qs
    return qs.filter(genres__name__iexact=category).distinct()


class DramaViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = DramaListSerializer

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        user = self.request.user
        if user.is_authenticated:
            states = UserDrama.objects.filter(user=user)
            context['user_states'] = {s.drama_id: s for s in states}
        return context

    def get_queryset(self):
        qs = (
            _year_filtered_qs()
            .prefetch_related('genres')
            .prefetch_related(
                Prefetch(
                    'cast_entries',
                    queryset=DramaCast.objects.select_related('person').order_by(
                        'cast_order'
                    ),
                )
            )
        )
        qs = _apply_category(qs, self.request.query_params.get('category', ''))
        qs = _apply_search(qs, self.request.query_params.get('search', '').strip())
        return qs.order_by('-year', '-first_air_date', 'title')

    def get_serializer_class(self):
        if self.action == 'retrieve':
            return DramaDetailSerializer
        return DramaListSerializer

    @action(detail=False, methods=['get'], url_path='popular')
    def popular(self, request):
        limit = settings.POPULAR_LIMIT
        qs = _year_filtered_qs().order_by('-rating', '-year')[:limit]
        serializer = self.get_serializer(qs, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'], url_path='recently-added')
    def recently_added(self, request):
        limit = settings.RECENTLY_ADDED_LIMIT
        year = settings.RECENTLY_ADDED_YEAR
        qs = (
            _year_filtered_qs()
            .filter(year=year)
            .order_by('-first_air_date')[:limit]
        )
        serializer = self.get_serializer(qs, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['get'], url_path='you-may-also-like')
    def you_may_also_like(self, request, pk=None):
        drama = self.get_object()
        cast_person_ids = drama.cast_entries.values_list('person_id', flat=True)
        if not cast_person_ids:
            return Response([])

        related_ids = (
            DramaCast.objects.filter(person_id__in=cast_person_ids)
            .exclude(drama_id=drama.pk)
            .values_list('drama_id', flat=True)
            .distinct()
        )
        qs = (
            _year_filtered_qs()
            .filter(pk__in=related_ids)
            .prefetch_related('genres')
            .order_by('-rating', '-year')
        )
        serializer = self.get_serializer(qs, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def favorite(self, request, pk=None):
        drama = self.get_object()
        state, _ = UserDrama.objects.get_or_create(user=request.user, drama=drama)
        state.is_favorite = not state.is_favorite
        state.save(update_fields=['is_favorite'])
        return Response({'is_favorite': state.is_favorite})

    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def mylist(self, request, pk=None):
        drama = self.get_object()
        state, _ = UserDrama.objects.get_or_create(user=request.user, drama=drama)
        state.is_in_my_list = not state.is_in_my_list
        state.save(update_fields=['is_in_my_list'])
        return Response({'is_in_my_list': state.is_in_my_list})

    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def favorites(self, request):
        ids = UserDrama.objects.filter(
            user=request.user, is_favorite=True
        ).values_list('drama_id', flat=True)
        qs = _year_filtered_qs().filter(pk__in=ids).order_by('-year')
        serializer = self.get_serializer(qs, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated], url_path='my-list')
    def my_list(self, request):
        ids = UserDrama.objects.filter(
            user=request.user, is_in_my_list=True
        ).values_list('drama_id', flat=True)
        qs = _year_filtered_qs().filter(pk__in=ids).order_by('-year')
        serializer = self.get_serializer(qs, many=True)
        return Response(serializer.data)


class CategoryListView(APIView):
    def get(self, request):
        genres = Genre.objects.all().order_by('name')
        data = [{'id': 'all', 'name': 'All'}] + [
            {'id': str(g.pk), 'name': g.name} for g in genres
        ]
        return Response(data)
