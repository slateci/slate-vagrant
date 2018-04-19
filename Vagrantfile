# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

Vagrant.require_version '>= 1.6.0'

# Make sure the vagrant-ignition plugin is installed
required_plugins = %w(vagrant-ignition)

plugins_to_install = required_plugins.select { |plugin| !Vagrant.has_plugin? plugin }
unless plugins_to_install.empty?
  puts "Installing plugins: #{plugins_to_install.join(' ')}"
  if system "vagrant plugin install #{plugins_to_install.join(' ')}"
    exec "vagrant #{ARGV.join(' ')}"
  else
    abort 'Installation of one or more plugins has failed. Aborting.'
  end
end

IGNITION_CONFIG_PATH = File.join(File.dirname(__FILE__), 'config.ign')
FILES_DIR_PATH = File.join(File.dirname(__FILE__), 'files')
SCRIPTS_DIR_PATH = File.join(File.dirname(__FILE__), 'scripts')

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
$vagrant_share = true
$files_dest_dir = '/opt/files'

Vagrant.configure('2') do |config|
  config.vbguest.auto_update = false if Vagrant.has_plugin?('vagrant-vbguest')
  config.ssh.insert_key = false
  config.ssh.forward_agent = true

  (1..$num_instances).each do |i|
    config.vm.define vm_name = format('%s-%02d', $instance_name_prefix, i) do |cfg|
      cfg.vm.hostname = vm_name
      cfg.vm.box = $vm_box
      cfg.vm.box_url = $vm_box_url
      cfg.ignition.enabled = true

      if $enable_serial_logging
        logdir = File.join(File.dirname(__FILE__), 'log')
        FileUtils.mkdir_p(logdir)

        serial_file = File.join(logdir, format('%s-serial.txt', vm_name))
        FileUtils.touch(serial_file)

        cfg.vm.provider :virtualbox do |vbox|
          vbox.customize ['modifyvm', :id, '--uart1', '0x3F8', '4']
          vbox.customize ['modifyvm', :id, '--uartmode1', serial_file]
        end
      end

      cfg.vm.provider :virtualbox do |vbox|
        vbox.gui = $vm_gui
        vbox.memory = $vm_memory
        vbox.cpus = $vm_cpus
        vbox.check_guest_additions = false
        vbox.functional_vboxsf     = false
        vbox.customize ['modifyvm', :id, '--cpuexecutioncap', $vb_cpuexecutioncap.to_s]
        cfg.ignition.config_obj = vbox
      end

      ip = "#{$vm_ip_prefix}.#{i + 100}"
      cfg.vm.network :private_network, ip: ip
      cfg.ignition.ip = ip
      cfg.ignition.hostname = vm_name
      cfg.ignition.drive_name = 'config' + i.to_s
      cfg.ignition.path = 'config.ign' if File.exist?(IGNITION_CONFIG_PATH)

      if $vagrant_share
        cfg.vm.synced_folder '.', '/vagrant', id: 'core', nfs: true, mount_options: ['nolock,vers=3,udp']
      end
      cfg.vm.provision 'file', source: FILES_DIR_PATH, destination: '/tmp/files'
      cfg.vm.provision 'shell', inline: "mv /tmp/files #{$files_dest_dir}", privileged: true
      Dir.entries(SCRIPTS_DIR_PATH).select { |f| !File.directory? f }.sort_by { |f| File.path(f) } .each do |script|
        cfg.vm.provision 'shell', path: File.join(SCRIPTS_DIR_PATH, script), privileged: true
      end
    end
  end
end
