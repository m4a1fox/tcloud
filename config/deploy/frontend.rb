# Deploys frontend
# Deploy command example:
# 	cap frontend deploy -s host=ec2-50-17-138-170.compute-1.amazonaws.com

set :application, "tcloud.frontend"

set :domain, "tcloud@#{host}"
server domain, :web, :app
role :db,  domain, :primary => true # This is where Rails migrations will run

set :port, 22

set :repository,  "git@git.archer-soft.com:tcloud-drupal-site.git"

require File.expand_path("../lib/php", __FILE__)
