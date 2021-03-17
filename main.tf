provider "alicloud" {
  region = "cn-beijing"
}

resource "alicloud_vpc" "this" {
  cidr_block = "172.16.0.0/12"
}

resource "alicloud_vswitch" "this" {
  availability_zone = "cn-beijing-b"
  cidr_block        = "172.16.0.0/21"
  vpc_id            = alicloud_vpc.this.id
}

resource "alicloud_security_group" "this" {}

resource "alicloud_eci_container_group" "example" {
  container_group_name = "tf-testacc-eci-gruop"
  cpu                  = 8.0
  memory               = 16.0
  restart_policy       = "OnFailure"
  security_group_id    = alicloud_security_group.this.id
  vswitch_id           = alicloud_vswitch.this.id
  tags = {
    TF = "create"
  }

  containers {
    image             = "registry-vpc.cn-beijing.aliyuncs.com/eci_open/nginx:alpine"
    name              = "nginx"
    working_dir       = "/tmp/nginx"
    image_pull_policy = "IfNotPresent"
    commands          = ["/bin/sh", "-c", "sleep 9999"]
    volume_mounts {
      mount_path = "/tmp/test"
      read_only  = false
      name       = "empty1"
    }
    ports {
      port     = 80
      protocol = "TCP"
    }
    environment_vars {
      key   = "test"
      value = "nginx"
    }
  }
  containers {
    image    = "registry-vpc.cn-beijing.aliyuncs.com/eci_open/centos:7"
    name     = "centos"
    commands = ["/bin/sh", "-c", "sleep 9999"]
  }
  init_containers {
    name              = "init-busybox"
    image             = "registry-vpc.cn-beijing.aliyuncs.com/eci_open/busybox:1.30"
    image_pull_policy = "IfNotPresent"
    commands          = ["echo"]
    args              = ["hello initcontainer"]
  }
  volumes {
    name = "empty1"
    type = "EmptyDirVolume"
  }
  volumes {
    name = "empty2"
    type = "EmptyDirVolume"
  }
}


resource "alicloud_eci_image_cache" "example" {
  image_cache_name  = "tf-test"
  images            = ["registry.cn-beijing.aliyuncs.com/sceneplatform/sae-image-xxxx:latest"]
  security_group_id = alicloud_security_group.this.id
  vswitch_id        = alicloud_vswitch.this.id
  eip_instance_id   = "eip-uf60c7cqb2pcrkgxhxxxx"
}