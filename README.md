# Nomad Up and Running

## Nomad Guides

Nomad Guides Operations can be used to launch full stack Nomad clusters with Consul and optionally Vault servers.
This is a very easy way to get started with all HashiCorp tools.   We do not recommend you put these systems in production in their current state.   

They can be found at: https://github.com/hashicorp/nomad-guides/tree/master/operations/provision-nomad

## Environment files

For OSS users sharing workspaces, sometimes it may be desired to have unique values when running dev/test/qa systems.   Environment variables make it very easy to do local unique configurations.   Typically they'll be stored in a location out of the repository.  e.g. ~/terraform/environments

nomad-quick-start-example.sh is an example of this kind of file to be sourced before terraform runs

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

## SOCKS Proxy

When running non-public resources, you will have to connect through the bastion to get access to the internal load balancers.   The easiest way to do this is create a SOCKS proxy via SSH into the bastion host and enable SOCKS proxy in your web browser.   

```
BASTION=10.4.2.1
```

Now that you have a socks proxy setup, you can connect directly to the URLs provided in the output block.

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
ssh -A ${KEYFILE} ec2-user@${BASTION}
exit
```

## Install pre-requisite software
Because we're using a generic images we'll have to install some software onto the Nomad nodes.  At the time, the passthrough of user-data from the main module to the nomad-aws module isn't enabled, so we'll just use a script.  In the future, we'll be able to just pass user-data (and this repo will be updated)

```
scp nomad_client_setup.sh ec2-user@${BASTION}:~
ssh ec2-user@${BASTION}
for i in $(consul members | grep client-nomad | awk '{print $2}' | grep -v Address | cut -f 1 -d :);do scp nomad_client_setup.sh $i:~; ssh -o StrictHostKeyChecking=false $i "bash nomad_client_setup.sh"; done
``` 

* nomad status
* vi helloworld.nomad
* nomad plan helloworld.nomad
* nomad run helloworld.nomad (Use the version)
* nomad status
* curl http://IP:Port/helloworld/index.html
* vi fabio.nomad
* nomad status fabio
* Nomad GUI: jobs—fabio—fabio—<allocation>—click admin
* https://nomad.jake.hashidemos.io/helloworld
* terraform destroy -auto-approve