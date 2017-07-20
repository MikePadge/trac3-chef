#
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Cookbook:: iis
# Recipe:: default
#
# Copyright:: 2011-2016, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Always add this, so that we don't require this to be added if we want to add other components
default = Opscode::IIS::Helper.older_than_windows2008r2? ? 'Web-Server' : 'IIS-WebServerRole'

([default] + node['iis']['components']).each do |feature|
  windows_feature feature do
    action :install
    all !Opscode::IIS::Helper.older_than_windows2012?
    source node['iis']['source'] unless node['iis']['source'].nil?
  end
end

service 'iis' do
  service_name 'W3SVC'
  action [:enable, :start]
end

iis_site 'Default Web Site' do
  action [:stop, :delete]
end

template 'c:\inetpub\wwwroot\Default.htm' do
  source 'Default.htm.erb'
end

remote_directory "feather" do
  path "#{node['iis']['docroot']}/icons"
  action :create
end

cookbook_file 'c:/inetpub/wwwroot/web.config' do
  source 'web.config'
  path 'c:/inetpub/wwwroot/web.config'
  action :create_if_missing
end

iis_site 'icons' do
  protocol :http
  port 80
  path "c:/inetpub/wwwroot/"
  action [:add,:start]
end

# doesn't work and i'm not sure why
# iis_section 'unlock staticContent of default web site' do
#   section 'system.webServer/icons'
#   site 'icons'
#   action :unlock
# end

# iis_section 'unlocked web.config globally for windows auth' do
#   action :unlock
#   section 'system.webServer/'
# end

include_recipe 'iis::flame', 'iis::mod_auth_basic', 'iis::mod_auth_windows', 'iis::mod_management', 'iis::winupdate'
# 'iis::siteup'



