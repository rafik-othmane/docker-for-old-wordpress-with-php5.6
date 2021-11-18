# Dockerfile for DataGarden's application server

FROM php:5.6.40-apache-stretch

# php.ini file to use as base configuration, can be one of:
# * php.ini-development
# * php.ini-production
# Defaults to "php.ini-development"
ARG PHP_INI_BASE_FILE="php.ini-development"


# Installs system packages
RUN \
    apt-get --assume-yes --quiet update && \
    apt-get --assume-yes --quiet --no-install-recommends install \
        curl \
        && \
    apt-get --assume-yes --quiet clean && \
    apt-get --assume-yes --quiet autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    true # No-op command to avoid "Empty continuation line" warning

# Enables Apache modules
RUN \
    a2enmod \
        deflate \
        expires \
        rewrite \
        && \
    true # No-op command to avoid "Empty continuation line" warning

# "docker-php-extension-installer" tool
ADD https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/
RUN \
    chmod +x /usr/local/bin/install-php-extensions && \
    sync && \
    true # No-op command to avoid "Empty continuation line" warning

# Installs required PHP extensions (except the one already installed, see `php -m`)
RUN \
    install-php-extensions \
        bz2 \
        curl \
        ldap \
        fileinfo \
        imagick \
        mbstring \
        pdo_mysql \
        mysql \
        session \
        simplexml \
        soap \
        xml \
        xmlrpc \
        zip \
        gd \
        && \
    true # No-op command to avoid "Empty continuation line" warning


# Add extra Apache *.conf configuration files
COPY Docker/webappserver/apache-configurations/* "${APACHE_CONFDIR}/conf-enabled/"

# Choose base php.ini file to use
RUN \
    cp -a "${PHP_INI_DIR}/${PHP_INI_BASE_FILE}" "${PHP_INI_DIR}/php.ini" && \
    true # No-op command to avoid "Empty continuation line" warning

# Add extra PHP *.ini configuration files
COPY Docker/webappserver/php-configurations/* "${PHP_INI_DIR}/conf.d/"

# Add entrypoint script
COPY Docker/webappserver.docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Certificates
COPY Docker/certificates/* /usr/local/share/ca-certificates/
RUN \
    update-ca-certificates


ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["apache2-foreground"]

LABEL \
    org.opencontainers.image.title="${COMPOSE_PROJECT_NAME}  - Webserver" \
    org.opencontainers.image.project="${COMPOSE_PROJECT_NAME}" \
    org.opencontainers.image.module="Webserver" \
    org.opencontainers.image.vendor="${COMPOSE_PROJECT_VENDOR}" \
    org.opencontainers.image.licenses="proprietary"
