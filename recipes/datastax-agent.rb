# if including this recipe then enable datastax-agent
node.default['datastax-agent']['enabled'] = true

# search for opscenter role
if node['datastax-agent']['role_based_opscenter']
  if Chef::Config[:solo]
    Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
    Chef::Log.warn("Dissable with node['datastax-agent']['role_based_opscenter']")
  else
    search(:node, "#{node['opscenter']['role']} AND chef_environment:#{node.chef_environment}") do |m|
      list = m['ipaddress']
    end
  end
  node.default['datastax-agent']['opscenter-ip'] = list
end


#Install the datastax-agent package
package "datastax-agent" do
  version node['datastax-agent']['version']
  action :install
end

#Set up the stomp IP (the IP of Opscenter)
template "#{node['datastax-agent']['conf_dir']}/address.yaml" do
   source "address.yaml.erb"
   notifies :restart, "service[datastax-agent]"
 end

#Restart the agent
service "datastax-agent" do
  action :start
end
