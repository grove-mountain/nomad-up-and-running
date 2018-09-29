# Typically located on local git only.   Sourced with:
# . ~/terraform/environments/nomad-quick-start-example.sh

# This isn't an exhaustive list of overrides, just the ones I wanted 
# overriden.   

# You can always create other workspaces and put variables in .tfvars files
# or TFE variables


# By default quick start makes web endpoints public.   
# Make this false to make internal-only web endpoints.
# This makes a more secure environment typically.
PUBLIC=false

# If Using a custom AMI
# IMAGE_OVERRIDE=ami-0feeb6ce210f8861b
IMAGE_OVERRIDE=""

# For any resource that has tags, they probably have the same ones, reuse
COMMON_TAGS='{"owner" = "jlundberg", "TTL" = "-1"}'
COMMON_TAGS_LIST='[
 {"key" = "owner", "value" = "jlundberg", "propagate_at_launch" = true},
 {"key" = "TTL", "value" = "-1", "propagate_at_launch" = true}
]'

export TF_VAR_name="jake-nomad-qs"
export TF_VAR_common_name='jake.hashidemos.io'
export TF_VAR_organization_name='HashiCorp'

# Bastion settings
export TF_VAR_bastion_nomad_version="0.8.5"
export TF_VAR_bastion_image_id="${IMAGE_OVERRIDE}"
export TF_VAR_network_tags=${COMMON_TAGS}

# Nomad settings
export TF_VAR_nomad_version="0.8.5"
export TF_VAR_nomad_clients="3"
export TF_VAR_nomad_image_id="${IMAGE_OVERRIDE}"
export TF_VAR_nomad_public="${PUBLIC}"
export TF_VAR_nomad_tags=${COMMON_TAGS}
export TF_VAR_nomad_tags_list=${COMMON_TAGS_LIST}

# Consul settings
export TF_VAR_consul_version="1.2.3"
export TF_VAR_consul_image_id="${IMAGE_OVERRIDE}"
export TF_VAR_consul_public="${PUBLIC}"
export TF_VAR_consul_tags=${COMMON_TAGS}
export TF_VAR_consul_tags_list=${COMMON_TAGS_LIST}

# Vault settings
export TF_VAR_vault_version="0.11.1"
export TF_VAR_vault_servers="1"
export TF_VAR_vault_provision="true"
export TF_VAR_vault_image_id="${IMAGE_OVERRIDE}"
export TF_VAR_vault_public="${PUBLIC}"
export TF_VAR_vault_tags=${COMMON_TAGS}
export TF_VAR_vault_tags_list=${COMMON_TAGS_LIST}

# TFE settings for creating TFE workspaces with TF
#. ~/.tfe_saas_token
#export TF_VAR_tfe_org="jake-org"
#export TF_VAR_tfe_token=$(cat ~/.tfe_saas_jake-org)
#export TF_VAR_vcs_token=$(cat ~/.gh_repo)
#export TF_VAR_vcs_identifier="grove-mountain/nomad-guides"
#export TF_VAR_vcs_branch="master"
