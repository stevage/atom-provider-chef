name "prod"
description "Faux-production version, serving up /opt/dataset-provider/data on port 80."
default_attributes "dataset-provider" => { 
  "share-path" => "/opt/dataset-provider/data",
  "port" => "80"
 }

