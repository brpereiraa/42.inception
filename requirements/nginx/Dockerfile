FROM debian:bullseye

RUN apt update \ 
    && apt install -y nginx \
    && apt install -y openssl

COPY default /etc/nginx/sites-available/. 

CMD ["nginx", "-g", "daemon off;"]

