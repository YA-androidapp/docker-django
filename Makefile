include .env

install:
	export DOCKER_BUILDKIT=0
	docker-compose build --no-cache --force-rm db
	docker-compose up -d db
	docker-compose build --no-cache --force-rm app
	docker-compose up -d app

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
