# Hec's Arch Linux Bootc Builds

[![Build container image](https://github.com/hecknt/arch-bootc-testing/actions/workflows/build.yaml/badge.svg)](https://github.com/hecknt/arch-bootc-testing/actions/workflows/build.yaml)

These are experimental builds of [Arch Linux](https://archlinux.org) built on top of [bootc](https://github.com/bootc-dev/bootc) for an atomic base. These builds should not currently be used, as they are experimental, and rapidly changing in whatever direction I feel like taking it that day.

## Building

In order to get a running arch-bootc system you can run the following steps:
```shell
just build-containerfile # This will build the containerfile and all the dependencies you need
just generate-bootable-image # Generates a bootable image for you using bootc!
```

Then you can run the `bootable.img` as your boot disk in your preferred hypervisor.

> [!WARNING]
> Builds from this repository are not tested against the ostree backend. Any weirdness that may come from rebasing from Fedora is entirely on YOU to figure out. 
>
> Fedora Atomic uses the ostree. This image is tested against the (currently experimental) [composefs backend](https://bootc-dev.github.io/bootc/experimental-composefs.html). Along with this fact, certain images (i.e any Universal Blue image such as [Bazzite](https://bazzite.gg)) will break upon rebase for unrelated reasons.
>
> If you don't know what you're doing, <ins>**don't install this image.**</ins> You are likely better off with fedora based image such as [Zirconium](https://github.com/zirconium-dev/zirconium) if you want to use niri.

Alternatively, you can install a Fedora Atomic (or any other bootc-based) system, and then switch to an image built by this repo using the following command:
```shell
sudo bootc switch ghcr.io/hecknt/arch-bootc-testing:latest
```
