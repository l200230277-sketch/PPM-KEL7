from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import CategoryListView, DramaViewSet

router = DefaultRouter()
router.register('dramas', DramaViewSet, basename='drama')

urlpatterns = [
    path('categories/', CategoryListView.as_view(), name='categories'),
    path('', include(router.urls)),
]
