variable "auth_url" {}
variable "domain_name" {}
variable "region_name" {}
variable "project_name" {}
variable "user_name" {}
variable "password" {}
variable "image_name" {}
variable "internal_net" {}
variable "external_net" {}
variable "admin_size" {}
variable "master_size" {}
variable "mons" {}
variable "worker_size" {}
variable "osds" {}
variable "sles_base" {}
variable "sles_update" {}
variable "ses_base" {}
variable "ses_update" {}

provider "openstack" {
  domain_name = "${var.domain_name}"
  tenant_name = "${var.project_name}"
  user_name = "${var.user_name}"
  password = "${var.password}"
  auth_url = "${var.auth_url}"
  insecure = "true"
}

data "template_file" "admin" {
  template = "${file("admin.tpl")}"

  vars {
    sles_base = "${var.sles_base}"
    sles_update = "${var.sles_update}"
    ses_base = "${var.ses_base}"
    ses_update = "${var.ses_update}"
  }
}

data "template_file" "mon" {
  template = "${file("mon.tpl")}"

  vars {
    sles_base = "${var.sles_base}"
    sles_update = "${var.sles_update}"
    ses_base = "${var.ses_base}"
    ses_update = "${var.ses_update}"
    saltmaster = "host-${replace(openstack_compute_instance_v2.admin.access_ip_v4,".","-")}"
  }
}

data "template_file" "osd" {
  template = "${file("osd.tpl")}"

  vars {
    sles_base = "${var.sles_base}"
    sles_update = "${var.sles_update}"
    ses_base = "${var.ses_base}"
    ses_update = "${var.ses_update}"
    saltmaster = "host-${replace(openstack_compute_instance_v2.admin.access_ip_v4,".","-")}"
  }
}

resource "openstack_compute_keypair_v2" "keypair" {
  name       = "ses-ssh"
  region     = "${var.region_name}"
  public_key = "${file("ssh/id_caasp.pub")}"
}

resource "openstack_compute_secgroup_v2" "secgroup_base" {
  name        = "ses-base"
  region      = "${var.region_name}"
  description = "Basic security group for ses"

  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 2379
    to_port     = 2379
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "secgroup_admin" {
  name        = "ses-admin"
  region      = "${var.region_name}"
  description = "ses security group for admin"

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 4505
    to_port     = 4506
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 389
    to_port     = 389
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
  rule {
    from_port   = 6780
    to_port     = 7500
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "secgroup_mon" {
  name        = "ses-mon"
  region      = "${var.region_name}"
  description = "ses security group for mons"

  rule {
    from_port   = 2380
    to_port     = 2380
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 6443
    to_port     = 6444
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 8285
    to_port     = 8285
    ip_protocol = "udp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 30000
    to_port     = 32768
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 30000
    to_port     = 32768
    ip_protocol = "udp"
    cidr        = "0.0.0.0/0"
  }
  rule {
    from_port   = 6780
    to_port     = 7500
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "secgroup_osd" {
  name        = "ses-osd"
  region      = "${var.region_name}"
  description = "ses security group for osds"

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 8080
    to_port     = 8080
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 8081
    to_port     = 8081
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 2380
    to_port     = 2380
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 10250
    to_port     = 10250
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 8285
    to_port     = 8285
    ip_protocol = "udp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 30000
    to_port     = 32768
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 30000
    to_port     = 32768
    ip_protocol = "udp"
    cidr        = "0.0.0.0/0"
  }
  rule {
    from_port   = 6780
    to_port     = 7500
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_instance_v2" "admin" {
  name       = "ses-admin"
  region     = "${var.region_name}"
  image_name = "${var.image_name}"

  connection {
    private_key = "${file("ssh/id_caasp.pub")}"
  }

  flavor_name = "${var.admin_size}"
  key_pair    = "ses-ssh"

  network {
    name = "${var.internal_net}"
  }

  security_groups = [
    "${openstack_compute_secgroup_v2.secgroup_base.name}",
    "${openstack_compute_secgroup_v2.secgroup_admin.name}"
  ]

  user_data = "${data.template_file.admin.rendered}"
}

resource "null_resource" "deepsea" {

  connection {
    type = "ssh"
    host = "${openstack_compute_floatingip_associate_v2.admin_ext_ip.floating_ip}"
    private_key = "${file("ssh/id_caasp")}"
  }

  provisioner "file" {
    source      = "deepsea.sh"
    destination = "/tmp/deepsea.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/deepsea.sh",
      "/tmp/deepsea.sh",
    ]
  }
  depends_on = ["openstack_compute_instance_v2.admin", "openstack_compute_instance_v2.osd", 
  "openstack_compute_instance_v2.mon", "openstack_compute_volume_attach_v2.salt-minion-attach"]
}

resource "openstack_networking_floatingip_v2" "admin_ext" {
  pool = "${var.external_net}"
}

resource "openstack_compute_floatingip_associate_v2" "admin_ext_ip" {
  floating_ip = "${openstack_networking_floatingip_v2.admin_ext.address}"
  instance_id = "${openstack_compute_instance_v2.admin.id}"
}

resource "openstack_compute_instance_v2" "mon" {
  count      = "${var.mons}"
  name       = "ses-mon${count.index}"
  region     = "${var.region_name}"
  image_name = "${var.image_name}"

  connection {
    private_key = "${file("ssh/id_caasp.pub")}"
  }

  flavor_name = "${var.master_size}"
  key_pair    = "ses-ssh"

  network {
    name = "${var.internal_net}"
  }

  security_groups = [
    "${openstack_compute_secgroup_v2.secgroup_base.name}",
    "${openstack_compute_secgroup_v2.secgroup_mon.name}"
  ]

  user_data = "${data.template_file.mon.rendered}"
}

resource "openstack_blockstorage_volume_v2" "osd-blk" {
  count = "${var.osds}",
  size = 2
  name = "osd-blk${count.index}"
}

resource "openstack_compute_volume_attach_v2" "salt-minion-attach" {
  count = "${var.osds}"
  instance_id = "${element(openstack_compute_instance_v2.osd.*.id, count.index)}"
  volume_id = "${element(openstack_blockstorage_volume_v2.osd-blk.*.id, count.index)}"
}

resource "openstack_compute_instance_v2" "osd" {
  count      = "${var.osds}"
  name       = "ses-osd${count.index}"
  region     = "${var.region_name}"
  image_name = "${var.image_name}"

  connection {
    private_key = "${file("ssh/id_caasp.pub")}"
  }

  flavor_name = "${var.worker_size}"
  key_pair    = "ses-ssh"

  network {
    name = "${var.internal_net}"
  }

  security_groups = [
    "${openstack_compute_secgroup_v2.secgroup_base.name}",
    "${openstack_compute_secgroup_v2.secgroup_osd.name}"
  ]

  user_data = "${data.template_file.osd.rendered}"
}

output "external_ip_admin" {
  value = "${openstack_networking_floatingip_v2.admin_ext.address}"
}

output "internal_ip_admin" {
  value = ["${openstack_compute_instance_v2.admin.access_ip_v4}"]
}

output "internal_ip_mons" {
  value = ["${openstack_compute_instance_v2.mon.*.access_ip_v4}"]
}

output "internal_ip_osds" {
  value = ["${openstack_compute_instance_v2.osd.*.access_ip_v4}"]
}