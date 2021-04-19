FROM python:3
LABEL maintainer="yaand"

ARG POSTGRES_DB
ARG POSTGRES_USER
ARG POSTGRES_PASSWORD

RUN export POSTGRES_DB=$POSTGRES_DB
RUN export POSTGRES_USER=$POSTGRES_USER
RUN export POSTGRES_PASSWORD=$POSTGRES_PASSWORD

ENV PYTHONUNBUFFERED 1
RUN mkdir /code
WORKDIR /code
ADD ./infra/docker/python/requirements.txt /code/
RUN pip install -r requirements.txt
ADD . /code/

RUN django-admin startproject myproj . && \
    sed -i "s/'django.db.backends.sqlite3'/'django.db.backends.postgresql'/g" ./myproj/settings.py && \
    echo "${POSTGRES_DB} ${POSTGRES_USER} ${POSTGRES_PASSWORD}" && \
    sed -i "s#'NAME': BASE_DIR / 'db.sqlite3'#'NAME': '${POSTGRES_DB}', 'USER': '${POSTGRES_USER}', 'PASSWORD': '${POSTGRES_PASSWORD}', 'HOST': 'db', 'PORT': 5432#g" ./myproj/settings.py

# django-allauth
RUN echo "AUTHENTICATION_BACKENDS = ('django.contrib.auth.backends.ModelBackend','allauth.account.auth_backends.AuthenticationBackend',)\n\nSITE_ID = 1" >> ./myproj/settings.py && \
    sed -i "s/'django.contrib.staticfiles',/'django.contrib.staticfiles','django.contrib.sites','allauth','allauth.account','allauth.socialaccount',/g" ./myproj/settings.py && \
    sed -i "s/from django.urls import path/from django.urls import path, include/g" ./myproj/urls.py && \
    sed -i "s#path('admin/', admin.site.urls),#path('admin/', admin.site.urls),\n    path('accounts/', include('allauth.urls')),#g" ./myproj/urls.py

RUN cat ./myproj/settings.py
RUN cat ./myproj/urls.py

RUN python manage.py migrate

RUN sed -i "s#STATIC_URL = '/static/'#STATIC_URL = '/static/'\nSTATIC_ROOT = '/static'#g" ./myproj/settings.py && \
    python manage.py collectstatic