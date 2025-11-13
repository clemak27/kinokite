#!/bin/bash

set -ouex pipefail

# copy system files into root

rsync -rvK /ctx/sys_files/ /

# disable unused registries

sudo sed -i 's/enabled=1/enabled=0/' \
  /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:phracek:PyCharm.repo \
  /etc/yum.repos.d/fedora-cisco-openh264.repo \
  /etc/yum.repos.d/google-chrome.repo \
  /etc/yum.repos.d/rpmfusion-nonfree-nvidia-driver.repo \
  /etc/yum.repos.d/rpmfusion-nonfree-steam.repo

RELEASE=$(rpm -E %fedora)

dnf -y install \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$RELEASE.noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$RELEASE.noarch.rpm"

# packages

dnf -y remove \
  firefox \
  firefox-langpacks \
  toolbox

dnf -y install \
  distrobox \
  gcc-c++ \
  kontact \
  ksshaskpass \
  openrgb-udev-rules \
  podman-compose \
  podman-docker \
  steam-devices \
  vim \
  wl-clipboard \
  zsh

# flatpak

mkdir -p /etc/flatpak/remotes.d/
curl --retry 3 -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo
mv -f /usr/lib/systemd/system/enable-flathub.service /usr/lib/systemd/system/flatpak-add-fedora-repos.service

# podman

mkdir -p /etc/containers
touch /etc/containers/nodocker

systemctl enable podman.socket

# change default shell

sed -i 's@/bin/bash@/bin/zsh@g' /etc/default/useradd

# signed image

mkdir -p /etc/pki/containers
cp /ctx/cosign.pub /etc/pki/containers/clemak27.pub

restorecon -RFv /etc/pki/containers
restorecon -RFv /etc/containers
