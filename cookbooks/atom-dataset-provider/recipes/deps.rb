if node['platform_family'] == "debian"
    #build-essential is meant to do this?
    execute "apt-get update" do
       action :nothing 
    end.run_action(:run)
end

include_recipe "build-essential"

if platform?("ubuntu","debian")
  %w{g++ curl libssl-dev apache2-utils git-core}.each do |pkg|
    package pkg do
      action :install
    end
  end
  package "python-software-properties" do
    action :install
  end
  bash("add-npm-repo") do
    user "root"
    code <<-EOH
    apt-add-repository ppa:chris-lea/node.js
    apt-get update
    EOH
  end
  package "nodejs npm" do
    action :install
  end

end
