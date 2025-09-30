FROM debian:bookworm

RUN apt update && apt install -y mariadb-server 

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY ./tools/init.sql /etc/mysql/init.sql
COPY ./tools/script.sh .

RUN mkdir /run/mysqld && chmod +x script.sh

EXPOSE 3306

CMD ["./script.sh"]
