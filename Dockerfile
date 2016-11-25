FROM ubuntu:latest

# install the PHP extensions we need
RUN apt-get update && apt-get install -y software-properties-common python-software-properties \
	&& apt-add-repository -y ppa:webupd8team/java && apt-get update \
	&& apt-get install -y oracle-java8-installer \
	&& rm -rf /var/lib/apt/lists/* 

VOLUME /var/www/html

ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle

RUN wget http://downloads.ghostscript.com/public/binaries/ghostscript-9.15-linux-x86_64.tgz \
	&& tar xzvf ghostscript-9.15-linux-x86_64.tgz \
	&& cd /usr/bin/ \
	&& mv gs gs-- \
	&& ln -s /opt/ghostscript-9.15-linux-x86_64/gs-915-linux_x86_64 gs

# upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
RUN curl -o wordpress.tar.gz -SL https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz \
	&& echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
	&& tar -xzf wordpress.tar.gz -C /usr/src/ \
	&& rm wordpress.tar.gz \
	&& chown -R www-data:www-data /usr/src/wordpress

COPY docker-entrypoint.sh /entrypoint.sh

# grr, ENTRYPOINT resets CMD now
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
