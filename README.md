# Slate Vagrant
---

**Supported Operating Systems:** Linux / OSX

**Virtualization Support:** Virtualbox

The Slate Vagrant project spins up a single Virtualbox VM running CoreOS with base configuration provided by the
ignition config [`config.ign`](config.ign).  This config is generated in a multi stage process:
1. `config.rb` contains all the variables related to the Vagrant Image and Kubernetes Config itself.
2. Vagrant generates a Container Linux Config based off the Ruby Template `config.yaml.erb` with the variables stored 
in the `config.rb` `$kube_config` hash.
3. Vagrant renders the templates stored in the templates directory and copies them to the ignition directory
4. Non template files are copied from the files directory to the ignition directory.
5. The CoreOS Config Transpiler reads the Vagrant generated `config.yaml` and combines it with the files stored in the
ignition directory to generate the `config.ign` ignition config.

**Requirements**
* [Vagrant](https://www.vagrantup.com/downloads.html)
* [Virtual Box](https://www.virtualbox.org/wiki/Downloads)
* [CoreOS Config Transpiler](https://github.com/coreos/container-linux-config-transpiler)
* If enabling the data disk Make sure you have approximately 20GB hard disk free

**Requiremente**
Make sure you have approximately 20GB hard disk free.
Download and install the latest [Vagrant](https://www.vagrantup.com/downloads.html).
Download and install the latest [Docker for Mac](https://docs.docker.com/docker-for-mac/) or [Docker for Linux](https://runnable.com/docker/install-docker-on-linux).
Download and install the latest [Virtual Box](https://www.virtualbox.org/wiki/Downloads).

**Details**
If `$vagrant_share = true` (default), the project directory will be mounted to `/vagrant` within the VM via NFS. If
true Vagrant will ask for your password to modify exports. This is benign and expected.

The VM configuration can be changed by editing the parameters in the Vagrant file.

|       **Variable**      |                                                  **Default**                                                 |
|:-----------------------:|:------------------------------------------------------------------------------------------------------------:|
|     `num_instances`     |                                                      `1`                                                     |
|     `coreos_channel`    |                                                    `beta`                                                    |
|  `instance_name_prefix` |                                                    `slate`                                                   |
| `enable_serial_logging` |                                                    `false`                                                   |
|        `vm_vbox`        |                                          `coreos-#{$coreos_channel}`                                         |
|       `vm_box_url`      | `https://#{$coreos_channel}.release.core-os.net/amd64-usr/current/coreos_production_vagrant_virtualbox.json` |
|         `vm_gui`        |                                                    `false`                                                   |
|       `vm_memory`       |                                                    `4096`                                                    |
|         `vm_cpu`        |                                                      `2`                                                     |
|      `vm_ip_prefix`     |                                                  `10.255.34`                                                 |
|   `vb_cpuexecutioncap`  |                                                     `100`                                                    |
|     `vagrant_share`     |                                                    `false`                                                   |
|        `data_disk`      |                                                    `false`                                                   |
|    `data_disk_name`     |                                                  `data.vdi`                                                  |
|    `data_disk_size`     |                                                     `20`                                                     |


The Kubernetes Configuration is controlled via the `$kube_config` hash.

|    Variable Name   |          Config         |                                                   Description                                                   |
|:------------------:|:-----------------------:|:---------------------------------------------------------------------------------------------------------------:|
| `api_advertise_ip` |  `#{vm_ip_prefix}.101`  |                                         Kubernetes API Advertise Address                                        |
|  `cluster_dns_ip`  |     `10.255.200.10`     |                                        IP to use for cluster DNS service                                        |
|     `pod_cidr`     |    `10.255.100.0/22`    |                                                  Pod CIDR range                                                 |
|   `service_cidr`   |    `10.255.200.0/22`    |                                                Service CIDR range                                               |
| `external_ip_cidr` | `#{vm_ip_prefix}.32/27` |                     CIDR range to allocate for use with service type LoadBalancer (metalLB)                     |
|     `data_disk`    |       `$data_disk`      |                            Pass through from Vagrant config of `$data_disk` parameter                           |
|    `components`    |            -            | Hash of component items to be downloaded. Uses format `<name>: { url: '<url>', checksum: '<sha512 checksum>' }` |