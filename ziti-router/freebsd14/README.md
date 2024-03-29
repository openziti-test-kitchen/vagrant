
Use this Vagrant box as-is with the `vagrant-libvirt` plugin on Linux to build and run a ziti router with Go on FreeBSD 14.0.

macOS or Windows users could use the Virtualbox provider with minor modifications to the Vagrantfile.

The provisioning playbook looks for a router enrollment token in the Ansible controller's filesystem at `/tmp/router1.jwt`. Adjust that path and controller's ctrl endpoint address and port to match your development environment.

1. Install Ansible on your host machine, i.e., `pip install ansible`.
1. In this directory, run `vagrant up`.
1. In the VM, run:

    ```sh
    ~/ziti/build/ziti router run /tmp/ziti-router/config.yml
    ```

## Iterative Development with local ziti checkout

1. In a Unix shell, `export ZITI_SOURCE` and assign the filesystem path that contains related OpenZiti projects, e.g.,
  `export ZITI_SOURCE=~/openziti_source`. The source directory must contain and checkouts you wish to rsync to the Vagrant
  box.
1. In the ziti project, check out branch `freebsd`.
1. run `vagrant reload` to restart the VM with the new environment variable set to sync the ziti source to the VM.
1. After the VM is up, run `vagrant rsync` for a one-time sync, or `vagrant rsync-auto` to continually rsync your source checkouts to the VM. Each sync will delete the build directory on the VM.
