#
# Cookbook: Birdless Feathers
#
#
#
include_recipe "iis"
include_recipe "git"

iis_pool 'icons' do
  runtime_version "2.0"
  pipeline_mode :Classic
  action :add
end

# needs to be forced?
# directory "#{node['iis']['docroot']}/icons" do
#   recursive true
#   action :delete
# end

git "#{node['iis']['docroot']}/icons" do
  repository "https://github.com/colebemis/feather"
  reference "master"
  action :sync
end

# template "c:/inetpub/wwwroot/icons.htm" do
#   source "icons.htm.erb"
# end

# directory "#{node['iis']['docroot']}/icon" do
#   action :create
# end

iis_section 'unlocked web.config globally for Basic auth' do
  action :unlock
  section 'system.webServer/security/authentication/basicAuthentication'
end

iis_section 'unlock staticContent of default web site' do
  section 'system.webServer/icon'
  site 'icons'
  action :unlock
end

iis_site 'icons' do
  protocol :http
  port 80
  path "c:/inetpub/wwwroot/"
  action [:add,:start]
end
