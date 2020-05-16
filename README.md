# terraform-oci-azure-vpn
Automatic setup of a very basic VPN connection between OCI and Azure. No BGP and just one single tunnel.

## Instructions

1. Copy the directory containing you oci credentials (probably something like ~/.oci) to the main directory of your cloned repo

2. Edit set_env.sh

3. Source `set_env.sh`

4. Run `terraform apply`

This will run some time (40+ minutes).

## Error referring to public ip 

Azure will assign public ips at the time they are used by another Azure resource, e.g. a VM being started or - in this case - a VNG is actually running. Due to this behavior, it can happen that an error related to public ips being null will be thrown when the CPE is set up in OCI. In this case just run `terraform apply` a second time.



# oci-azure-vpn
