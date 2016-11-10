#!/usr/bin/env bash

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT dependencies.sh: $1"
}

logger "Installing dependencies..."
if [ -x "$(command -v apt-get)" ]; then
  sudo apt-get update -y
  sudo apt-get install -y unzip apt-transport-https ca-certificates
  sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D -y
  echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /tmp/docker.list
  sudo mv /tmp/docker.list /etc/apt/sources.list.d/docker.list
  sudo apt-get update -y
  sudo apt-get purge lxc-docker -y
  sudo apt-get install linux-image-extra-$(uname -r) -y
  sudo apt-get install apparmor docker-engine -y
else
  logger "yum not supported"
  EXIT 255
fi