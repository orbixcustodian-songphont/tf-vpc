locals {
  vpc_id = var.existing_vpc_id != "" ? var.existing_vpc_id : (var.create_vpc ? ibm_is_vpc.vpc[0].id : data.ibm_is_vpc.existing_vpc[0].id)
}

# Define Public Gateway
resource "ibm_is_public_gateway" "public_gateway_a" {
  name = "public-gateway-zone-a"
  vpc  = local.vpc_id
  zone = "jp-tok-1"
}

resource "ibm_is_public_gateway" "public_gateway_b" {
  name = "public-gateway-zone-b"
  vpc  = local.vpc_id
  zone = "jp-tok-2"
}

resource "ibm_is_public_gateway" "public_gateway_c" {
  name = "public-gateway-zone-c"
  vpc  = local.vpc_id
  zone = "jp-tok-3"
}

data "ibm_is_vpc" "existing_vpc" {
  count = var.create_vpc || var.existing_vpc_id != "" ? 0 : 1
  name  = var.vpc_name
}

resource "ibm_is_network_acl" "allow-all" {
  name = "allow-all"
  vpc  = local.vpc_id
}

resource "ibm_is_network_acl_rule" "allow-all-outbound" {
  name        = "outbound"
  action      = "allow"
  source      = "0.0.0.0/0"
  destination = "0.0.0.0/0"
  direction   = "outbound"
  network_acl = ibm_is_network_acl.allow-all.id
  icmp {
    code = 1
    type = 1
  }
}

resource "ibm_is_network_acl_rule" "allow-all-inbound" {
  name        = "inbound"
  action      = "allow"
  source      = "0.0.0.0/0"
  destination = "0.0.0.0/0"
  direction   = "inbound"
  network_acl = ibm_is_network_acl.allow-all.id
  icmp {
    code = 1
    type = 1
  }
}

# Define Subnets in Each Zone
resource "ibm_is_subnet" "subnet_a" {
  name           = "subnet-zone-a"
  vpc            = local.vpc_id
  zone           = "jp-tok-1"
  public_gateway = ibm_is_public_gateway.public_gateway_a.id
  ipv4_cidr_block = "10.244.0.0/18"
}

resource "ibm_is_subnet" "subnet_b" {
  name           = "subnet-zone-b"
  vpc            = local.vpc_id
  zone           = "jp-tok-2"
  public_gateway = ibm_is_public_gateway.public_gateway_b.id
  ipv4_cidr_block = "10.244.64.0/18"
}

resource "ibm_is_subnet" "subnet_c" {
  name           = "subnet-zone-c"
  vpc            = local.vpc_id
  zone           = "jp-tok-3"
  public_gateway = ibm_is_public_gateway.public_gateway_c.id
  ipv4_cidr_block = "10.244.128.0/18"
}