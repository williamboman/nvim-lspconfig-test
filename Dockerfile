FROM ubuntu:latest AS base

RUN yes | unminimize

RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && \
    apt install -y tzdata && \
    dpkg-reconfigure --frontend noninteractive tzdata

# Base deps
RUN apt update
RUN apt install -y \
        clang \
        cmake \
        curl \
        default-jre \
        erlang \
        g++ \
        git \
        gzip \
        haskell-platform \
        libxml2-dev \
        make \
        ninja-build \
        php-cli \
        python3 \
        python3-pip \
        python3-venv \
        ruby \
        ruby-dev \
        software-properties-common \
        tar \
        unzip \
        wget

# Dart
RUN wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list && \
    apt update && \
    apt install -y dart

# Dotnet
RUN wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt update && \
    apt install -y dotnet-sdk-5.0

# Ocaml
RUN add-apt-repository ppa:avsm/ppa && \
        apt update && \
        apt install -y ocaml opam && \
        opam init -y && \
        opam install -y merlin

# Neovim
RUN wget -O /opt/nvim-linux64.tar.gz https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz && \
    tar -xvf /opt/nvim-linux64.tar.gz -C /opt

# PHP
RUN curl -fsSL https://getcomposer.org/installer -o /tmp/composer-setup.php && \
    php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Node.js
RUN KEYRING=/usr/share/keyrings/nodesource.gpg; VERSION=node_16.x; DISTRO="$(lsb_release -s -c)"; \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --dearmor | tee "$KEYRING" > /dev/null && \
    gpg --no-default-keyring --keyring "$KEYRING" --list-keys && \
    echo "deb [signed-by=$KEYRING] https://deb.nodesource.com/$VERSION $DISTRO main" | tee /etc/apt/sources.list.d/nodesource.list && \
    echo "deb-src [signed-by=$KEYRING] https://deb.nodesource.com/$VERSION $DISTRO main" | tee -a /etc/apt/sources.list.d/nodesource.list && \
    apt update && apt install -y nodejs

# Go
RUN rm -rf /usr/local/go && \
    curl -fsSL https://go.dev/dl/go1.17.5.linux-amd64.tar.gz | tar -xz -C /usr/local

# Erlang
RUN wget -nv -O /usr/local/bin/rebar3 https://s3.amazonaws.com/rebar3/rebar3 && \
    chmod +x /usr/local/bin/rebar3

# pwsh
RUN curl -fsSL https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb > /tmp/packages-microsoft-prod.deb && \
    dpkg -i /tmp/packages-microsoft-prod.deb && \
    rm /tmp/packages-microsoft-prod.deb && \
    apt update && apt install -y powershell

# Install Rust
RUN curl -fsS https://sh.rustup.rs | bash -s -- -y

# Install Watchman
RUN mkdir -p /tmp/watchman && \
    curl -fsSL https://github.com/facebook/watchman/releases/download/v2021.12.06.00/watchman-v2021.12.06.00-linux.zip > /tmp/watchman.zip && \
    unzip -d /tmp/watchman /tmp/watchman.zip && \
    cd /tmp/watchman/watchman-v2021.12.06.00-linux && \
    mkdir -p /usr/local/var/run/watchman && \
    cp bin/* /usr/local/bin && \
    cp lib/* /usr/local/lib && \
    chmod 755 /usr/local/bin/watchman && \
    chmod 2777 /usr/local/var/run/watchman && \
    rm -rf /tmp/watchman.zip /tmp/watchman

# Install vala
RUN add-apt-repository ppa:vala-team && \
    apt update && apt install -y valac

RUN pip3 install meson

ENV PATH "/root/.cargo/bin:/usr/local/go/bin:/root/.opam/default/bin:/usr/lib/dart/bin:/opt/nvim-linux64/bin:${PATH}"
