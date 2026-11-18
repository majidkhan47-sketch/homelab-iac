terraform {
  backend "local" {
    path = "/var/tmp/tf-state/homelab.tfstate"
  }

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.70"
    }
  }
}

provider "proxmox" {
  endpoint  = "https://192.168.2.201:8006/"
  api_token = var.proxmox_api_token
  insecure  = true
}

resource "proxmox_virtual_environment_vm" "test_vm" {
  name            = "tf-test-vm-01"
  node_name       = "pve2"
  vm_id           = 205
  stop_on_destroy = true

  clone {
    vm_id = 9001
    full  = false
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 2048
  }

  network_device {
    bridge = "labnet"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_account {
      username = "admin-ser"
      keys     = [trimspace(file("~/.ssh/id_ed25519.pub"))]
    }
  }
}
