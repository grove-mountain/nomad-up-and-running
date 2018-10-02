# Nomad Up and Running

The intent of this demo is to allow you to launch a Nomad cluster using the Nomad Quick Start guide.   Then, you will launch a very simple, non-containerized Tomcat application using the raw_exec driver.   After, you will launch a containerized version of the popular Consul enabled load balancer Fabio.   

## Nomad Guides

Nomad Guides Operations can be used to launch full stack Nomad clusters with Consul and optionally Vault servers.
This is a very easy way to get started with all HashiCorp tools.   We do not recommend you put these systems in production in their current state.   

They can be found at: https://github.com/hashicorp/nomad-guides/tree/master/operations/provision-nomad

## Environment files

For OSS users sharing workspaces, sometimes it may be desired to have unique values when running dev/test/qa systems.   Environment variables make it very easy to do local unique configurations.   Typically they'll be stored in a location out of the repository.  e.g. ~/terraform/environments

nomad-quick-start-example.sh is an example of this kind of file to be sourced before terraform runs.  Copy and customize to your needs and source the file before terraform runs. 

## Security

For security purposes, this guide assumes you make it so non-load balancers are public.  If using the example file, public is already set to false.   Otherwise make sure to set the following variables as false however you set variables:

```
nomad_public
vaul_public
consul_public
```

This ensures you can test this guide with higher security than leaving everything open to the public.   If you open your resources to the public, realize the security risks and mitigate as required.

## Terraform run

Once you navigate to the desired directory (quick-start was used in this guide), update your variables via environment file or .tfvars file and run terraform

Once the run is complete you will be given a large output with information like:

* Detailed resource outputs
* SSH Connection instructions
* Nomad connection details and basic commands
* Consul connection details and basic commands
* Vault connection details and basic commands

### Example usage:
```
git clone https://github.com/hashicorp/nomad-guides.git
cd nomad-guides/operations/provision-nomad/quick-start/terraform-aws
. ~/git/environments/nomad-quick-start.sh
terraform plan
terraform apply
```


## SSH to bastion

You'll run most commands from the bastion host.   The connection details are at the top of the output.  

Beware!  If you add too many SSH keys to your keychain, you may get failures because you may fail authentication before a good key is reached.   Use `ssh-add` utilities to manage those keys.

Check the output for a line similar to:
```
ssh-add nomad-quick-start-5c228498.key.pem
ssh -A -i nomad-quick-start-5c228498.key.pem ec2-user@18.206.95.27
```

Set your KEYFILE and BASTION environment variables
e.g.
```
KEYFILE=nomad-quick-start-5c228498.key.pem
BASTION=18.206.95.27
```

Test the connection and exit
```
ssh -A -i ${KEYFILE} ec2-user@${BASTION}
```

## Install pre-requisite software
Because we're using a generic images we'll have to install some software onto the Nomad nodes.  At the time, the passthrough of user-data from the main module to the nomad-aws module isn't enabled, so we'll just use a script.  In the future, we'll be able to just pass user-data (and this repo will be updated)

Clone the github repository containing all the code and change to that directory

```
ssh ec2-user@${BASTION}
git clone https://github.com/grove-mountain/nomad-up-and-running.git

cd nomad-up-and-running

for i in $(consul members | grep client-nomad | awk '{print $2}' | grep -v Address | cut -f 1 -d :);do scp nomad_client_setup.sh $i:~; ssh -o StrictHostKeyChecking=false $i "bash nomad_client_setup.sh"; done
``` 

## SOCKS Proxy

When running non-public resources, you will have to connect through the bastion to get access to the internal load balancers.   The easiest way to do this is create a SOCKS proxy via SSH into the bastion host and enable SOCKS proxy in your web browser.  See your web browser's documentation to see how to enable SOCKS proxies.

Open another terminal window and run:
```
ssh -D 8765 -f -C -q -N ec2-user@${BASTION}
```

Now that you have a socks proxy setup, you can connect directly to the URLs provided in the output block.

## Run Nomad Jobs

```
nomad status
nomad plan helloworld.nomad
nomad run helloworld.nomad
nomad status hw
nomad plan fabio.nomad
nomad run fabio.nomad
nomad status fabio

```

## Update security groups

This is currently a manual step.  You need to ensure that you can reach fabio on port 9999.   Search for the security group with the string "client-nomad-consul-client".   This is easy to do in the console or via command line
```
aws ec2 describe-security-groups --filters Name=group-name,Values='*client-nomad-consul-client*'
```

Add the TCP port 9999 with access to the same security group name.   


## Verify things are running

curl http://fabio.service.consul:9999/helloworld/index.html


## Add an ALB to access Fabio (optional)

If you want to be able to reach the demo application from the outside world:
  * Create or use an existing ACM certificate 
  * Create an ALB
  * Use HTTPS on 443
  * Use ACM created above
  * Create a target group for HTTP traffic on 9999
  * Health check on /helloworld/index.html codes: 200



## Clean up
If you're finished with this infrastructure at this point, destroy the resources:
```
terraform destroy
```