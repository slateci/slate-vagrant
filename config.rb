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
$data_disk = false
$data_disk_name = 'data.vdi'
$data_disk_size = 20

$kube_config = {
  api_advertise_ip: "#{$vm_ip_prefix}.101",
  cluster_dns_ip: '10.255.200.10',
  pod_cidr: '10.255.100.0/22',
  service_cidr: '10.255.200.0/22',
  external_ip_cidr: "#{$vm_ip_prefix}.32/27",
  data_disk: $data_disk,
  components: {
    kubeadm: {
      url: 'https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/linux/amd64/kubeadm',
      checksum: 'fc96e821fd593a212c632a6c9093143fab5817f6833ba1df1ced2ce4fb82f1ebefde71d9a898e8f9574515e9ba19e40f6ab09a907f6b1b908d7adfcf57b3bf8b'
    },
    kubelet: {
      url: 'https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/linux/amd64/kubelet',
      checksum: '5cf4bde886d832d1cc48c47aeb43768050f67fe0458a330e4702b8071567665c975ed1fe2296cba5aea95a6de0bec4b731a32525837cac24646fb0158e2c2f64'
    },
    kubectl: {
      url: 'https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/linux/amd64/kubectl',
      checksum: '38a2746ac7b87cf7969cf33ccac177e63a6a0020ac593b7d272d751889ab568ad46a60e436d2f44f3654e2b4b5b196eabf8860b3eb87368f0861e2b3eb545a80'
    },
    cni_plugins: {
      url: 'https://github.com/containernetworking/plugins/releases/download/v0.6.0/cni-plugins-amd64-v0.6.0.tgz',
      checksum: '398afcb1bdac39b3c5113ef6e114b887827a3600a227cd5cef7d36eaea397670520f35b221907490ad78af81049629a321816ce834318749ef7e75d2ab12a5c4'
    },
    crictl: {
      url: 'https://github.com/kubernetes-incubator/cri-tools/releases/download/v1.0.0-beta.1/crictl-v1.0.0-beta.1-linux-amd64.tar.gz',
      checksum: '0fb86549b6a9d17b7c4fdf69586edbea207a4e7885e034ffc73f453dc2df8912562a1d2f173b84388debd94c04127f0e12df65a12a4cba13e9db8807e1522ef1'
    },
    cfssl: {
      url: 'https://pkg.cfssl.org/R1.2/cfssl_linux-amd64',
      checksum: '344d58d43aa3948c78eb7e7dafe493c3409f98c73f27cae041c24a7bd14aff07c702d8ab6cdfb15bd6cc55c18b2552f86c5f79a6778f0c277b5e9798d3a38e37'
    },
    cfssljson: {
      url: 'https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64',
      checksum: 'b80f19e61e16244422ad3d877e5a7df5c46b34181d264c9c529db8a8fc2999c6a6f7c1fb2dec63e08d311d6657c8fe05af3186b7ff369a866a47d140d393b49b'
    }
  }
}
