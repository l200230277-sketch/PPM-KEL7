from django.contrib import admin

from .models import Drama, DramaCast, Genre, Person


@admin.register(Genre)
class GenreAdmin(admin.ModelAdmin):
    list_display = ('name', 'tmdb_id')
    search_fields = ('name',)


@admin.register(Person)
class PersonAdmin(admin.ModelAdmin):
    list_display = ('name', 'tmdb_id')
    search_fields = ('name',)


class DramaCastInline(admin.TabularInline):
    model = DramaCast
    extra = 0


@admin.register(Drama)
class DramaAdmin(admin.ModelAdmin):
    list_display = ('title', 'year', 'rating', 'is_ongoing', 'first_air_date')
    list_filter = ('year', 'is_ongoing', 'genres')
    search_fields = ('title',)
    filter_horizontal = ('genres',)
    inlines = [DramaCastInline]
