#!/bin/sh

# Store build time
date > /etc/vagrant_box_build_time

# Set up sudo
echo 'vagrant ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vagrant

# Install vagrant key
mkdir -pm 700 /home/vagrant/.ssh
cat /tmp/vagrant_id_rsa.pub > /home/vagrant/.ssh/authorized_keys && rm /tmp/vagrant_id_rsa.pub
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# NFS used for file syncing
apt-get install --yes --no-install-recommends nfs-common
