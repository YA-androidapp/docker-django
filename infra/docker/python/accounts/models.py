from django.db import models
from django.contrib.auth.models import AbstractUser


class CustomUser(AbstractUser):
    class Meta:
        verbose_name_plural = 'CustomUser'

    age = models.IntegerField('Age', blank=True, default=0)
