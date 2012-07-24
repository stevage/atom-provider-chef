Vagrant::Config.run do |config|
  config.vm.box = "lucid32up"  
  config.vm.boot_mode = :gui
  config.vm.network :hostonly, "192.168.2.205"
  config.vm.customize ["modifyvm", :id, "--rtcuseutc", "on"]
  config.vm.share_folder "data", "/mnt/data", "data"
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ["cookbooks"]
    chef.add_recipe "dataset-provider"
  end
end
