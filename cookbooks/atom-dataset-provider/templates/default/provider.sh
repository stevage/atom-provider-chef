#!bin/bash
#templated!
bin/atom-dataset-provider -d <%= node["dataset-provider"]["share-path"] %> -p <%= node["dataset-provider"]["port"] %>
