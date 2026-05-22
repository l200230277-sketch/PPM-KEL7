from django.conf import settings
from rest_framework import serializers

from .models import Drama, DramaCast, Genre, Person, UserDrama
from .services.tmdb import poster_url


class CastMemberSerializer(serializers.Serializer):
    name = serializers.CharField()
    photo_url = serializers.CharField(allow_blank=True)


class DramaListSerializer(serializers.ModelSerializer):
    id = serializers.CharField(source='pk', read_only=True)
    genres = serializers.SlugRelatedField(many=True, read_only=True, slug_field='name')
    tags = serializers.ListField(child=serializers.CharField(), read_only=True)
    poster_url = serializers.SerializerMethodField()
    primary_genre = serializers.SerializerMethodField()
    is_favorite = serializers.SerializerMethodField()
    is_in_my_list = serializers.SerializerMethodField()

    class Meta:
        model = Drama
        fields = [
            'id',
            'title',
            'year',
            'rating',
            'genres',
            'tags',
            'synopsis',
            'poster_url',
            'primary_genre',
            'is_favorite',
            'is_in_my_list',
        ]

    def get_poster_url(self, obj: Drama) -> str:
        return poster_url(obj.poster_path)

    def get_primary_genre(self, obj: Drama) -> str:
        first = obj.genres.first()
        return first.name if first else ''

    def _user_state(self, obj: Drama) -> UserDrama | None:
        cache = self.context.get('user_states')
        if cache is not None:
            return cache.get(obj.pk)
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return UserDrama.objects.filter(user=request.user, drama=obj).first()
        return None

    def get_is_favorite(self, obj: Drama) -> bool:
        state = self._user_state(obj)
        if state is not None:
            return state.is_favorite
        return str(obj.pk) in self.context.get('favorite_ids', set())

    def get_is_in_my_list(self, obj: Drama) -> bool:
        state = self._user_state(obj)
        if state is not None:
            return state.is_in_my_list
        return str(obj.pk) in self.context.get('my_list_ids', set())


class DramaDetailSerializer(DramaListSerializer):
    main_cast = serializers.SerializerMethodField()

    class Meta(DramaListSerializer.Meta):
        fields = DramaListSerializer.Meta.fields + [
            'main_cast',
            'status',
            'is_ongoing',
        ]

    def get_main_cast(self, obj: Drama) -> list[dict]:
        entries = obj.cast_entries.select_related('person').order_by('cast_order')[
            : settings.MAIN_CAST_LIMIT
        ]
        return [
            {
                'name': entry.person.name,
                'photo_url': poster_url(entry.person.profile_path),
            }
            for entry in entries
        ]


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Genre
        fields = ['id', 'name']
