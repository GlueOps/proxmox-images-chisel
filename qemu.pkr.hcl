variable "image_password" {
  type = string
}

variable "chisel_image" {
  type = string
  # renovate: datasource=docker depName=docker.io/jpillora/chisel
  default = "docker.io/jpillora/chisel:1.11.8@sha256:51d034146bb06e03a493646e63e61d42fd3b5da914c7180c92ba603865768633"
}

source "qemu" "qemu-amd64" {
  accelerator      = "kvm"
  iso_url          = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
  iso_checksum     = "file:https://cloud.debian.org/images/cloud/trixie/latest/SHA512SUMS"
  disk_image       = true
  output_directory = "images"
  # Keep the virtual disk small: tools-api grows it to the Waggle slot's disk_gb
  # at provision time, and Proxmox can't shrink — so this must stay below any slot.
  disk_size        = "4096M"
  format           = "qcow2"
  vm_name          = "debian-13-chisel-amd64.qcow2"
  ssh_username     = "debian"
  ssh_password     = "${var.image_password}"
  shutdown_command = "sudo fstrim -av && sudo shutdown -P now"
  headless         = true
  ssh_wait_timeout = "15m"
  vnc_port_min     = 5901
  vnc_port_max     = 5901
  cd_files         = ["user-data", "meta-data"]
  cd_label         = "cidata"
  qemuargs = [
    ["-m", "2048M"],
    ["-smp", "2"]
  ]
}

build {
  sources = ["source.qemu.qemu-amd64"]

  provisioner "shell" {
    inline = [
      "cloud-init status --wait || true",

      # Bake in everything a chisel exit node needs at boot
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y qemu-guest-agent docker.io",
      "sudo systemctl enable qemu-guest-agent docker",
      "sudo docker pull ${var.chisel_image}",
      # A digest pull doesn't create the floating tag consumers reference in
      # their `docker run` (tools-api uses docker.io/jpillora/chisel:1) — tag it
      # so the preloaded image is actually used instead of re-pulled at boot.
      "sudo docker tag ${var.chisel_image} docker.io/jpillora/chisel:1",

      # Clean up apt
      "sudo apt-get -y autoremove",
      "sudo apt-get -y clean",
      "sudo rm -rf /var/lib/apt/lists/*",

      # Clear logs
      "sudo find /var/log -type f -name '*.log' -delete",

      # Reset instance identity so every Proxmox clone provisions fresh:
      # cloud-init reruns against the NoCloud ISO tools-api attaches, ssh host
      # keys regenerate, machine-id regenerates (unique DHCP identity), and the
      # build-time password can't be used against deployed VMs.
      "sudo passwd -l debian",
      "sudo rm -f /etc/ssh/ssh_host_*",
      "sudo cloud-init clean --logs --seed",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo rm -f /var/lib/dbus/machine-id"
    ]
  }

  post-processor "shell-local" {
    inline = [
      "qemu-img convert -O qcow2 -c images/debian-13-chisel-amd64.qcow2 images/debian-13-chisel-amd64-compressed.qcow2",
      "rm user-data",
      "rm meta-data",
      "rm images/debian-13-chisel-amd64.qcow2",
      "mv images/debian-13-chisel-amd64-compressed.qcow2 images/debian-13-chisel-amd64.qcow2"
    ]
  }
}

packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "1.1.0"
    }
  }
}
