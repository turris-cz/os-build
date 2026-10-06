FROM debian:bookworm

RUN apt-get update && \
  apt-get -y upgrade && \
  apt-get -y install --no-install-recommends \
  autoconf \
  autoconf-archive \
  automake \
  build-essential \
  bzip2 \
  ca-certificates \
  cmake \
  curl \
  fakeroot \
  file \
  gawk \
  gcc \
  gcc-multilib \
  git \
  libarchive-dev \
  libcurl4-openssl-dev \
  libevent-dev \
  liblua5.1-0-dev \
  libncurses-dev \
  libssl-dev \
  libtool \
  liburiparser-dev \
  lua5.1 \
  m4 \
  make \
  pkg-config \
  python3 \
  python3-distutils \
  rsync \
  subversion \
  unzip \
  uthash-dev \
  wget \
  zlib1g-dev && \ 
  rm -rf /var/lib/apt/lists/*

## Compile custom library base64c required by updater-ng
WORKDIR /tmp

RUN \
  git clone --branch "v0.2.1" "https://gitlab.nic.cz/turris/base64c.git" && \
  cd base64c && \
  ./bootstrap && ./configure --prefix=/usr && make install && \
  cd .. && \
  rm -rf base64c

## Add a user for build environment as it is not possible to build OpenWrt as root
RUN useradd -ms /bin/bash -d /build build

WORKDIR /build
USER build
ENV HOME="/build"

CMD [ "bash" ]
