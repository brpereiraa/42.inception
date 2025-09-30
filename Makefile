ALL: 
	docker compose -f ./srcs/docker-compose.yml up --build

re: fclean
	docker system prune -a -f
	docker compose -f ./srcs/docker-compose.yml down -v
	docker compose -f ./srcs/docker-compose.yml up --build

fclean:
	docker stop $$(docker ps -qa) || true
	docker rm $$(docker ps -qa) || true
	docker rmi -f $$(docker images -qa) || true
	docker volume rm $$(docker volume ls -q) || true
	docker network rm $$(docker network ls -q) || true


