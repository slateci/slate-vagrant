# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'
require 'erb'

def ct_present?
  # PATHEXT is windows, and contains the valid executable extensions (e.g. exe)
  # if windows, add the extensions to the list of things to check, otherwise skip
  # check if it exists in any of the valid paths
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each do |ext|
      exe = File.join(path, "ct#{ext}")
      return true if File.executable?(exe) && !File.directory?(exe)
    end
  end
  false
end

def render_erb_template(tmplt, dest, b)
  # short circuit return
  return unless File.exist?(tmplt)
  content = ERB.new(File.read(tmplt), nil, '-').result(b)
  File.open(dest, 'w') { |f| f.write(content) }
end

# Short circuit early if requirements are not satisifed
Vagrant.require_version '>= 1.6.0'
CWD = File.dirname(__FILE__)
CONFIG = File.join(CWD, 'config.rb')
IGNITION_CONFIG_TEMPLATE = File.join(CWD, 'config.yaml.erb')
IGNITION_CONFIG = File.join(CWD, 'config.yaml')
IGNITION_FILES_DIR = File.join(CWD, 'ignition')
RENDERED_IGNITION_CONFIG = File.join(CWD, 'config.ign')
required_plugins = %w(vagrant-ignition)
abort 'Config not Found. Cannot continue.' unless File.exist?(CONFIG)
abort 'Ignition Config Template not Found. Cannot continue.' unless File.exist?(IGNITION_CONFIG_TEMPLATE)
abort 'ct (config transpiler) not Found. Cannot continue.' unless ct_present?
plugins_to_install = required_plugins.select { |plugin| !Vagrant.has_plugin? plugin }
unless plugins_to_install.empty?
  puts "Installing plugins: #{plugins_to_install.join(' ')}"
  if system "vagrant plugin install #{plugins_to_install.join(' ')}"
    exec "vagrant #{ARGV.join(' ')}"
  else
    abort 'Installation of one or more plugins has failed. Aborting.'
  end
end

require CONFIG

b = binding
# load kube config into limited binding
$kube_config.each { |k, v| b.local_variable_set(k, v) }
render_erb_template(IGNITION_CONFIG_TEMPLATE, IGNITION_CONFIG, b)
Dir.glob(File.join(CWD, 'templates', '*.erb')).each do |src|
  dest = File.join(CWD, 'ignition', File.basename(src, File.extname(src)))
  render_erb_template(src, dest, b)
end

# copy files from 'files' to ignition
files_path = File.join(CWD, 'files')
Dir.entries(files_path).select { |f| !File.directory? f }.each do |f|
  FileUtils.cp(File.join(files_path, f), File.join(CWD, 'ignition', f))
end

# execute ct and render usable ignition config
system "ct -in-file #{IGNITION_CONFIG} -out-file #{RENDERED_IGNITION_CONFIG} -files-dir #{IGNITION_FILES_DIR} -pretty"

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
        vbox.customize ['modifyvm', :id, '--chipset', 'ICH9']
        vbox.customize ['modifyvm', :id, '--paravirtprovider', 'default']

        if $enable_serial_logging
          logdir = File.join(CWD, 'log')
          FileUtils.mkdir_p(logdir)

          serial_file = File.join(logdir, format('%s-serial.txt', vm_name))
          FileUtils.touch(serial_file)
          vbox.customize ['modifyvm', :id, '--uart1', '0x3F8', '4']
          vbox.customize ['modifyvm', :id, '--uartmode1', serial_file]
        end

        data_disk_path = File.join(CWD, $data_disk_name)
        if $data_disk && !File.exist?(data_disk_path)
          vbox.customize ['createhd', '--filename', data_disk_path, '--variant', 'Fixed',
                          '--size', $data_disk_size * 1024]
          # Adding a SATA controller that allows 4 hard drives
          vbox.customize ['storagectl', :id, '--name', 'SATA Controller', '--add', 'sata', '--portcount', 4]
          vbox.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0,
                          '--type', 'hdd', '--medium', data_disk_path]
        end
        cfg.ignition.config_obj = vbox
      end

      ip = "#{$vm_ip_prefix}.#{i + 100}"
      cfg.ignition.ip = "#{ip}/24"
      cfg.ignition.hostname = vm_name
      cfg.ignition.drive_name = 'config' + i.to_s
      cfg.ignition.path = 'config.ign' if File.exist?(RENDERED_IGNITION_CONFIG)
      cfg.vm.network :private_network, ip: ip, virtualbox__hostonly: 'vboxnet8'
      cfg.vm.synced_folder '.', '/vagrant', id: 'core', nfs: true, mount_options: ['nolock,vers=3,udp'] if $vagrant_share
    end
  end
end
