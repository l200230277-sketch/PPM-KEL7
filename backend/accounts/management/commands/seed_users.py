from django.contrib.auth.models import User
from django.core.management.base import BaseCommand

from accounts.models import UserProfile


class Command(BaseCommand):
    help = 'Create default admin and minjung users'

    def handle(self, *args, **options):
        defaults = [
            ('admin', 'admin123', 'admin1@gmail.com', True, 'Admin', ''),
            ('minjung', 'minjung123', 'minjung234@gmail.com', False, 'Minjung', 'Go'),
        ]
        for username, password, email, is_staff, first, last in defaults:
            user, created = User.objects.get_or_create(
                username=username,
                defaults={'email': email, 'is_staff': is_staff, 'is_superuser': is_staff},
            )
            if created:
                user.set_password(password)
                user.save()
            else:
                user.email = email
                user.is_staff = is_staff
                user.is_superuser = is_staff
                user.set_password(password)
                user.save()
            UserProfile.objects.update_or_create(
                user=user,
                defaults={'first_name': first, 'last_name': last},
            )
            self.stdout.write(self.style.SUCCESS(f'User {username} ready'))
