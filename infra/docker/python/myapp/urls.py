from django.urls import path
from .views import *

app_name = 'myapp'

urlpatterns = [
    path('profile/', ProfileView.as_view(), name='profile'),
    path('', WelcomeView.as_view(), name='welcome'),

    path('posts/', IndexView.as_view(), name='index'),
    path('post/<int:pk>/', PostDetailView.as_view(), name='post_detail'),
    path('categories/', CategoryListView.as_view(), name='category_list'),
    path('tags/', TagListView.as_view(), name='tag_list'),
    path('category/<str:category_slug>/',
         CategoryPostView.as_view(), name='category_post'),
    path('tag/<str:tag_slug>/', TagPostView.as_view(), name='tag_post'),
]
