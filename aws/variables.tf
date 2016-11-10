variable "name" {
  default = "nomad-client"
  description = "Name for the clients"
}

variable "platform" {
  default = "ubuntu"
  description = "The OS Platform"
}

variable "user" {
  default = {
    ubuntu  = "ubuntu"
    rhel6   = "ec2-user"
    centos6 = "centos"
    centos7 = "centos"
    rhel7   = "ec2-user"
  }
}

variable "ami" {
  description           = "AWS AMI Id, if you change, make sure it is compatible with instance type, not all AMIs allow all instance types "
  default = {
    us-east-1-ubuntu  = "ami-fce3c696"
    us-west-2-ubuntu  = "ami-9abea4fb"
    eu-west-1-ubuntu = "ami-47a23a30"
    eu-central-1-ubuntu = "ami-accff2b1"
    ap-northeast-1-ubuntu = "ami-90815290"
    ap-southeast-1-ubuntu = "ami-0accf458"
    ap-southeast-2-ubuntu = "ami-1dc8b127"
    us-east-1-rhel6   = "ami-0d28fe66"
    us-west-2-rhel6   = "ami-3d3c0a0d"
    us-east-1-centos6 = "ami-57cd8732"
    us-west-2-centos6 = "ami-1255b321"
    us-east-1-rhel7   = "ami-2051294a"
    us-west-2-rhel7   = "ami-775e4f16"
    us-east-1-centos7 = "ami-6d1c2007"
    us-west-1-centos7 = "ami-af4333cf"
  }
}

variable "service_conf" {
  default = {
    ubuntu  = "debian_upstart.conf"
    rhel6   = "rhel_upstart.conf"
    centos6 = "rhel_upstart.conf"
    centos7 = "rhel_nomad.service"
    rhel7   = "rhel_nomad.service"
  }
}

variable "service_conf_dest" {
  default = {
    ubuntu  = "upstart.conf"
    rhel6   = "upstart.conf"
    centos6 = "upstart.conf"
    centos7 = "nomad.service"
    rhel7   = "nomad.service"
  }
}

variable "consul_service_conf" {
  default = {
    ubuntu  = "debian_consul_upstart.conf"
    rhel6   = "rhel_consul_upstart.conf"
    centos6 = "rhel_consul_upstart.conf"
    centos7 = "rhel_consul.service"
    rhel7   = "rhel_consul.service"
  }
}

variable "consul_service_conf_dest" {
  default = {
    ubuntu  = "consul_upstart.conf"
    rhel6   = "consul_upstart.conf"
    centos6 = "consul_upstart.conf"
    centos7 = "consul.service"
    rhel7   = "consul.service"
  }
}

variable "key_name" {
  description = "SSH key name in your AWS account for AWS instances."
  default = "deployer-key"
}

variable "region" {
  default = "us-east-1"
  description = "The region of AWS, for AMI lookups."
}

variable "servers" {
  default = "2"
  description = "The number of Nomad servers to launch."
}

variable "instance_type" {
  default = "t2.small"
  description = "AWS Instance type, if you change, make sure it is compatible with AMI, not all AMIs allow all instance types "
}

variable "tagName" {
  default = "Nomad-Server"
  description = "Name tag for the servers"
}

variable "consul_ips" {
  description = "The IPs for the consul servers"
}

variable "zones" {
  description = "the zones used for launching the machines."
}

variable "vpc_id" {
  description = "the ID of the vpc to launch our machines into."
}

variable "vpc_cidr" {
  description = "the subnet ip range to use"
}

variable "subnet_ids" {
  description = "the subnet id used to launch machines"
}

variable "disk_size" {
  default = "10"
  description = "the size of the disk of the instance"
}

variable "private_key" {
  description = "Path to the private key specified by key_name."
  default = "~/.ssh/id_rsa"
}

variable "bastion_host" {
  description = "SSH Host to use for remote execution"
}
