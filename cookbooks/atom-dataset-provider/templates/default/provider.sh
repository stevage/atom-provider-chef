#!/bin/bash
bin/atom-dataset-provider -d <%= node["dataset-provider"]["share-path"] %> -p <%= node["dataset-provider"]["port"] %> --group-pattern '/^<%= node["dataset-provider"]["share-path"] %>/([^/]+/[^/]+/)/'
