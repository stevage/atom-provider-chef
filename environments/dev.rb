name "dev"
description "Local desktop version, serving up /mnt/data on a weird port."
default_attributes "dataset-provider" => { 
  "share-path" => "/mnt/data",
  "port" => "80"
 }

