# Hec's Arch Linux Bootc Builds

[![Build container image](https://github.com/hecknt/arch-bootc-testing/actions/workflows/build.yaml/badge.svg)](https://github.com/hecknt/arch-bootc-testing/actions/workflows/build.yaml)

These are experimental builds of [Arch Linux](https://archlinux.org) built for [bootc](https://github.com/bootc-dev/bootc) usage. They are currently very barebones and should not be used outside of testing and experimentation.

## Building

In order to get a running arch-bootc system you can run the following steps:
```shell
just build-containerfile # This will build the containerfile and all the dependencies you need
just generate-bootable-image # Generates a bootable image for you using bootc!
```

Then you can run the `bootable.img` as your boot disk in your preferred hypervisor.

Alternatively, you can install a Fedora Atomic (or any other bootc-based) system, and then switch to an image built by this repo using the following command:
```shell
sudo bootc switch ghcr.io/hecknt/arch-bootc-testing:latest
```
