FROM debian:bullseye-slim

ENV USER_ID=1000
ENV GROUP_ID=1000
ENV UNAME=developer

WORKDIR /var/www/

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends gnupg ca-certificates zip unzip openssh-client rsync sudo git wget curl apt-transport-https \
    && echo "deb https://packages.sury.org/php/ bullseye main" | tee /etc/apt/sources.list.d/sury-php.list \
    && wget -qO - https://packages.sury.org/php/apt.gpg | sudo apt-key add - \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends ghostscript libmagickcore-6.q16-6-extra libnss3 \
       php8.1-amqp php8.1-bcmath php8.1-bz2 php8.1-cli php8.1-common php8.1-curl php8.1-fpm php8.1-gd php8.1-gmp php8.1-igbinary php8.1-imagick php8.1-intl php8.1-maxminddb php8.1-mbstring php8.1-memcached php8.1-msgpack php8.1-mysql php8.1-opcache php8.1-pgsql php8.1-readline php8.1-redis php8.1-sqlite3 php8.1-vips php8.1-xml php8.1-yaml php8.1-zip php8.1-xdebug \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY configs/php8.ini /etc/php/8.1/fpm/php.ini
COPY configs/php8.ini /etc/php/8.1/cli/php.ini
COPY configs/www.conf /etc/php/8.1/fpm/pool.d/www.conf
COPY configs/docker.conf /etc/php/8.1/fpm/pool.d/docker.conf
COPY configs/zz-docker.conf /etc/php/8.1/fpm/pool.d/zz-docker.conf

COPY scripts/entrypoint-php-fpm.sh /usr/local/bin/entrypoint
COPY scripts/set-puid.sh /usr/local/bin/set-puid
COPY scripts/copy-ssh-keys.sh /usr/local/bin/copy-ssh-keys
COPY scripts/add-host-alias.sh /usr/local/bin/add-host-alias

# User
RUN chmod +x /usr/local/bin/entrypoint /usr/local/bin/set-puid /usr/local/bin/copy-ssh-keys /usr/local/bin/add-host-alias && \
    ln -s /usr/sbin/php-fpm8.1 /usr/local/bin/php-fpm && \
    groupadd --gid ${GROUP_ID} ${UNAME} && \
    useradd --uid ${USER_ID} --gid ${GROUP_ID} -m -g ${UNAME} -s /bin/bash ${UNAME} && \
    usermod -a -G sudo ${UNAME} && usermod -a -G www-data ${UNAME} && \
    echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    passwd -d ${UNAME} && \
    mkdir -p /home/${UNAME}/.ssh /var/log/php /run/php && \
    chown -R ${UNAME}:${UNAME} /home/${UNAME}/.ssh /var/log/php /run/php && \
    chmod 775 /var/log/php && \
    sed -i 's/\#\ \ \ StrictHostKeyChecking\ ask/StrictHostKeyChecking no/g' /etc/ssh/ssh_config

EXPOSE 9000

USER ${UNAME}

ENTRYPOINT ["entrypoint"]
CMD ["php-fpm"]
