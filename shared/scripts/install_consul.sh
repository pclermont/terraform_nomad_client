#!/usr/bin/env bash

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT install_consul.sh: $1"
}

logger "Fetching Consul..."
CONSUL=0.7.0
cd /tmp
wget https://releases.hashicorp.com/consul/${CONSUL}/consul_${CONSUL}_linux_amd64.zip -O consul.zip


logger "Installing Consul..."
cd /tmp
unzip consul.zip >/dev/null
chmod +x consul
sudo mv consul /usr/local/bin/consul
sudo mkdir -p /opt/consul/data

CONSUL_JOIN=$(cat /tmp/consul-server-addr | tr -d '\n')

# Write the flags to a temporary file

IP=$( /sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}' )

cat >/tmp/consul-server-addr << EOF
CONSUL_FLAGS=" -bind=${IP} -join=${CONSUL_JOIN} -data-dir=/opt/consul/data"
EOF

if [ -f /tmp/consul_upstart.conf ];
then
  logger "Installing Consul Upstart service..."
  sudo mkdir -p /etc/consul.d
  sudo mv /tmp/client.hcl /etc/consul.d/
  sudo mkdir -p /etc/service
  sudo chown root:root /tmp/consul_upstart.conf
  sudo mv /tmp/consul_upstart.conf /etc/init/consul.conf
  sudo chmod 0644 /etc/init/consul.conf
  sudo mv /tmp/consul-server-addr /etc/service/consul
  sudo chmod 0644 /etc/service/consul
else
  logger "Installing Consul Systemd service..."
  sudo mkdir -p /etc/systemd/system/consul.d
  sudo mv /tmp/client.hcl /etc/systemd/system/consul.d/
  sudo chown root:root /tmp/consul.service
  sudo mv /tmp/consul.service /etc/systemd/system/consul.service
  sudo chmod 0644 /etc/systemd/system/consul.service
  sudo mv /tmp/consul-server-addr /etc/sysconfig/consul
  sudo chown root:root /etc/sysconfig/consul
  sudo chmod 0644 /etc/sysconfig/consul
fi

logger "Installing dnsmasq..."
sudo apt-get -y install dnsmasq
echo 'server=/consul/127.0.0.1#8600' > /tmp/10-consul
sudo mv /tmp/10-consul /etc/dnsmasq.d/
sudo service dnsmasq restart