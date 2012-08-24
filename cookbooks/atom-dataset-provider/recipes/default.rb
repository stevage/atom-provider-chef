
include_recipe "atom-dataset-provider::deps"

ohai "reload_passwd" do
  action :nothing
  plugin "passwd"
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

    directory "/mnt/data/experiment1/dataset1" do
       recursive true
       only_if { node.chef_environment == "dev" }
    end

    file "/mnt/data/experiment1/dataset1/testfile1.txt" do
       owner "atom"
       group "atom"
       mode "0644"
       content "A sample file."
       only_if { node.chef_environment == "dev"}
    end
#    service "atom-dataset-provider" do
#      start_command "/opt/atom-dataset-provider/current/provider.sh"
#      stop_command "/opt/atom-dataset-provider/current/kill_provider.sh"       
#      action [:enable]
#    end	
       
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

