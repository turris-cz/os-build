# This is Docker file for container used on Gitlab to test
# if all patches were applied correctly.
# To build it you have to run in repository root:
#   docker build -t registry.nic.cz/turris/turris-build -f .Dockerfile .
# With built container you can push it to Gitlab with:
#   docker push registry.nic.cz/turris/turris-build

FROM debian:stable

RUN \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get -y install --no-install-recommends \
    git subversion \
    gawk unzip file \
    ca-certificates wget curl rsync \
    python python3 \
    build-essential zlib1g-dev libssl-dev libncurses-dev gcc-multilib \
    && \
  apt-get clean

RUN useradd -ms /bin/bash -d /build build
USER build
ENV HOME /build

CMD [ "bash" ]

