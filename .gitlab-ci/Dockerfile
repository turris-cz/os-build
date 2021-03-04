FROM debian:stable

## Apt update and upgrade
RUN apt-get update && \
    apt-get -y upgrade

## Dependencies required for tools which are used by OpenWrt and also a few to build some packages
RUN apt-get -y install --no-install-recommends \
    git subversion \
    gawk unzip file \
    ca-certificates wget curl rsync \
    python python3 \
    build-essential zlib1g-dev libssl-dev libncurses-dev gcc-multilib

## Dependencies for building medkit in general as Updater-ng, usign and fakeroot and others
RUN apt-get -y install --no-install-recommends \
    ca-certificates curl git bzip2 \
    autoconf autoconf-archive automake libtool \
    make cmake pkg-config gcc fakeroot \
    libcurl4-openssl-dev libevent-dev libssl-dev liburiparser-dev \
    libarchive-dev \
    uthash-dev \
    liblua5.1-0-dev

## Dependencies for Turris updater's lists
RUN apt-get -y install --no-install-recommends \
    git \
    lua5.1 \
    m4

## And finally, clean apt cache to not be present in the final container
RUN apt-get clean

## Add a user for build environment as it is not possible to build OpenWrt as root
RUN useradd -ms /bin/bash -d /build build
USER build
ENV HOME /build

CMD [ "bash" ]
