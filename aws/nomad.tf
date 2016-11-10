provider "aws" {
    region = "${var.region}"
    alias  = "${var.region}"
}

resource "aws_efs_file_system" "volumes" {
  creation_token = "Volumes for the docker network"
  tags {
    Name = "DockerVolumes"
  }
}

resource "aws_efs_mount_target" "volumes" {
  count = "${length(split(",", var.zones))}"
  file_system_id = "${aws_efs_file_system.volumes.id}"
  subnet_id = "${element(split(",", var.subnet_ids), count.index % length(split(",", var.subnet_ids)))}"
  security_groups = ["${aws_security_group.nomad_client.id}"]
}

resource "aws_instance" "nomad_client" {
  provider      = "aws.${var.region}"
  ami           = "${lookup(var.ami, join("-",list( var.region, var.platform)))}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.key_name}"
  subnet_id     = "${element(split(",", var.subnet_ids), count.index % length(split(",", var.subnet_ids)))}"
  count         = "${var.servers}"

  root_block_device {
    volume_size = "${var.disk_size}"
  }

  associate_public_ip_address = false
  vpc_security_group_ids      = ["${aws_security_group.nomad_client.id}"]

  connection {
    user = "${lookup(var.user, var.platform)}"
    private_key = "${file(var.private_key)}"
    bastion_host = "${var.bastion_host}"
  }

  #Instance tags
  tags {
    Name = "${var.name}-${element(split(",", var.zones), count.index % length(split(",", var.zones)))}-${count.index + 1}"
    Type    = "${var.name}"
    Zone    = "${element(split(",", var.zones), count.index % length(split(",", var.zones)))}"
    Machine = "${var.instance_type}"
  }
  depends_on = ["aws_efs_mount_target.volumes"]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install -y nfs-common",
      "sudo mkdir -p /opt/nomad/data/alloc",
      "cp /etc/fstab /tmp/fstab",
      "echo '${element(aws_efs_mount_target.volumes.*.dns_name, count.index % length(aws_efs_mount_target.volumes.*.dns_name))}:/ /opt/nomad/data/alloc nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0'  >> /tmp/fstab",
      "sudo cp /tmp/fstab /etc/fstab",
      "sudo mount -a"
    ]
  }

  provisioner "file" {
    source = "${path.module}/../shared/scripts/client.hcl"
    destination = "/tmp/client.hcl"
  }

  provisioner "file" {
    source = "${path.module}/../shared/scripts/${lookup(var.service_conf, var.platform)}"
    destination = "/tmp/${lookup(var.service_conf_dest, var.platform)}"
  }
  provisioner "file" {
    source = "${path.module}/../shared/scripts/${lookup(var.consul_service_conf, var.platform)}"
    destination = "/tmp/${lookup(var.consul_service_conf_dest, var.platform)}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${element(split(",", var.consul_ips), 0)} > /tmp/consul-server-addr",
      "echo ${var.servers} > /tmp/nomad-server-count",
    ]
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/../shared/scripts/dependencies.sh",
      "${path.module}/../shared/scripts/install_consul.sh",
      "${path.module}/../shared/scripts/install.sh",
      "${path.module}/../shared/scripts/service.sh",
      "${path.module}/../shared/scripts/ip_tables.sh",
    ]
  }
}

resource "aws_security_group" "nomad_client" {
  provider    = "aws.${var.region}"
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "Security group for Nomad clients"

  tags { Name = "${var.name}" }

  // These are for internal traffic
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  ingress {
    from_port = 4646
    to_port = 4648
    protocol = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  // These are for maintenance
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // This is for outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
