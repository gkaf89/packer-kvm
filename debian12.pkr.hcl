# Packer configuration file to generate a Debian 12 Vagrant box

variable "config_file" {
  type    = string
  default = "debian-preseed.cfg"
}

variable "cpu" {
  type    = string
  default = "2"
}

# Use a 40GB disk
variable "disk_size" {
  type    = string
  default = "40000"
}

variable "headless" {
  type    = string
  default = "true"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:23ab444503069d9ef681e3028016250289a33cc7bab079259b73100daee0af66"
}

variable "iso_url" {
  type    = string
  default = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.2.0-amd64-netinst.iso"
}

variable "name" {
  type    = string
  default = "debian"
}

variable "ram" {
  type    = string
  default = "2048"
}

variable "ssh_password" {
  type    = string
  default = "vagrant"
}

variable "ssh_username" {
  type    = string
  default = "root"
}

variable "version" {
  type    = string
  default = "12"
}

source "qemu" "debian12" {
  accelerator      = "kvm"
  boot_command     = [
    "<esc><wait>",
    "auto <wait>",
    "console-keymaps-at/keymap=us <wait>",
    "console-setup/ask_detect=false <wait>",
    "debconf/frontend=noninteractive <wait>",
    "debian-installer=en_US <wait>",
    "fb=false <wait>",
    "install <wait>",
    "kbd-chooser/method=us <wait>",
    "keyboard-configuration/xkb-keymap=us <wait>",
    "locale=en_US <wait>",
    "netcfg/get_hostname=${var.name}${var.version} <wait>",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/http/${var.config_file} <wait>",
    "<enter><wait>"
  ]
  boot_wait        = "15s"
  disk_cache       = "none"
  disk_compression = true
  disk_discard     = "unmap"
  disk_interface   = "virtio"
  disk_size        = var.disk_size
  format           = "qcow2"
  headless         = var.headless
  host_port_max    = 2229
  host_port_min    = 2222
  http_directory   = "."
  http_port_max    = 10089
  http_port_min    = 10082
  iso_checksum     = var.iso_checksum
  iso_url          = var.iso_url
  net_device       = "virtio-net"
  output_directory = "artifacts/qemu/${var.name}${var.version}"
  qemu_binary      = "/usr/bin/qemu-system-x86_64"
  qemuargs         = [
                       ["-m", "${var.ram}M"], ["-smp", "${var.cpu}"]
                     ]
  shutdown_command = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
  ssh_password     = var.ssh_password
  ssh_username     = var.ssh_username
  ssh_wait_timeout = "30m"
}

build {
  sources = ["source.qemu.debian12"]

  provisioner "file" {
    source = "sshkeys/id_rsa.pub"
    destination = "/tmp/vagrant_id_rsa.pub"
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    execute_command = "{{ .Vars }} bash '{{ .Path }}'"
    scripts = ["scripts/update.sh", "scripts/vagrant.sh"]
  }

  post-processor "vagrant" {
    keep_input_artifact = true
    output = "artifacts/box/debian12-vagrant.box"
  }
}
