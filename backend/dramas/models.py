from django.conf import settings
from django.db import models


class Genre(models.Model):
    tmdb_id = models.IntegerField(unique=True)
    name = models.CharField(max_length=100)

    class Meta:
        ordering = ['name']

    def __str__(self):
        return self.name


class Person(models.Model):
    tmdb_id = models.IntegerField(unique=True)
    name = models.CharField(max_length=255)
    profile_path = models.CharField(max_length=255, blank=True)

    class Meta:
        ordering = ['name']

    def __str__(self):
        return self.name


class Drama(models.Model):
    tmdb_id = models.IntegerField(unique=True)
    title = models.CharField(max_length=255)
    year = models.PositiveIntegerField()
    rating = models.FloatField(default=0)
    synopsis = models.TextField(blank=True)
    poster_path = models.CharField(max_length=255, blank=True)
    first_air_date = models.DateField(null=True, blank=True)
    status = models.CharField(max_length=50, blank=True)
    is_ongoing = models.BooleanField(default=False)
    genres = models.ManyToManyField(Genre, related_name='dramas', blank=True)
    tags = models.JSONField(default=list, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-first_air_date', 'title']
        verbose_name_plural = 'dramas'

    def __str__(self):
        return self.title


class DramaCast(models.Model):
    drama = models.ForeignKey(
        Drama,
        on_delete=models.CASCADE,
        related_name='cast_entries',
    )
    person = models.ForeignKey(
        Person,
        on_delete=models.CASCADE,
        related_name='roles',
    )
    character_name = models.CharField(max_length=255, blank=True)
    cast_order = models.IntegerField(default=999)

    class Meta:
        ordering = ['cast_order', 'id']
        unique_together = [['drama', 'person']]
        verbose_name_plural = 'drama cast'

    def __str__(self):
        return f'{self.person.name} in {self.drama.title}'


class UserDrama(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='drama_states',
    )
    drama = models.ForeignKey(
        Drama,
        on_delete=models.CASCADE,
        related_name='user_states',
    )
    is_favorite = models.BooleanField(default=False)
    is_in_my_list = models.BooleanField(default=False)

    class Meta:
        unique_together = [['user', 'drama']]

    def __str__(self):
        return f'{self.user.username} -> {self.drama.title}'
