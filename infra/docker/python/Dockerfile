FROM python:3
LABEL maintainer="yaand"

ARG DATABASE_URL
ARG POSTGRES_DB
ARG POSTGRES_USER
ARG POSTGRES_PASSWORD

RUN export DATABASE_URL=$DATABASE_URL && \
    export POSTGRES_DB=$POSTGRES_DB && \
    export POSTGRES_USER=$POSTGRES_USER && \
    export POSTGRES_PASSWORD=$POSTGRES_PASSWORD

ENV PYTHONUNBUFFERED 1
RUN mkdir /code
WORKDIR /code
ADD ./infra/docker/python/requirements.txt /code/
RUN pip install -r requirements.txt && \
    pip freeze > requirements.out
RUN cat requirements.out

# myproj project
RUN django-admin startproject myproj . && \
    sed -i "s/from pathlib import Path/from pathlib import Path\nimport os/g" ./myproj/settings.py && \
    sed -i "s/# Quick-start/# read the .env file\n# Quick-start/g" ./myproj/settings.py && \
    sed -i "s/# Quick-start/import environ\n# Quick-start/g" ./myproj/settings.py && \
    sed -i "s/# Quick-start/env = environ.Env()\n# Quick-start/g" ./myproj/settings.py && \
    sed -i "s/# Quick-start/if os.path.exists(os.path.join(BASE_DIR, '.env')):\n# Quick-start/g" ./myproj/settings.py && \
    sed -i "s/# Quick-start/    env.read_env(os.path.join(BASE_DIR, '.env'))\n# Quick-start/g" ./myproj/settings.py && \
    sed -i "s/DEBUG = True/DEBUG = env('DEBUG', default=True)/g" ./myproj/settings.py && \
    sed -i "s/# SECURITY WARNING: don't run with debug/SECRET_KEY = env('SECRET_KEY', default=SECRET_KEY)\n\n\n# SECURITY WARNING: don't run with debug/g" ./myproj/settings.py && \
    sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = env.list('ALLOWED_HOSTS', default=(\['\*'\] if DEBUG else \['localhost', '127.0.0.1']))/g" ./myproj/settings.py && \
    sed -i "s/    'django.contrib.staticfiles',/    'django.contrib.staticfiles',\n    'import_export',/g" ./myproj/settings.py && \
    sed -i "s/LANGUAGE_CODE = 'en-us'/LANGUAGE_CODE = 'ja-jp'/g" ./myproj/settings.py && \
    sed -i "s#TIME_ZONE = 'UTC'#TIME_ZONE = 'Asia/Tokyo'#g" ./myproj/settings.py && \
    sed -i "s#STATIC_URL = '/static/'#STATIC_URL = '/static/'\nSTATIC_ROOT = os.path.join(BASE_DIR, 'static')#g" ./myproj/settings.py

# RUN sed -i "s|# Password validation|DATABASES = {'default': env.db('DATABASE_URL', default='sqlite:///db.sqlite3')}\n\n\# Password validation|g" ./myproj/settings.py
RUN sed -i "s|# Password validation|DATABASES = {'default': env.db('DATABASE_URL', default='${DATABASE_URL}')}\n\n\# Password validation|g" ./myproj/settings.py
# RUN sed -i "s#'NAME': BASE_DIR / 'db.sqlite3'#'NAME': '${POSTGRES_DB}', 'USER': '${POSTGRES_USER}', 'PASSWORD': '${POSTGRES_PASSWORD}', 'HOST': 'db', 'PORT': 5432#g" ./myproj/settings.py

RUN cat ./myproj/settings.py
RUN echo "DATABASE_URL: $DATABASE_URL"

# accounts app
RUN python manage.py startapp accounts && \
    sed -i "s/'django.contrib.staticfiles',/'django.contrib.staticfiles','accounts.apps.AccountsConfig',/g" ./myproj/settings.py && \
    echo "\nAUTH_USER_MODEL = 'accounts.CustomUser'" >> ./myproj/settings.py && \
    echo "from .models import CustomUser\n\nadmin.site.register(CustomUser)" >> ./accounts/admin.py
