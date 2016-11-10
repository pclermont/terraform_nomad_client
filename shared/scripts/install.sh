#!/usr/bin/env bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT install.sh: $1"
}

logger "Fetching Nomad..."
NOMAD=0.4.1
cd /tmp
wget https://releases.hashicorp.com/nomad/${NOMAD}/nomad_${NOMAD}_linux_amd64.zip -O nomad.zip

logger "Installing Nomad..."
cd /tmp
unzip nomad.zip >/dev/null
chmod +x nomad
sudo mv nomad /usr/local/bin/nomad
sudo mkdir -p /opt/nomad/data

IP=$( /sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}' )

cat >/tmp/nomad_flags << EOF
NOMAD_FLAGS=" -data-dir=/opt/nomad/data -client"
EOF

cat >/tmp/nomad_default.hcl << EOF
data_dir     = "/opt/nomad/data"
enable_debug = true
bind_addr    = "0.0.0.0"
//region       = "{{ region }}"
//datacenter   = "{{ datacenter }}"
//name         = "{{ name }}"
//log_level    = "{{ log_level }}"
advertise       {
        http = "${IP}:4646"
}
EOF

if [ -f /tmp/upstart.conf ];
then
  logger "Installing Upstart service..."
  sudo mkdir -p /etc/nomad.d
  sudo chmod 0644 /tmp/nomad_default.hcl
  sudo mv /tmp/nomad_default.hcl /etc/nomad.d/default.hcl
  sudo mkdir -p /etc/service
  sudo chown root:root /tmp/upstart.conf
  sudo mv /tmp/upstart.conf /etc/init/nomad.conf
  sudo chmod 0644 /etc/init/nomad.conf
  sudo cp /tmp/nomad_flags /etc/service/nomad
  sudo chmod 0644 /etc/service/nomad
else
  logger "Installing Systemd service..."
  sudo mkdir -p /etc/systemd/system/nomad.d
  sudo chmod 0644 /tmp/nomad_default.hcl
  sudo mv /tmp/nomad_default.hcl /etc/systemd/system/nomad.d/default.hcl
  sudo chown root:root /tmp/nomad.service
  sudo mv /tmp/nomad.service /etc/systemd/system/nomad.service
  sudo chmod 0644 /etc/systemd/system/nomad.service
  sudo cp /tmp/nomad_flags /etc/sysconfig/nomad
  sudo chown root:root /etc/sysconfig/nomad
  sudo chmod 0644 /etc/sysconfig/nomad
fi

