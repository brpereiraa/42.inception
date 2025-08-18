FROM debian:bullseye

RUN apt update && apt upgrade -y && apt install -y php7.4-fpm php-mysqli curl netcat

COPY www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY script.sh .

RUN mkdir /run/php
RUN chmod +x script.sh

EXPOSE 9000

CMD ["./script.sh"]
