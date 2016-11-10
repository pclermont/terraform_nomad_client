#!/usr/bin/env bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT service.sh: $1"
}

logger "Starting Docker..."
echo 'DOCKER_OPTS="--dns 172.17.0.1"' >> /tmp/docker
sudo mv /tmp/docker /etc/default/docker
sudo service docker restart

if [ -x "$(command -v systemctl)" ]; then
  logger "using systemctl"
  sudo systemctl enable docker.service
  sudo systemctl start docker
else
  logger "using upstart"
  sudo restart docker
fi

logger "Starting Consul..."
if [ -x "$(command -v systemctl)" ]; then
  logger "using systemctl"
  sudo systemctl enable docker
  sudo systemctl start docker
else
  logger "using upstart"
  sudo start consul
fi

sleep 2

logger "Starting Nomad..."
if [ -x "$(command -v systemctl)" ]; then
  logger "using systemctl"
  sudo systemctl enable nomad.service
  sudo systemctl start nomad
else 
  logger "using upstart"
  sudo start nomad
fi
