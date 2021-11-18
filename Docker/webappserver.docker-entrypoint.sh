#!/bin/bash

# Entrypoint for Mr-Plantes's application server Docker container

# Wraps the official PHP Docker image entrypoint (/usr/local/bin/docker-php-entrypoint)
# to allow running "composer install" automatically at startup only if needed.

# References:
# * php:5.6.40-apache-jessie image's `Dockerfile` and https://github.com/docker-library/php/blob/c88c3d52f41a370f3a62e3ded62b7b223b4cb846/5.6/jessie/apache/Dockerfile

set -Eeuo pipefail

readonly PROGNAME="$(basename -- "$0")"
readonly PROGDIR="$(readlink -m -- "$(dirname -- "$0")")"
readonly ARGS="$@"

exec \
    chroot --userspec=$(whoami) / \
    /usr/local/bin/docker-php-entrypoint "$@"

# Reads the group the web server is running under
webserver_group=$( \
    . /etc/apache2/envvars 2>/dev/null && \
    echo "${APACHE_RUN_GROUP}" || \
    echo "nobody" \
) && \
chgrp -R "${webserver_group}" . && \
chmod -R g+w \
    .plantes/wp-content \
    && \
true # No-op command to avoid "Empty continuation line" warning
