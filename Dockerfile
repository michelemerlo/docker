FROM centos:7
MAINTAINER Michèle Merlo <michele.merlo@bl.ch>
USER root
ENV http_proxy="http://faiwebproxysvc:ci11pu06@faiintproxy.bl.ch:8088/"
ENV HTTP_PROXY="http://faiwebproxysvc:ci11pu06@faiintproxy.bl.ch:8088/"
ENV https_proxy="http://faiwebproxysvc:ci11pu06@faiintproxy.bl.ch:8088/"
RUN yum clean all \
        && yum -y update \
        && yum remove php-common-5.4.16-42.el7.x86_64 \
        && rpm -Va --nofiles --nodigest \
        && rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
        && rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
RUN yum -y install php56w php56w-opcache
RUN yum -y  --skip-broken install wget httpd php56w-fpm php56w-mbstring.x86_64 php56w-tidy php56w-gd php56w-mysql php56w-xml
EXPOSE 80 3306
RUN echo 'ServerName 10.12.48.153' >> /etc/httpd/conf/httpd.conf \
        && touch /var/www/html/index.html \
        && echo '<!DOCTYPE html> <html lang="de"> <head> <meta charset="UTF-8" /> <title>Webserver Test</title> </head> <body> <h1>Test page</h1> <p>Webserver up & running :)</p> </body> </html>' >> /var/www/html/index.html \
        && chown apache:apache /var/www/html/index.html \
        && chmod 777 /var/www/html/index.html \
        && wget https://releases.wikimedia.org/mediawiki/1.28/mediawiki-1.28.0.tar.gz \
        && tar -xvzf mediawiki-1.28.0.tar.gz -C /var/www/html
RUN chown apache:apache /var/www/html/mediawiki-1.28.0/cache \
        && chown apache:apache /var/www/html/mediawiki-1.28.0/images 
#RUN yum -y install mariadb-server mariadb
COPY /apache-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["mysqld_safe"]
