FROM debian:stable

RUN \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get -y install --no-install-recommends \
    git subversion \
    gawk unzip file \
    ca-certificates wget curl rsync \
    python python3 \
    lua5.1 m4 \
    build-essential zlib1g-dev libssl-dev libncurses-dev gcc-multilib \
    && \
  apt-get clean

RUN useradd -ms /bin/bash -d /build build
USER build
ENV HOME /build

CMD [ "bash" ]

