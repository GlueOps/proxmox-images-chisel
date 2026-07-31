# Changelog

## 0.1.0 (2026-07-31)


### Features

* adopt semver via release-please; attach image assets to semver releases ([#5](https://github.com/GlueOps/proxmox-images-chisel/issues/5)) ([cec04d5](https://github.com/GlueOps/proxmox-images-chisel/commit/cec04d5b8dece23a9f1719b3fd2dd0a3a51be6e2))
* build and release minimal debian-13 chisel image ([#1](https://github.com/GlueOps/proxmox-images-chisel/issues/1)) ([9a070b8](https://github.com/GlueOps/proxmox-images-chisel/commit/9a070b86067ece92588813956197f8b60be60718))
* switch to packer qemu build mirroring glueops/codespaces ([#4](https://github.com/GlueOps/proxmox-images-chisel/issues/4)) ([5ff7faf](https://github.com/GlueOps/proxmox-images-chisel/commit/5ff7faf60cf7e7b77e4358fc069c6f500726fe76))


### Bug Fixes

* align release-please config with glueops/codespaces ([#7](https://github.com/GlueOps/proxmox-images-chisel/issues/7)) ([a1c3d41](https://github.com/GlueOps/proxmox-images-chisel/commit/a1c3d4162c434170935540c41a575ada3375c90d))
* run libguestfs unprivileged — passt refuses to run as root ([#2](https://github.com/GlueOps/proxmox-images-chisel/issues/2)) ([1587f04](https://github.com/GlueOps/proxmox-images-chisel/commit/1587f04d74abf318510eb411fdd6f4f82c8a758e))
* work around passt failures on ubuntu-24.04 runners ([#3](https://github.com/GlueOps/proxmox-images-chisel/issues/3)) ([e60f57c](https://github.com/GlueOps/proxmox-images-chisel/commit/e60f57c56225f0085c7cdd002bc46d1f06ac9adf))
