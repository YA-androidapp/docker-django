include .env

install:
	docker-compose run web django-admin startproject myproj .

	docker-compose run web sed -i "s/'django.db.backends.sqlite3'/'django.db.backends.postgresql'/g" ./myproj/settings.py
	echo "loaded: ${DB_NAME} ${DB_USER} ${DB_PASS}"
	docker-compose run web sed -i "s#'NAME': BASE_DIR / 'db.sqlite3'#'NAME': '$${DB_NAME:-postgres}', 'USER': '$${DB_USER:-postgres}', 'PASSWORD': '$${DB_PASS:-secret}', 'HOST': 'db', 'PORT': 5432#g" ./myproj/settings.py
	docker-compose run web cat myproj/settings.py

	docker-compose up -d

up:
	docker-compose up -d
build:
	docker-compose build --no-cache --force-rm
stop:
	docker-compose stop
down:
	docker-compose down --remove-orphans
restart:
	@make down
	@make up
destroy:
	docker-compose down --rmi all --volumes --remove-orphans
destroy-volumes:
	docker-compose down --volumes --remove-orphans
ps:
	docker-compose ps
logs:
	docker-compose logs
app:
	docker-compose exec app bash
db:
	docker-compose exec db bash
sql:
	docker-compose exec db bash -c 'PGPASSWORD=$$POSTGRES_PASSWORD mysql -U $$POSTGRES_USER -d $$POSTGRES_DB'
