FROM centos:8

MAINTAINER A.Kamis hi@ahmetkamis.com

ENV container docker

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]

# Install php, nginx, vim, supervisor
RUN yum -y update && \
	yum -y install epel-release && \
	yum -y install policycoreutils-python-utils && \
	dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
	dnf -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm && \
	dnf -y module list php && \
	dnf -y module enable php:remi-8.1 && \
	dnf -y install php php-cli php-common php-fpm && \
	dnf -y install php-mysqlnd php-gd php-zip php-gmp php-mcrypt php-redis php-bcmath && \
	dnf -y install \
	nginx \
	vim \
	supervisor

# Files & Permission
COPY . /usr/share/nginx/laravel
RUN chown -R nginx:nginx /usr/share/nginx/laravel

RUN mkdir /run/php-fpm/

# Fix permission denied error for php sessions/caches
RUN chown -R nginx:nginx /var/lib/php

# Confs
RUN rm -f /etc/nginx/nginx.conf
COPY ./docker/conf/nginx/nginx.conf /etc/nginx/nginx.conf

RUN rm -f /etc/php-fpm.d/www.conf
COPY ./docker/conf/php-fpm/www.conf /etc/php-fpm.d/www.conf

COPY ./docker/conf/nginx/default.conf /etc/nginx/default.d/default.conf
COPY ./docker/conf/nginx/laravel.conf /etc/nginx/conf.d/laravel.conf

RUN rm -f /etc/supervisor/supervisord.conf
COPY ./docker/conf/supervisord.conf /etc/supervisor/supervisord.conf

# Entry point
ADD ./docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT /entrypoint.sh
