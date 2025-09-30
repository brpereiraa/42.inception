# 42.inception

A Docker-based micro-infrastructure that provisions a self-hosted WordPress stack fronted by Nginx and backed by MariaDB. Everything is orchestrated with Docker Compose and reproducible through a simple Makefile.

### Stack
- **Nginx**: reverse proxy + TLS termination (ports 80/443)
- **WordPress (PHP-FPM)**: application container
- **MariaDB**: relational database
- **Bridge network**: `inception-network`
- **Bind-mounted data volume**: persists website files and database data


---

## Repository layout
- `srcs/docker-compose.yml`: Compose file defining services, network, and the persistent volume
- `srcs/requirements/`: Dockerfiles and configs for `nginx`, `wordpress`, and `mariadb`
- `secrets/tls/`: expected location for TLS key/cert used by Nginx
- `Makefile`: helper targets to build, run, and clean the environment

---

## Configuration
### 1) Environment file (`.env`)
Create a `.env` file in `srcs/` next to `docker-compose.yml`. The following variables are referenced:

- WordPress/site
  - `WP_URL` (domain used by WordPress and Nginx)
  - `WP_ADMIN_USER`
  - `WP_ADMIN_PASSWORD`
  - `WP_ADMIN_EMAIL`
  - `WP_USER`
  - `WP_USER_EMAIL`
  - `WP_USER_PASSWORD`

- Database
  - `DB_NAME`
  - `DB_USER`
  - `DB_PASSWORD`
  - `DB_HOST` (should match the DB service hostname, e.g. `mariadb`)

Example:
```env
WP_URL=example.local
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=change-me
WP_ADMIN_EMAIL=admin@example.local
WP_USER=author
WP_USER_EMAIL=author@example.local
WP_USER_PASSWORD=change-me

DB_NAME=wordpress
DB_USER=wpuser
DB_PASSWORD=change-me
DB_HOST=mariadb
```

Place the file at: `srcs/.env`

### 2) TLS certificates for Nginx
Nginx expects TLS materials mounted at `secrets/tls` in the project root, which are mapped into the container at `/etc/nginx/secrets`.

- Directory: `secrets/tls/`
- Recommended filenames: `server.crt` and `server.key`

Generate self-signed certs (example):
```bash
openssl req -x509 -newkey rsa:2048 -nodes -keyout secrets/tls/server.key -out secrets/tls/server.crt -days 365 -subj "/CN=example.local"
```
Update `example.local` to match your `WP_URL`.

### 3) Persistent data path
The bind-mounted volume is configured in `srcs/docker-compose.yml` to point to a host path:
```yaml
volumes:
  web_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/bruno/data
```

If you change it, keep the rest of the volume configuration the same.


## Makefile targets
The `Makefile` wraps common Docker Compose actions against `srcs/docker-compose.yml`.

- `make` (default `ALL`): build and start the stack in the foreground
- `make re`: prune old resources, recreate the stack from scratch
- `make fclean`: stop and remove all containers, images, volumes, and networks on your system (destructive)

Commands executed (for reference):
```make
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
```


---

## Usage
1. Create `srcs/.env` with the variables listed above.
2. Put TLS files in `secrets/tls/` (`server.crt`, `server.key`).
3. Ensure the data directory configured at `volumes.web_data.driver_opts.device` exists and is accessible by Docker.
4. Optionally add your domain (e.g. `example.local`) to the hosts file.
5. Start the stack:
   - `make`
6. Access:
   - HTTP: `http://<WP_URL>` (or `http://localhost` if using raw ports)
   - HTTPS: `https://<WP_URL>`

On first run, WordPress will auto-configure using the provided environment variables.

---

## Services overview
- `nginx`
  - Builds from `srcs/requirements/nginx/`
  - Listens on host ports `80` and `443`
  - Mounts `web_data` at `/var/www/html` and TLS secrets at `/etc/nginx/secrets`
  - Depends on `wordpress` and `mariadb`

- `wordpress`
  - Builds from `srcs/requirements/wordpress/`
  - Receives DB and site settings via environment variables
  - Mounts `web_data` at `/var/www/html`

- `mariadb`
  - Builds from `srcs/requirements/mariadb/`
  - Receives DB name/user/password via environment variables
  - Mounts `web_data` at `/var/lib/mysql`

---

