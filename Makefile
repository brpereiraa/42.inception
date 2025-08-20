ALL: 
	docker compose up --build

re:
	docker system prune -a -f
	docker compose down -v
	docker compose up --build