ADD ./infra/docker/python/accounts/*.py /code/accounts/
RUN python manage.py makemigrations && \
    python manage.py migrate

# createsuperuser
RUN DJANGO_SUPERUSER_PASSWORD="Passw0rd#" \
    DJANGO_SUPERUSER_USERNAME="Admin" \
    DJANGO_SUPERUSER_EMAIL="admin@example.net" \
    python manage.py createsuperuser --noinput \
    ; exit 0

# django-allauth
# EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
RUN echo "\nACCOUNT_ADAPTER = 'accounts.adapter.AccountAdapter'" >> ./myproj/settings.py && \
    echo "\nACCOUNT_AUTHENTICATION_METHOD = 'email'" >> ./myproj/settings.py && \
    echo "\nACCOUNT_EMAIL_REQUIRED = True" >> ./myproj/settings.py && \
    echo "\nACCOUNT_EMAIL_VARIFICATION = 'none'" >> ./myproj/settings.py && \
    echo "\nACCOUNT_FORMS = {'signup' : 'accounts.forms.CustomSignupForm',}" >> ./myproj/settings.py && \
    echo "\nACCOUNT_LOGOUT_REDIRECT_URL = '/accounts/login/'" >> ./myproj/settings.py && \
    echo "\nACCOUNT_SESSION_REMEMBER = True" >> ./myproj/settings.py && \
    echo "\nACCOUNT_USERNAME_REQUIRED = False" >> ./myproj/settings.py && \
    echo "\nAUTHENTICATION_BACKENDS = ('django.contrib.auth.backends.ModelBackend','allauth.account.auth_backends.AuthenticationBackend',)" >> ./myproj/settings.py && \
    echo "\nEMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'" >> ./myproj/settings.py && \
    echo "\nSITE_ID = 1" >> ./myproj/settings.py && \
    sed -i "s/TEMPLATES = \[/import os\nTEMPLATES = \[/g" ./myproj/settings.py && \
    sed -i "s/'DIRS': \[\],/'DIRS': \[os.path.join(BASE_DIR, 'templates'),\],/g" ./myproj/settings.py && \
    sed -i "s/'django.contrib.staticfiles',/'django.contrib.staticfiles','django.contrib.sites','allauth','allauth.account','allauth.socialaccount',/g" ./myproj/settings.py && \
    sed -i "s/'django.template.context_processors.debug',/'django.template.context_processors.debug',\n                'django.template.context_processors.request',/g" ./myproj/settings.py && \
    sed -i "s/from django.urls import path/from django.urls import path, include/g" ./myproj/urls.py && \
    sed -i "s#path('admin/', admin.site.urls),#path('admin/', admin.site.urls),\n    path('accounts/', include('allauth.urls')),#g" ./myproj/urls.py
ADD ./infra/docker/python/templates/account/*.html /code/templates/account/
RUN python manage.py migrate

# myapp app
RUN python manage.py startapp myapp && \
    sed -i "s/'django.contrib.staticfiles',/'django.contrib.staticfiles','myapp.apps.MyappConfig',/g" ./myproj/settings.py && \
    echo "\nLOGIN_REDIRECT_URL = 'myapp:profile'" >> ./myproj/settings.py && \
    sed -i "s#path('admin/', admin.site.urls),#path('admin/', admin.site.urls),\n    path('', include('myapp.urls')),#g" ./myproj/urls.py && \
    echo "from myapp.models import Category, Tag, Post\n\nadmin.site.register(Category)\nadmin.site.register(Tag)\nadmin.site.register(Post)" >> ./accounts/admin.py
ADD ./infra/docker/python/myapp/models.py ./infra/docker/python/myapp/urls.py ./infra/docker/python/myapp/views.py /code/myapp/
ADD ./infra/docker/python/myapp/templates/*.html /code/myapp/templates/
ADD ./infra/docker/python/myapp/templates/myapp/*.html /code/myapp/templates/myapp/
ADD ./infra/docker/python/myapp/fixtures/seeds.json /code/myapp/fixtures/
RUN python manage.py makemigrations && \
    python manage.py migrate && \
    python manage.py loaddata myapp/fixtures/seeds.json

# static files
RUN sed -i "s#STATIC_URL = '/static/'#STATIC_URL = '/static/'\nSTATIC_ROOT = '/static'#g" ./myproj/settings.py && \
    python manage.py collectstatic
