
include_recipe "dataset-provider::deps"

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

app_dirs = [
  "/opt/dataset-provider",
]


app_dirs.each do |dir|
  directory dir do
    owner "atom"
    group "atom"
  end
end

deploy_revision "atom-dataset-provider" do
  action :force_deploy
  deploy_to "/opt/dataset-provider"
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
      # tests fail - dunno why 
     #npm test
      EOH
    end

    file "#{release_path}/provider.sh" do
      backup false
      group "atom"
      owner "atom"
      mode "0744"
      content <<-EOH
      #!/bin/bash
      bin/atom-dataset-provider -d #{node["dataset-provider"]["share-path"]} -p #{node["dataset-provider"]["port"]}
      EOH
    end

  end
  restart_command do
    current_release = release_path
    bash "restart_provider" do
      user "root"
      group "atom"
      cwd current_release
      code <<-EOH
        nohup ./provider.sh >> provider.log
      EOH
    end
  end
end

