# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

Vagrant.require_version '>= 1.6.0'
CONFIG = File.join(File.dirname(__FILE__), 'config.rb')
if File.exist?(CONFIG)
  require CONFIG
else
  abort 'Config not Found. Cannot continue.'
end
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
DATA_DISK_PATH = File.join(File.dirname(__FILE__), $data_disk_name)

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

      cfg.vm.provider :virtualbox do |vbox|
        vbox.gui = $vm_gui
        vbox.memory = $vm_memory
        vbox.cpus = $vm_cpus
        vbox.check_guest_additions = false
        vbox.functional_vboxsf     = false
        vbox.customize ['modifyvm', :id, '--cpuexecutioncap', $vb_cpuexecutioncap.to_s]

        if $enable_serial_logging
          logdir = File.join(File.dirname(__FILE__), 'log')
          FileUtils.mkdir_p(logdir)

          serial_file = File.join(logdir, format('%s-serial.txt', vm_name))
          FileUtils.touch(serial_file)
          vbox.customize ['modifyvm', :id, '--uart1', '0x3F8', '4']
          vbox.customize ['modifyvm', :id, '--uartmode1', serial_file]
        end

        if $data_disk && !File.exist?(DATA_DISK_PATH)
          vbox.customize ['createhd', '--filename', DATA_DISK_PATH, '--variant', 'Fixed',
                          '--size', $data_disk_size * 1024]
          # Adding a SATA controller that allows 4 hard drives
          vbox.customize ['storagectl', :id, '--name', 'SATA Controller', '--add', 'sata', '--portcount', 4]
          vbox.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0,
                          '--type', 'hdd', '--medium', DATA_DISK_PATH]
        end
        cfg.ignition.config_obj = vbox
      end

      ip = "#{$vm_ip_prefix}.#{i + 100}"
      cfg.ignition.ip = "#{ip}/24"
      cfg.ignition.hostname = vm_name
      cfg.ignition.drive_name = 'config' + i.to_s
      cfg.ignition.path = 'config.ign' if File.exist?(IGNITION_CONFIG_PATH)

      if $vagrant_share
        cfg.vm.synced_folder '.', '/vagrant', id: 'core', nfs: true, mount_options: ['nolock,vers=3,udp']
      end
      cfg.vm.provision 'file', source: FILES_DIR_PATH, destination: '/tmp/files'
      cfg.vm.provision 'shell', inline: "mv /tmp/files #{$files_dest_dir}", privileged: true
      Dir.entries(SCRIPTS_DIR_PATH).select { |f| !File.directory? f }.sort_by { |f| File.path(f) } .each do |script|
        cfg.vm.provision 'shell', path: File.join(SCRIPTS_DIR_PATH, script), env: $script_env, privileged: true
      end
    end
  end
end
