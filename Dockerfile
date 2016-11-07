FROM debian:jessie

# The nodejs version from debian is outdated
RUN apt-get update -y && apt-get install -y curl locales
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -

# Switch to Europe/Berlin
RUN ln --force --symbolic "/usr/share/zoneinfo/Europe/Berlin" "/etc/localtime"
RUN dpkg-reconfigure --frontend=noninteractive tzdata

# Switch to UTF-8
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="en_US.UTF-8"' > /etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

RUN apt-get update -y && apt-get install -y \
    ruby \
    ruby-dev \
    libmysqlclient-dev \
    cmake \
    pkg-config \
    imagemagick \
    git \
    php5-dev \
    php5-cli \
    php-pear \
    php5-mysql \
    php5-curl \
    php5-imagick \
    php5-mcrypt \
    php5-mhash \
    php5-redis \
    php5-sqlite

RUN cd /usr/local/bin/ && curl https://getcomposer.org/installer | php && mv composer.phar composer

COPY config/prepare_environment /usr/local/bin/prepare_environment

RUN gem install bundler
RUN bundle config --global silence_root_warning 1

# Use correct Port for git
RUN mkdir -p /root/.ssh
COPY config/ssh_config /root/.ssh/config

# Preset some environment vars
ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    COMPOSER_NO_INTERACTION=1 \
    COMPOSER_ALLOW_SUPERUSER=1

# Install older version of node & npm
RUN cd /tmp && \
    curl https://nodejs.org/download/release/v6.7.0/node-v6.7.0-linux-x64.tar.gz -O && \
    cd /usr/local && \
    tar -xzf /tmp/node-v6.7.0-linux-x64.tar.gz && \
    rm /tmp/node-v6.7.0-linux-x64.tar.gz && \
    cd /usr/local/bin && \
    ln -s /usr/local/node-v6.7.0-linux-x64/bin/npm && \
    ln -s /usr/local/node-v6.7.0-linux-x64/bin/node
