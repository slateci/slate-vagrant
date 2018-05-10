# Slate Vagrant
---

**Supported Operating Systems:** Linux / OSX

**Virtualization Support:** Virtualbox

The Slate Vagrant project spins up a single Virtualbox VM running CoreOS with base configuration provided by the
ignition config [`config.ign`](config.ign).  Once booted, Vagrant will copy over all files within the [`files`](files)
directory to `/opt/files` in the VM and then execute the scripts found in the [`scripts`](scripts) directory in order.
The last script to be executed will echo the `kubeconfig` to the console and copy it to `/vagrant/$HOSTNAME.kconfig`
assuming the `/vagrant` share is mounted.

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
|     `vagrant_share`     |                                                    `true`                                                    |
|     `files_dest_dir`    |                                                  `opt/files`                                                 |
|     `slate_ephemeral`   |                                                    `true`                                                    |
| `slate_ephemeral_size`  |                                                     `50`                                                     |
