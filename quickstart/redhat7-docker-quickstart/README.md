
# Run Ziti Controller in Docker on CentOS 7 with Vagrant

## Prerequisites

* [Vagrant](https://www.vagrantup.com/downloads.html)
* [libvirt](https://libvirt.org/)
  * [vagrant-libvirt](https://vagrant-libvirt.github.io/vagrant-libvirt/)
  * [vagrant-reload](https://github.com/aidanns/vagrant-reload)
* [ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

## Usage

```bash
vagrant up --provider=libvirt
```

## Login and Run a Command

```bash
vagrant ssh -- docker logs ziti-controller       
```

## Inspect the Controller's Certificate

```bash
$ virsh net-dhcp-leases --network vagrant-libvirt 
 Expiry Time           MAC address         Protocol   IP address           Hostname   Client ID or DUID
---------------------------------------------------------------------------------------------------------
 2023-03-30 12:15:23   52:54:00:d4:1d:13   ipv4       192.168.121.125/24   -          -

$ cfssl certinfo -domain 192.168.121.125:1280 | jq .sans
[
  "ziti-controller",
  "localhost",
  "ziti",
  "ziti-edge-controller",
  "127.0.0.1"
]
```
