
include_recipe "atom-dataset-provider::deps"

ohai "reload_passwd" do
  action :nothing
  plugin "passwd"
end

bash "set timezone" do
  # It's pretty important that the dataset provider has the right time, as consumers rely on it to know if data is new.
  # Obviously this should be configurable.
  # If timezone not set to any Australian tz, make it Melbourne.
  code <<-EOH
  ls -l /etc/localtime | grep Australia > /dev/null; 
  if [ $? -eq 1 ]; then 
    ln -sf /usr/share/zoneinfo/Australia/Melbourne /etc/localtime
  fi
  
  ntpdate 0.pool.ntp.org
  EOH
end

user "atom" do
  action :create
  comment "Atom dataset provider"
  system true
  supports :manage_home => true
  notifies :reload, resources(:ohai => "reload_passwd"), :immediately
end

bash "install foreman" do
  code <<-EOH
  gem install foreman -v 0.47.0
  EOH
end


app_dirs = [
  "/opt/atom-dataset-provider",
]


app_dirs.each do |dir|
  directory dir do
    owner "atom"
    group "atom"
  end
end

deploy_revision "atom-dataset-provider" do
  action :force_deploy
  deploy_to "/opt/atom-dataset-provider"
  repository "https://github.com/stevage/atom-dataset-provider"
  branch "master"
  user "atom"
  group "atom"
  symlink_before_migrate({})
  purge_before_symlink([])
  create_dirs_before_symlink([])
  symlinks({})
  before_symlink do
    bash "install_npm" do
      user "root"
      cwd release_path
      code <<-EOH
      npm install
      npm install vows
      EOH
    end

    cookbook_file "#{release_path}/kill_provider.sh" do
      source "kill_provider.sh"
      backup false
      group "atom"
      owner "atom"
      mode "0774"
    end

    template "#{release_path}/provider.sh" do
      source "provider.sh"
      backup false
      group "atom"
      owner "atom"
      mode "0774"
    end

    cookbook_file "#{release_path}/lib/atom-dataset-provider/templates/feed.atom" do
      # Provide a custom version of feed.atom to have a custom feed.
      source "feed.atom"
      group "atom"
      owner "atom"
      mode "0664"
      ignore_failure true # this is an optional override file
    end
 
    cookbook_file "#{release_path}/Procfile" do
      group "atom"
      owner "atom"
      mode "0664"
    end
  
    cookbook_file "#{release_path}/.foreman" do
      group "atom"
      owner "atom"
      mode "0664"
    end
    
    ["/Microscopy/Biology", "/Microscopy/Materials",].each do |sampledir|
      directory node["dataset-provider"]["share-path"]+sampledir do
        owner "atom"
        group "atom"
        recursive true
        only_if { node.chef_environment == "dev" }
      end
    end 

    [["/Microscopy/Materials", "ZnO_combs_on_ITO_glass.tif"], 
     ["/Microscopy/Materials", "ica002.tif"],                 
     ["/Microscopy/Materials", "manganese.spc"],              
     ["/Microscopy/Materials", "manganese_dump.txt"],         
     ["/Microscopy/Materials", "nickel.bmp"],
     
     ["/Microscopy/Biology", "ant.tif"],
     ["/Microscopy/Biology", "mosquito.tif"],
    ].each do |sampledir, samplefile|
      cookbook_file node["dataset-provider"]["share-path"] + sampledir + "/" + samplefile do
        owner "atom"
        group "atom"
        mode "0644"
        source samplefile
        only_if { node.chef_environment == "dev" }
      end
    end
          
  end
  restart_command do
    bash "activate_foreman" do
      cwd "/opt/atom-dataset-provider/current"
      # Arguments to foreman are set in .foreman file
      code <<-EOH
        foreman export upstart /etc/init
        restart atom || start atom
      EOH
    end
  end
end

