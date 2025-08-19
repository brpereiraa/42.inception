ALL: 
	docker compose up --build

re:
	docker system prune -a
	docker compose up --build
