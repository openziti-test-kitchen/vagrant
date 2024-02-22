
Use this Vagrant box as-is with the `vagrant-libvirt` plugin on Linux to build ziti-sdk-c with a modified tlsuv on
FreeBSD 14.0.

macOS or Windows users could use the Virtualbox provider with minor modifications to the Vagrantfile.

1. Adjust the paths in [Vagrantfile](Vagrantfile) to match your local environment, i.e., the filesystem paths to ziti-sdk-c and tlsuv (`config.vm.synced_folder`).
1. In the ziti-sdk-c project, check out branch `freebsd-preset`.
1. In the tlsuv project, check out branch `freebsd-compression`.
1. Install Ansible on your host machine, i.e., `pip install ansible`.
1. In this directory, run `vagrant up`.
1. After the VM is up, run `vagrant rsync-auto` to continually rsync your ziti-sdk-c and tlsuv checkouts to the VM.
1. In the VM, run:

    ```sh
    export VCPKG_ROOT=~/vcpkg
    BUILD=~/ziti-sdk-c/build
    rm -rf $BUILD
    mkdir $BUILD
    cd $BUILD
    cmake --preset ci-freebsd-x64 -Dtlsuv_DIR=${HOME}/tlsuv ..
    cmake --build .
    ```
