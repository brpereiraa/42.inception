FROM debian:bookworm

RUN apt update && apt upgrade -y && apt-get install -y php8.2-fpm php-mysql curl netcat-openbsd

COPY www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY script.sh .

RUN chmod +x script.sh

EXPOSE 9000

CMD ["./script.sh"]
