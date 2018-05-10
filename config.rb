# -*- mode: ruby -*-
# # vi: set ft=ruby :

$num_instances = 1
$coreos_channel = 'beta'
$instance_name_prefix = 'slate'
$enable_serial_logging = false
$vm_box = "coreos-#{$coreos_channel}"
$vm_box_url = "https://#{$coreos_channel}.release.core-os.net/amd64-usr/current/coreos_production_vagrant_virtualbox.json"
$vm_gui = false
$vm_memory = 4096
$vm_cpus = 2
$vm_ip_prefix = '10.255.34'
$vb_cpuexecutioncap = 100
$vagrant_share = false
$files_dest_dir = '/opt/files'
$data_disk = true
$data_disk_name = 'data.vdi'
$data_disk_size = 50
$cni_version = 'v0.6.0'
$k8s_release = 'v1.10.2'
$cfssl_release = 'R1.2'
$cri_tools_release = 'v1.0.0-beta.0'

$script_env = {
  FILES_DEST_DIR: $files_dest_dir,
  CNI_VERSION: $cni_version,
  K8S_RELEASE: $k8s_release,
  CFSSL_RELEASE: $cfssl_release,
  CRI_TOOLS_RELEASE: $cri_tools_release
}
