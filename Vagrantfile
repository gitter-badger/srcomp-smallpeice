VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu-14.04-server"
  config.vm.box_url = "https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-14.04-amd64-vbox.box"
  config.vm.hostname = "srcomp"

  config.vm.provision "puppet" do |puppet|
    puppet.module_path = "modules"
  end

  config.vm.synced_folder "files/", "/etc/boxconf"
end

