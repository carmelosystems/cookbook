#
# Cookbook Name:: nodeConnect
# Recipe:: default
#
# Copyright 2015, Carmelo Systems 
#
# All rights reserved - Do Not Redistribute
#

# Node controller IP address. This need to be changed by noting 
# the controller IP address and replacing with below value.

controller = "52.10.254.180"

# Node tag defines a type of nodes. Multiple nodes may be 
# associated with the same tag. User can change the tag names in the 
# list below based on service nodes provides. Note that each node need to be
# tagged with atleast one of the value from the list using Knife tag ... 
# command. Multitagging is also supported for Node.  

nodeTags = ["Apps", "Backup", "Web", "Data"]

# Below list is for the cloud provider for the Node instance.
# Do not edit the provider list. Tag the node based on the provider 
# using Knife tag .. command along with other tagging for the node.
# Eg: "knife tag create Node0 Web aws ..." for a web server node in
# AWS EC2.

cloudProvider = [ "aws", "azure", "google", "phoenixnap",
                  "softlayer", "digitalocean", "other"]

node_name = "#{Chef::Config[:node_name]}"


def get_tag(n_tags, default)
  ts  = '' 
  found = false
  many  = false
  if run_context.node[:tags].length <=0 then
     return default 
  end

  n_tags.each do |t|
    if run_context.node[:tags].include?(t) then
        found = true
        if many
           ts = ts + ',' + t
        else
           ts = t
           many = true
        end
    end
  end
  if found 
     return ts
  else
     return default 
  end
end

default_tag = ""
n_tag = get_tag(nodeTags, default_tag)
provider = get_tag(cloudProvider, "other")
Chef::Log.info "tag name = #{n_tag}"
Chef::Log.info "Node name = #{node_name}"
Chef::Log.info "Controller = #{controller}"
Chef::Log.info "Provider = #{provider}"

script "install_node_client" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
    wget --no-check-certificate https://#{controller}/install_node_client.sh
    chmod +x install_node_client.sh
    if [#{n_tag} = ""]; then
        ./install_node_client.sh -m force -s #{controller} -n #{node_name} -c #{provider} 
    else 
        ./install_node_client.sh -m force -s #{controller} -n #{node_name} -c #{provider} -t  #{n_tag} 
    fi
  EOH
end

