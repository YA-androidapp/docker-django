FROM python:3
LABEL maintainer="yaand"

ARG POSTGRES_DB
ARG POSTGRES_USER
ARG POSTGRES_PASSWORD

RUN export POSTGRES_DB=$POSTGRES_DB && \
    export POSTGRES_USER=$POSTGRES_USER && \
    export POSTGRES_PASSWORD=$POSTGRES_PASSWORD

ENV PYTHONUNBUFFERED 1
RUN mkdir /code
WORKDIR /code
ADD ./infra/docker/python/requirements.txt /code/
RUN pip install -r requirements.txt

RUN django-admin startproject myproj . && \
    sed -i "s/'django.db.backends.sqlite3'/'django.db.backends.postgresql'/g" ./myproj/settings.py && \
    sed -i "s#'NAME': BASE_DIR / 'db.sqlite3'#'NAME': '${POSTGRES_DB}', 'USER': '${POSTGRES_USER}', 'PASSWORD': '${POSTGRES_PASSWORD}', 'HOST': 'db', 'PORT': 5432#g" ./myproj/settings.py

RUN python manage.py startapp accounts && \
    sed -i "s/'django.contrib.staticfiles',/'django.contrib.staticfiles','accounts.apps.AccountsConfig',/g" ./myproj/settings.py && \
    echo "\nfrom django.contrib.auth.models import AbstractUser\n\nclass CustomUser(AbstractUser):\n    class Meta:\n        verbose_name_plural = 'CustomUser'\n    age = models.IntegerField('年齢', blank=True, default=0)\n" >> ./accounts/models.py && \
    echo "\nAUTHENTICATION_BACKENDS = ('django.contrib.auth.backends.ModelBackend','allauth.account.auth_backends.AuthenticationBackend',)" >> ./myproj/settings.py && \
    echo "\nSITE_ID = 1\nLOGIN_REDIRECT_URL = '/'\nACCOUNT_LOGOUT_REDIRECT_URL = '/accounts/login/'\n" >> ./myproj/settings.py && \
    echo "\nAUTH_USER_MODEL = 'accounts.CustomUser'" >> ./myproj/settings.py && \
    echo "\nACCOUNT_FORMS = {'signup' : 'accounts.forms.CustomSignupForm',}\nACCOUNT_ADAPTER = 'accounts.adapter.AccountAdapter'"  >> ./myproj/settings.py && \
    echo "from .models import CustomUser\n\nadmin.site.register(CustomUser)" >> ./accounts/admin.py
ADD ./infra/docker/python/accounts/adapter.py /code/accounts/
ADD ./infra/docker/python/accounts/forms.py /code/accounts/
RUN python manage.py makemigrations && \
    python manage.py migrate

RUN DJANGO_SUPERUSER_PASSWORD="Passw0rd#" DJANGO_SUPERUSER_USERNAME="Admin" DJANGO_SUPERUSER_EMAIL="admin@example.net" python manage.py createsuperuser --noinput

# django-allauth
RUN echo "\nACCOUNT_AUTHENTICATION_METHOD = 'email'\nACCOUNT_USERNAME_REQUIRED = False\nACCOUNT_EMAIL_VARIFICATION = 'none'" >> ./myproj/settings.py && \
    # EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
    echo "\nACCOUNT_EMAIL_REQUIRED = True\nEMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'" >> ./myproj/settings.py && \
    sed -i "s/'django.contrib.staticfiles',/'django.contrib.staticfiles','django.contrib.sites','allauth','allauth.account','allauth.socialaccount',/g" ./myproj/settings.py && \
    sed -i "s/'django.template.context_processors.debug',/'django.template.context_processors.debug',\n                'django.template.context_processors.request',/g" ./myproj/settings.py && \
    sed -i "s/from django.urls import path/from django.urls import path, include/g" ./myproj/urls.py && \
    sed -i "s#path('admin/', admin.site.urls),#path('admin/', admin.site.urls),\n    path('accounts/', include('allauth.urls')),#g" ./myproj/urls.py
RUN python manage.py migrate

RUN sed -i "s#STATIC_URL = '/static/'#STATIC_URL = '/static/'\nSTATIC_ROOT = '/static'#g" ./myproj/settings.py && \
    python manage.py collectstatic
