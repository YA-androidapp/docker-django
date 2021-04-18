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

RUN django-admin startproject myproj .
RUN sed -i "s/'django.db.backends.sqlite3'/'django.db.backends.postgresql'/g" ./myproj/settings.py
RUN echo "${POSTGRES_DB} ${POSTGRES_USER} ${POSTGRES_PASSWORD}"
RUN sed -i "s#'NAME': BASE_DIR / 'db.sqlite3'#'NAME': '${POSTGRES_DB}', 'USER': '${POSTGRES_USER}', 'PASSWORD': '${POSTGRES_PASSWORD}', 'HOST': 'db', 'PORT': 5432#g" ./myproj/settings.py
RUN cat ./myproj/settings.py
