# proxmox-images-chisel

Prebuilt Proxmox VM image for GlueOps chisel exit nodes (the load balancers behind `tools-api`'s `/v1/k3d-lb-nodes` endpoint for dev/k3d clusters).

Compared to provisioning on a stock Debian cloud image (apt update + install qemu-guest-agent + install docker on every boot, ~2–4 minutes), this image bakes everything in so a new exit node reports its IP and serves chisel within seconds of booting.

## What's in the image

- Base: `debian-13-genericcloud-amd64` (trixie/latest at build time, checksum-verified)
- `qemu-guest-agent` — installed and enabled (IP discovery works as soon as the VM boots)
- Docker engine (`docker.io`) — installed and enabled
- `docker.io/jpillora/chisel:1` — pre-pulled into docker's image store (no registry pull at provision time)
- `/etc/machine-id` cleared, so every clone gets a unique identity and DHCP lease

The image is intentionally small (single GitHub release asset, well under the 2 GiB per-asset limit) — no splitting/reassembly needed, unlike larger image pipelines.

## Consuming from tools-api

```bash
PROXMOX_DOWNLOAD_SERVER_URL=https://github.com/GlueOps/proxmox-images-chisel/releases/latest/download
K3D_LB_VM_IMAGE=debian-13-chisel-amd64
```

The Proxmox node downloads `<base>/<image>.qcow2` itself (via its `download-url` API, which follows GitHub's redirect to the release asset), so nodes need HTTPS egress to github.com. `SHA256SUMS` is published alongside each release.

With this image, the cloud-init user-data only needs to run the chisel container — no package installs:

```yaml
#cloud-config
runcmd:
  - docker run -d --restart always -p 9090:9090 -p 443:443 -p 80:80 docker.io/jpillora/chisel:1 server --reverse --port=9090 --auth='<user>:<pass>'
```

## Building

`.github/workflows/build_image.yaml` builds and releases the image:

- **Weekly** (Monday 06:00 UTC) — picks up Debian point releases and security updates
- **Manually** — `gh workflow run build_image.yaml` (optional input: `chisel_image` to preload a different chisel image)

Build-time instance identity is fully reset (cloud-init clean, ssh host keys removed, machine-id cleared, build password locked), so every Proxmox clone provisions fresh against the NoCloud ISO tools-api attaches.

Each run creates a date-tagged release (`vYYYY.MM.DD.HHMM`) marked as latest, so the `releases/latest/download` URL always serves the newest image while older releases remain available for rollback (repoint by downloading a specific tag's asset to your own mirror if you need to pin).

The build uses packer's QEMU builder on a stock GitHub runner (KVM-accelerated), mirroring [glueops/codespaces](https://github.com/glueops/codespaces)'s image pipeline minus the S3 upload and multi-part release splitting — this image fits in a single release asset.
