# encoding: UTF-8
#
# Cookbook Name:: openstack-block-storage
# Recipe:: api
#
# Copyright 2012, Rackspace US, Inc.
# Copyright 2012-2013, AT&T Services, Inc.
# Copyright 2013, Opscode, Inc.
# Copyright 2013-2014, SUSE Linux Gmbh.
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
# Make Openstack object available in Chef::Recipe
class ::Chef::Recipe
  include ::Openstack
end

include_recipe 'openstack-block-storage::cinder-common'

platform_options = node['openstack']['block-storage']['platform']

platform_options['cinder_api_packages'].each do |pkg|
  package pkg do
    options platform_options['package_overrides']
    action :upgrade
  end
end

db_type = node['openstack']['db']['block-storage']['service_type']
node['openstack']['db']['python_packages'][db_type].each do |pkg|
  package pkg do
    action :upgrade
  end
end

# Todo(jr): Runs via wsgi in apache2 now, need to find a nice way to
# trigger apache2 restart. Also disable the default installed wsgi
# service and use our template based setup

execute 'cinder-manage db sync' do
  user node['openstack']['block-storage']['user']
  group node['openstack']['block-storage']['group']
end

if node['openstack']['block-storage']['policyfile_url']
  remote_file '/etc/cinder/policy.json' do
    source node['openstack']['block-storage']['policyfile_url']
    owner node['openstack']['block-storage']['user']
    group node['openstack']['block-storage']['group']
    mode 0o0644
  end
end
