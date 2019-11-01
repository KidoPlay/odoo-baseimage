FROM debian:buster-slim
MAINTAINER Kido <xiaochen.chi@tianmai-tech.cn>

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8

WORKDIR /app

COPY ./deploy/pip.conf ~/.pip/pip.conf
COPY ./deploy/wkhtmltox_0.12.5-1.stretch_amd64.deb ./wkhtmltox.deb

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN set -x; \
        apt-get update \
        && apt-get install -y \
            ca-certificates \
            curl \
            dirmngr \
            fonts-noto-cjk \
            gnupg \
            libssl-dev \
            node-less \
            npm \
            python3-num2words \
            python3-pip \
            python3-phonenumbers \
            python3-pyldap \
            python3-qrcode \
            python3-renderpm \
            python3-setuptools \
            python3-vobject \
            python3-watchdog \
            python3-xlwt \
            python3-dev \
            libsasl2-dev \
            libldap2-dev \
            libssl-dev \
            xz-utils \
            gcc \
            g++ \
        && apt-get install -y ./wkhtmltox.deb \
        && rm -rf wkhtmltox.deb \
        && echo 'deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
        && export GNUPGHOME="$(mktemp -d)" \
        && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
        && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
        && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
        && gpgconf --kill all \
        && rm -rf "$GNUPGHOME" \
        && apt-get install -y postgresql-client libpq-dev\
        && rm -rf /var/lib/apt/lists/*

# Install rtlcss (on Debian buster)
RUN set -x; \
    npm install -g rtlcss

# Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN mkdir -p /mnt/extra-addons

VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expose Odoo services
EXPOSE 8069 8071

# ENTRYPOINT ["/entrypoint.sh"]
CMD ["python3", "odoo-bin"]