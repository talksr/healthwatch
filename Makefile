.PHONY: install lint test run up down

install:
	pip install -r requirements-dev.txt

lint:
	ruff check .

test:
	pytest -v

run:
	gunicorn --bind 0.0.0.0:8000 --workers 1 --threads 4 "app.main:create_app()"

up:
	docker compose up --build -d

down:
	docker compose down
