### oci
export TF_VAR_oci_tenancy_ocid="ocid1.tenancy.oc1..aaaaaaaadeoj3n5gq7dn7wt32cc4l6mzdopbhfumluhbp5haw4smiepeld7q"
export TF_VAR_oci_user_ocid="ocid1.user.oc1..aaaaaaaab7em6zux2kpm4tkxgk53tnylkra7jyfs6xdikufdrtktncwtsztq"
export TF_VAR_oci_compartment_ocid="ocid1.compartment.oc1..aaaaaaaaywbfhbbnfgyf47pq4uikio5qhqqpxxw4c34l2wpjfiiligm5jrna"
export TF_VAR_oci_fingerprint=ad:c9:c2:d1:0b:f3:00:cb:1d:81:e8:cc:36:d2:07:39
export TF_VAR_oci_private_key_path=/Users/paulopierrondi/.oci/oci_api_key.pem
export TF_VAR_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)

export TF_VAR_oci_region="eu-amsterdam-1"

export TF_VAR_peering_net="10.99.0"

export TF_VAR_oci_cidr_vpn_vcn="10.3.0.0/16"
export TF_VAR_oci_cidr_vpn_subnet="10.3.1.0/24"
export TF_VAR_oci_cidr_vpn_subnet2="10.3.2.0/24"

### azure
export TF_VAR_arm_client_id="8e1cb318-18b7-4d02-8c4f-c26b3d14a9cf"
export TF_VAR_arm_client_secret="/uIbd2U/NJEN6J-2/NDi6wd:mY/_.Bkt"
export TF_VAR_arm_tenant_id="aaf6f44a-0570-475b-bdc7-9eecf4a70551"
export TF_VAR_arm_subscription_id="03624262-fb2c-4f74-b6a9-25feda82427e"
export TF_VAR_arm_region="West Europe" 

export TF_VAR_oci_base_image="ocid1.image.oc1.eu-amsterdam-1.aaaaaaaat32fvq5hsmbljrvy77gr2xel7i3l3oc6g3bcnnd6mimzz5jqa7ka"


# test vnet
export TF_VAR_arm_cidr_vpn_vnet="10.2.0.0/16"
export TF_VAR_arm_cidr_vpn_subnet="10.2.1.0/24"
export TF_VAR_arm_cidr_vpn_gw_subnet="10.2.99.0/24"

export TF_VAR_arm_vnet_cidr="10.1.0.0/16"
export TF_VAR_arm_client_subnet_cidr="10.1.1.0/24"
export TF_VAR_arm_gw_subnet_cidr="10.1.99.0/24"
##CentOS
# export TF_VAR_arm_image_publisher="OpenLogic"
# export TF_VAR_arm_image_offer="CentOS-CI"
# export TF_VAR_arm_image_sku="7-CI"
# export TF_VAR_arm_image_version="latest"
##Oracle
export TF_VAR_arm_image_publisher="Oracle"
export TF_VAR_arm_image_offer="Oracle-Linux"
export TF_VAR_arm_image_sku="8-ci"
export TF_VAR_arm_image_version="8.0.11"