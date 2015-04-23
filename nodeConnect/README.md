# README.md
# Cookbook for nodeConnect
# Recipe name default.rb
# Copyright 2015, Carmelo Systems
# All rights reserved - Do Not Redistribute

Introduction
====================================================================
This README.md is to describe how to automate the Node Connect 
installation through Chef Cookbook. It is assumed that there is already 
a chef development environment and the additional recipe is cooked for 
Node Connect installation. 

If Chef Development environment is not present, the following link is 
a good reference to start.  
https://www.digitalocean.com/community/tutorials/how-to-install-a-chef-server-workstation-and-client-on-ubuntu-vps-instances

To begin using Chef on Node Connect installation, follow these steps. 

Step1: Create Cookbook:nodeConnect
====================================================================

In the workstation, create a cookbook with the following commands.

   ubuntu$ knife cookbook create nodeConnect

   ubuntu$ cd cookbooks/nodeConnect/recipes

Step2: Replace default.rb
====================================================================
Replace the default.rb with recipe cooked for NodeConnect by Carmelo 
Systems from github repository.  

Step3: Recipe customization 
====================================================================
3.1 Setting Node controller IP address (default.rb).
Node controller is a centralized entity to configure and manage Nodes. 
The IP address for the controller in default.rb ("52.10.254.180") 
should be replaced by the controller IP address launched in AWS us-west-2. 

3.2 Define Node Tag List (default.rb).
Node tag defines a type of nodes.  
A node can be associated with multiple tags. For Node Connect, tags are 
used to define policies that build encrypted tunnel between nodes. You 
must first define the tag names in the nodeTags in default.rb.  

Example given here are "Apps", "Backup", "Web" and "Data" tag names.   
Note that each node must be tagged with one or more of the tags from 
the Tag list using knife tag create command.

nodeTags = ["Apps", "Backup", "Web", "Data"]

3.3 Supported Node Provider Tags.
Currently Node Connect supports the following cloud providers:

cloudProvider = [ "aws", "azure", "google", "phoenixnap",
                  "softlayer", "digitalocean", "rackspace", "other"]

You must not change the above cloudProvider list in default.rb.  
You must provide for each node with one correct provider name through knife 
tag command from the list. 

Step 4: Provisioning Node using Knife
====================================================================

Example:

knife tag create Node1 Apps aws  ==> Node Connect tag "Apps" and provider "aws"

knife tag create Node2 Web Data aws ==> Node Connect tag "Apps" and "Data" and 
                                        provider "aws"

knife tag create Node3 Web Apps Data azure ==> Node Connect tag: "Web", 
                                      "Apps" & "Data" provider "azure"

knife tag create Node4 Web Apps Data azure denver ==> Node Connect tag "Web", 
         "Apps" & "Data" and provider: "azure" other tags on node as "denver"

Tagging and Policies together allow Node Connect controller to build 
encrypted tunnels any two nodes.   

Step 5: Testing the Recipe on a Node
====================================================================
Following steps need to be taken to test the recipe on a node 
(say on a previously added node0)

5.1 Set the tags for the node using "knife tag create Node0 Web Data Apps aws"

5.2 Add  a default editor export EDITOR=vi

5.3 Add the recipe into the “run_list" with "knife node edit Node0"

{
  "name": "Node0",
  "chef_environment": "_default",
  "normal": {
    "tags": [
      "Web",
      "aws",
      "Data",
      "Apps"
    ]
  },
  "run_list": [
  "recipe[nodeConnect]"      <<< added the recipe
]
}

5.4 Upload the cookbook into the server using "knife cookbook upload –a"

5.5 Test the cookbook in Node (Node0) with "sudo chef-client"

Client will be running Node Connect now!!. Check the controller’s 
“connect” page or chef logs for any error. 

nodeConnect recipe can be integrated with other recipes in the organization.

=================================END===============================
