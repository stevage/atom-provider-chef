current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "stevage"
client_key               "#{current_dir}/stevage.pem"
validation_client_name   "versi-validator"
validation_key           "#{current_dir}/versi-validator.pem"
chef_server_url          "https://api.opscode.com/organizations/versi"
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            ["#{current_dir}/cookbooks"]
