terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = "./tf_key.json"
  folder_id                = local.folder_id
  zone                     = "ru-central1-a"
}

resource "yandex_vpc_network" "foo" {
  name = "my-net"
}

resource "yandex_vpc_subnet" "foo" {
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.foo.id
  v4_cidr_blocks = ["10.5.0.0/24"]
}
resource "yandex_vpc_security_group" "group1" {
  name        = "My security group"
  description = "description for my security group"
  network_id  = "${yandex_vpc_network.foo.id}"
  labels = {
    my-label = "catgpt-sg"
  }
}
resource "yandex_vpc_security_group_rule" "rule1" {
  security_group_binding = yandex_vpc_security_group.group1.id
  direction              = "ingress"
  description            = "rule1 description"
  v4_cidr_blocks = ["10.5.0.0/24"]
  from_port              = 8080
  to_port                = 8080
  protocol               = "TCP"
}
resource "yandex_container_registry" "registry1" {
  name = "sagrityaninregistry"
  folder_id = local.folder_id
}

locals {
  folder_id = "b1g72ja3gj83ksl68q3h"
  service-accounts = toset([
    "sagrityanin1", "catgpt-ig-sa"
  ])
  catgpt-sagrityanin1-roles = toset([
    "container-registry.images.puller",
    "container-registry.viewer",
    "monitoring.editor",
  ])
  catgpt-ig-sa-roles = toset([
    "compute.editor",
    "iam.serviceAccounts.user",
    "load-balancer.admin",
    "vpc.publicAdmin",
    "vpc.user",
  ])
}

resource "yandex_iam_service_account" "service-accounts" {
  for_each = local.service-accounts
  name     = each.key
}
resource "yandex_resourcemanager_folder_iam_member" "catgpt-roles" {
  for_each  = local.catgpt-sagrityanin1-roles
  folder_id = local.folder_id
  member    = "serviceAccount:${yandex_iam_service_account.service-accounts["sagrityanin1"].id}"
  role      = each.key
}
resource "yandex_resourcemanager_folder_iam_member" "catgpt-ig-roles" {
  for_each  = local.catgpt-ig-sa-roles
  folder_id = local.folder_id
  member    = "serviceAccount:${yandex_iam_service_account.service-accounts["catgpt-ig-sa"].id}"
  role      = each.key
}

data "yandex_compute_image" "coi" {
  family = "container-optimized-image"
}
resource "yandex_compute_instance_group" "catgpt-group" {
  name = "catgpt-group"
  depends_on = [
    yandex_resourcemanager_folder_iam_member.catgpt-ig-roles
  ]
  service_account_id = yandex_iam_service_account.service-accounts["catgpt-ig-sa"].id
  instance_template {
    platform_id = "standard-v2"
    
    resources {
      cores         = 2
      memory        = 1
      core_fraction = 5
    }
    boot_disk {
      initialize_params {
        type = "network-hdd"
        size = "30"
        image_id = data.yandex_compute_image.coi.id
      }
    }
    network_interface {
      subnet_ids = ["${yandex_vpc_subnet.foo.id}"]
      nat = true
      
    }
    scheduling_policy {
      preemptible = true
    }
    service_account_id = yandex_iam_service_account.service-accounts["sagrityanin1"].id

    metadata = {
      docker-compose = templatefile(
        "${path.module}/docker-compose.yaml",
        {
          folder_id   = "${local.folder_id}",
          registry_id = "${yandex_container_registry.registry1.id}",
        }
      )
      user-data = file("${path.module}/cloud-config.yaml")
      ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }
  }
  scale_policy {
    fixed_scale {
      size = 2
    }
  }
  allocation_policy {
    zones = ["ru-central1-a"]
  }
  deploy_policy {
    max_unavailable = 2
    max_creating = 2
    max_expansion = 2
    max_deleting = 2
  }
  load_balancer {
    target_group_name        = "target-group"
    target_group_description = "load balancer target group"
  }
}


