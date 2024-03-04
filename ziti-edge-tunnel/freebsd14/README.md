
Use this Vagrant box as-is with the `vagrant-libvirt` plugin on Linux to build ziti-sdk-c with the FreeBSD ports of
tlsuv and ziti (Go).

macOS or Windows users could use the Virtualbox provider with minor modifications to the Vagrantfile.

1. In a Unix shell, `export ZITI_SOURCE` and assign the filesystem path that contains related OpenZiti projects, e.g.,
   `export ZITI_SOURCE=~/openziti_source`. The source directory must contain and checkouts you wish to rsync to the Vagrant
   box.
1. In the ziti-sdk-c project, check out branch `freebsd`.
1. In the tlsuv project, check out branch `freebsd`.
1. In the ziti project, check out branch `freebsd` if you wish to iterate inside the VM. CMake will clone this branch
   during the integration test phase of the build.
1. Install Ansible on your host machine, i.e., `pip install ansible`.
1. In this directory, run `vagrant up`.
1. After the VM is up, run `vagrant rsync` for a one-time sync, or `vagrant rsync-auto` to continually rsync your source
   checkouts to the VM. Each sync will delete the build directory on the VM.
1. In the VM, run:

    ```bash
    export VCPKG_ROOT=~/vcpkg
    BUILD=~/ziti-sdk-c/build
    rm -rf $BUILD
    mkdir $BUILD
    cd $BUILD
    cmake --preset ci-freebsd-x64 -DZITI_CLI_VER=freebsd -Dtlsuv_DIR=${HOME}/tlsuv ..
    cmake --build .
    ```
