FROM php:8.1-apache

LABEL maintainer="Kelnik Studios"

ARG TARGETPLATFORM
ARG TARGETARCH

ENV USER_ID=1000
ENV GROUP_ID=1000
ENV UNAME=developer

RUN case ${TARGETARCH} in \
         "amd64")  TINI_ARCH=amd64  ;; \
         "arm64")  TINI_ARCH=arm  ;; \
    esac && \
    apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        git wget zip unzip openssh-client sudo \
        inkscape imagemagick jpegoptim optipng webp ghostscript libavif-dev && \
    wget -q "https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.buster_${TARGETARCH}.deb" -O /tmp/wkhtmltopdf.deb && \
        apt install -y --no-install-recommends /tmp/wkhtmltopdf.deb && \
    wget -q https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions -O /usr/local/bin/install-php-extensions && \
        chmod +x /usr/local/bin/install-php-extensions && \
        sync && \
    install-php-extensions amqp gd zip soap sockets bcmath imap intl \
        mysqli pdo_mysql xsl opcache \
        pcntl shmop gettext calendar exif \
        redis memcached xdebug imagick mcrypt maxminddb && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    wget -q "https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_${TINI_ARCH}" -O /usr/local/bin/mhsendmail && \
        chmod +x /usr/local/bin/mhsendmail && \
    wget -q https://repo.ksdev.ru/amd64/chromium/chromium-headless-0.1.tar.gz -O /tmp/chromium.tar.gz && \
        tar -zxf /tmp/chromium.tar.gz -C /opt/ && \
        rm -rf /opt/chromium/portable && \
        chmod +x /opt/chromium/normal/chromium-headless && \
        chmod 755 /opt/chromium/normal/locales && \
        ln -s /opt/chromium/normal/chromium-headless /usr/local/sbin/chromium-browser && \
    rm -f /usr/local/bin/install-php-extensions && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /tmp/* /var/lib/apt/lists/*

COPY configs/php/8.ini $PHP_INI_DIR/php.ini
COPY configs/apache/bitrix.conf $APACHE_CONFDIR/sites-available/000-default.conf
COPY configs/ssl.conf /etc/ssl/developer.cnf
COPY scripts/deploy-project.sh /usr/local/bin/deploy-project
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint
COPY scripts/set-puid.sh /usr/local/bin/set-puid
COPY scripts/copy-ssh-keys.sh /usr/local/bin/copy-ssh-keys
COPY scripts/add-host-alias.sh /usr/local/bin/add-host-alias

RUN mkdir $APACHE_CONFDIR/ssl && \
    cd $APACHE_CONFDIR/ssl && \
    openssl req -new -x509 -days 1461 -nodes -out cert.pem -keyout cert.key \
            -extensions req_ext -config /etc/ssl/developer.cnf && \
    chmod +x /usr/local/bin/deploy-project \
            /usr/local/bin/entrypoint \
            /usr/local/bin/copy-ssh-keys \
            /usr/local/bin/add-host-alias \
            /usr/local/bin/set-puid && \
    mv /var/www/html /var/www/www && \
    a2enmod rewrite ssl headers expires proxy vhost_alias

# User
RUN groupadd --gid ${GROUP_ID} ${UNAME} && \
    useradd --uid ${USER_ID} --gid ${GROUP_ID} -m -g ${UNAME} -s /bin/bash ${UNAME} && \
    usermod -a -G sudo ${UNAME} && usermod -a -G www-data ${UNAME} && \
    echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    passwd -d ${UNAME} && \
    mkdir -p /home/${UNAME}/.ssh && \
    chown -R ${UNAME}:${UNAME} /home/${UNAME}/.ssh && \
    sed -i 's/\#\ \ \ StrictHostKeyChecking\ ask/StrictHostKeyChecking no/g' /etc/ssh/ssh_config && \
    sed -i "s;: \${APACHE_RUN_USER:=www-data};: \${APACHE_RUN_USER:=${UNAME}};g" $APACHE_CONFDIR/envvars && \
    sed -i "s;: \${APACHE_RUN_GROUP:=www-data};: \${APACHE_RUN_GROUP:=${UNAME}};g" $APACHE_CONFDIR/envvars

EXPOSE 80
EXPOSE 443

WORKDIR /var/www

USER ${UNAME}

ENTRYPOINT ["entrypoint"]
