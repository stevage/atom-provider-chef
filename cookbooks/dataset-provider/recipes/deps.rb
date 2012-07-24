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


#  bash("install_nodejs") do
#    user "root"
#    cwd "/usr/local/lib"
#    code <<-EOH
#    git clone git://github.com/ry/node.git
#    cd node
#    ./configure
#    make
#    make install
#    EOH
#    not_if do
#      File.exists?("/usr/local/lib/node")
#    end
#  end
#  directory "/usr/local/lib/npm"
#  bash("install_npm") do
#    user "root"
#    cwd "/usr/local/lib/npm"
#    code <<-EOH
#   wget http://npmjs.org/install.sh
#    chmod u+x install.sh
#    ./install.sh
#    EOH
#    not_if do
#      File.exists?("/usr/local/lib/npm/install.sh")
#    end

# end 
  
end
