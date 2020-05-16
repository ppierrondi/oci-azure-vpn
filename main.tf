resource "oci_core_virtual_network" "vpn_vcn" {
  cidr_block     = var.oci_cidr_vpn_vcn
  dns_label      = "vpnvcn"
  compartment_id = var.oci_compartment_ocid
  display_name   = "vpn-vcn"
}

resource "oci_core_subnet" "vpn_subnet" {
  cidr_block        = var.oci_cidr_vpn_subnet
  compartment_id    = var.oci_compartment_ocid
  vcn_id            = oci_core_virtual_network.vpn_vcn.id
  display_name      = "vpn-subnet"
  dns_label         = "vpnsubnet"
  security_list_ids = [oci_core_security_list.vpn_sl.id]
}
###testing second tunnel for redunduncy 
resource "oci_core_subnet" "vpn_subnet2" {
  cidr_block        = var.oci_cidr_vpn_subnet2
  compartment_id    = var.oci_compartment_ocid
  vcn_id            = oci_core_virtual_network.vpn_vcn.id
  display_name      = "vpn-subnet2"
  dns_label         = "vpnsubnet2"
  security_list_ids = [oci_core_security_list.vpn_sl.id]
}

resource "oci_core_internet_gateway" "vpn_igw" {
  display_name   = "vpn-internet-gateway"
  compartment_id = var.oci_compartment_ocid
  vcn_id         = oci_core_virtual_network.vpn_vcn.id
}

resource "oci_core_default_route_table" "vpn_default_route_table" {
  manage_default_resource_id = oci_core_virtual_network.vpn_vcn.default_route_table_id

  route_rules {
    network_entity_id = oci_core_internet_gateway.vpn_igw.id
    destination       = "0.0.0.0/0"
  }

  route_rules {
    network_entity_id = module.vpn.oci_vpn_drg_id
    destination       = var.arm_cidr_vpn_vnet
  }
}

resource "oci_core_security_list" "vpn_sl" {
  compartment_id = var.oci_compartment_ocid
  vcn_id         = oci_core_virtual_network.vpn_vcn.id
  display_name   = "connect-security-list"

  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "1"
  }

  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "6"

    tcp_options {
      min = "22"
      max = "22"
    }
  }

  # azure
  ingress_security_rules {
    source      = var.arm_cidr_vpn_vnet
    description = "Azure VPN test VNet"
    protocol    = "6"

    tcp_options {
      min = "5000"
      max = "19800"
    }
  }
  ingress_security_rules {
    source      = var.arm_cidr_vpn_vnet
    description = "Azure VPN test VNet"
    protocol    = "17"

    udp_options {
      min = "5000"
      max = "19800"
    }
  }

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
}

resource "azurerm_virtual_network" "vpn_vnet" {
  name                = "vpn-network"
  resource_group_name = azurerm_resource_group.connect.name
  location            = azurerm_resource_group.connect.location
  address_space       = [var.arm_cidr_vpn_vnet]
}

resource "azurerm_subnet" "vpn_subnet" {
  name                 = "vpn-subnet"
  resource_group_name  = azurerm_resource_group.connect.name
  virtual_network_name = azurerm_virtual_network.vpn_vnet.name
  address_prefix       = var.arm_cidr_vpn_subnet
}

resource "azurerm_subnet" "vpn_gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.connect.name
  virtual_network_name = azurerm_virtual_network.vpn_vnet.name
  address_prefix       = var.arm_cidr_vpn_gw_subnet
}

resource "azurerm_resource_group" "connect" {
  name     = "connect"
  location = var.arm_region
}

data "oci_identity_availability_domains" "connect_ads" {
  compartment_id = var.oci_compartment_ocid
}

data "template_file" "client" {
  template = "${file("templates/adb_client.tpl")}"
}
resource "azurerm_public_ip" "client_public_ip" {
  name                = "client-public-ip"
  location            = "${azurerm_resource_group.connect.location}"
  resource_group_name = "${azurerm_resource_group.connect.name}"
  allocation_method   = "Dynamic"
}

data "azurerm_public_ip" "client_public_ip" {
  name                = "${azurerm_public_ip.client_public_ip.name}"
  resource_group_name = "${azurerm_resource_group.connect.name}"
}
resource "azurerm_public_ip" "ref_public_ip" {
  name                = "ref-pub-ip"
  location            = "${azurerm_resource_group.connect.location}"
  resource_group_name = "${azurerm_resource_group.connect.name}"
  allocation_method   = "Dynamic"
}

data "azurerm_public_ip" "ref_public_ip" {
  name                = "${azurerm_public_ip.ref_public_ip.name}"
  resource_group_name = "${azurerm_resource_group.connect.name}"
}
########Azure VM
resource "azurerm_network_interface" "ref_nic" {
  name                = "ref-nic"
  location            = "${azurerm_resource_group.connect.location}"
  resource_group_name = "${azurerm_resource_group.connect.name}"

  ip_configuration {
    name                          = "ref-nic-config"
    subnet_id                     = "${azurerm_subnet.vpn_subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.ref_public_ip.id}"
  }
}

resource "azurerm_virtual_machine" "ref_instance" {
  name                  = "ref-instance"
  location              = "${azurerm_resource_group.connect.location}"
  resource_group_name   = "${azurerm_resource_group.connect.name}"
  network_interface_ids = ["${azurerm_network_interface.ref_nic.id}"]
  vm_size               = "Standard_F2s_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "${var.arm_image_publisher}"
    offer     = "${var.arm_image_offer}"
    sku       = "${var.arm_image_sku}"
    version   = "${var.arm_image_version}"
  }

  storage_os_disk {
    name              = "ref_osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "ref-client"
    admin_username = "azure"
    admin_password = "Welcome-1234"
    custom_data    = "${data.template_file.client.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      key_data = "${var.ssh_public_key}"
      path     = "/home/azure/.ssh/authorized_keys"
    }
  }
}


########OCI Instance--Added on 07/05/2020 for testing purposes Paulo√

resource "oci_core_instance" "client-instance" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.connect_ads.availability_domains[0],"name")}"
  compartment_id      = "${var.oci_compartment_ocid}"
  shape               = "VM.Standard2.4"

  create_vnic_details {
    subnet_id              = "${oci_core_subnet.vpn_subnet.id}"
    assign_public_ip       = true
    skip_source_dest_check = true
  }

  display_name = "oci-client"

  metadata = {
    ssh_authorized_keys = "${var.ssh_public_key}"
    # user_data           = "${base64encode(data.template_file.client.rendered)}"
  }

  source_details {
    source_id   = "${var.oci_base_image}"
    source_type = "image"
  }
  preserve_boot_volume = false
}
## modules 

module "vpn" {
  source = "./modules/vpn"

  oci_compartment_ocid = var.oci_compartment_ocid

  oci_vpn_vcn_id      =   oci_core_virtual_network.vpn_vcn.id
  oci_vpn_subnet_cidr =   var.oci_cidr_vpn_subnet
  oci_vpn_subnet_cidr2 =  var.oci_cidr_vpn_subnet2
  arm_resource_group_location = azurerm_resource_group.connect.location
  arm_resource_group_name     = azurerm_resource_group.connect.name

  arm_vpn_vnet_cidr    = var.arm_cidr_vpn_vnet
  arm_vpn_subnet_cidr  = var.arm_cidr_vpn_subnet
  arm_vpn_gw_subnet_id = azurerm_subnet.vpn_gateway_subnet.id

  peering_net = var.peering_net
}

