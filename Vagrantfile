# -*- mode: ruby -*-
# vi: set ft=ruby :

# Require YAML module
require 'yaml'
# require 'getoptlong'
require 'fileutils'
require 'shellwords'

class String
    def black;          "\e[30m#{self}\e[0m" end
    def red;            "\e[31m#{self}\e[0m" end
    def cyan;           "\e[36m#{self}\e[0m" end
end

config = YAML.load_file(File.join(File.dirname(__FILE__), 'config.yml'))

base_box=config['environment']['base_box']





manager_ip=config['environment']['manager_ip']

domain=config['environment']['domain']

boxes = config['boxes']

boxes_hostsfile_entries=""

# Configuration 
$rexray_cfg = "/etc/rexray/config.yml"
$volume_path = "#{File.dirname(__FILE__)}/.vagrant/volumes"
FileUtils::mkdir_p $volume_path
#$write_rexray_config_manager = <<SCRIPT
# 10.0.2.2 is the virtual ip for virtualbox host using vagrant
$write_rexray_config = <<SCRIPT
mkdir -p #{File.dirname($rexray_cfg).shellescape}
cat << EOF > #{$rexray_cfg.shellescape}
rexray:
  logLevel: warn
libstorage:
  service: virtualbox
  integration:
    volume:
      operations:
        mount:
          preempt: true
virtualbox:
  volumePath: #{$volume_path}
  endpoint: http://10.0.2.2:18083
  controllerName: SATA
EOF
SCRIPT

########

boxes.each do |box|
  boxes_hostsfile_entries=boxes_hostsfile_entries+box['mgmt_ip'] + ' ' +  box['name'] + ' ' + box['name']+'.'+domain+'\n'
end

#puts boxes_hostsfile_entries

update_hosts = <<SCRIPT
    echo "127.0.0.1 localhost" >/etc/hosts
    echo -e "#{boxes_hostsfile_entries}" |tee -a /etc/hosts
SCRIPT

$install_ceph_repo = <<SCRIPT
    wget -q -O- 'https://download.ceph.com/keys/release.asc' | apt-key add -
    echo deb http://download.ceph.com/debian-jewel/ $(lsb_release -sc) main | tee /etc/apt/sources.list.d/ceph.list
    apt-get update && apt-get install -y ceph-deploy
SCRIPT

$create_cephadm_user = <<SCRIPT
    useradd -d /home/cephadm -m cephadm -s /bin/bash
    echo "cephadm:changeme"|chpasswd
    echo "cephadm ALL = (root) NOPASSWD:ALL" >>/etc/sudoers
    [ ! -f /tmp_deploying_stage/id_rsa ] && ssh-keygen  -t rsa -P "" -f /tmp_deploying_stage/id_rsa
    mkdir -p /home/cephadm/.ssh &&  cp /tmp_deploying_stage/id_rsa* /home/cephadm/.ssh/
    cat /home/cephadm/.ssh/id_rsa.pub > /home/cephadm/.ssh/authorized_keys
    chown -R cephadm:cephadm /home/cephadm/.ssh/ && chmod 600 /home/cephadm/.ssh/*

SCRIPT

update_global_ssh_config =<<SCRIPT
    echo -e "\tStrictHostKeyChecking no\n\tUserKnownHostsFile=/dev/null" >> /etc/ssh/ssh_config

SCRIPT

Vagrant.configure(2) do |config|
  if Vagrant.has_plugin?("vagrant-proxyconf")
    if proxy != ''
        puts " Using proxy"
        config.proxy.http = proxy
        config.proxy.https = proxy
        config.proxy.no_proxy = "localhost,127.0.0.1"
    end
  end
  config.vm.box = base_box

  config.vm.synced_folder "tmp_deploying_stage/", "/tmp_deploying_stage",create:true
  #config.vm.synced_folder "src/", "/src",create:true
  boxes.each do |node|
    config.vm.define node['name'] do |config|
      config.vm.hostname = node['name']
      file_to_disk = './tmp_disks/data_'+node['name']+'.vdi'
      config.vm.provider "virtualbox" do |v|
        v.name = node['name']
        v.customize ["modifyvm", :id, "--memory", node['mem']]
        v.customize ["modifyvm", :id, "--cpus", node['cpu']]

	    v.customize ["modifyvm", :id, "--macaddress1", "auto"]

        v.customize ["modifyvm", :id, "--nictype1", "Am79C973"]
        v.customize ["modifyvm", :id, "--nictype2", "Am79C973"]
        v.customize ["modifyvm", :id, "--nictype3", "Am79C973"]
        v.customize ["modifyvm", :id, "--nictype4", "Am79C973"]
        v.customize ["modifyvm", :id, "--nicpromisc1", "allow-all"]
        v.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
        v.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
        v.customize ["modifyvm", :id, "--nicpromisc4", "allow-all"]
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        unless File.exist?(file_to_disk)
            v.customize ['createhd', '--filename', file_to_disk, '--size', 500 * 1024]
        end
        #v.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
        v.customize ['storageattach', :id, '--storagectl', 'SATA', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]

      end

      config.vm.network "private_network",
      ip: node['mgmt_ip'],
      virtualbox__intnet: "CEPH"


      #config.vm.network "forwarded_port", guest: 8080, host: 8080, auto_correct: true

      config.vm.network "public_network",
      bridge: ["enp4s0","wlp3s0","enp3s0f1","wlp2s0"],
      auto_config: true


      config.vm.provision "shell", inline: <<-SHELL
        apt-get update -qq && apt-get install -qq chrony curl && timedatectl set-timezone Europe/Madrid
        rpl "allow 1" "#allow 1" /etc/chrony/chrony.conf
        systemctl restart chrony
      SHELL

      config.vm.provision :shell, :inline => update_hosts

      config.vm.provision "shell" do |s|
       			s.name       = "Install Ceph Repo"
        		s.inline     = $install_ceph_repo
      end

      config.vm.provision "shell" do |s|
              s.name       = "Create Ceph Admin"
              s.inline     = $create_cephadm_user
      end

      config.vm.provision :shell, :inline => update_global_ssh_config

        #config.vm.provision "shell" do |s|
        #  s.name   = "Start rex-ray"
        #  s.inline = "sudo systemctl start rexray"
        #end

        #config.vm.provision "shell" do |s|
        #  s.name   = "Restart Docker Engine"
        #  s.inline = "sudo systemctl restart docker"
        #end

    end
  end

end
