# Define Public Gateway
resource "ibm_is_public_gateway" "public_gateway_a" {
  name = "public-gateway-zone-a"
  vpc  = ibm_is_vpc.vpc.id
  zone = "jp-tok-1"
}

resource "ibm_is_public_gateway" "public_gateway_b" {
  name = "public-gateway-zone-b"
  vpc  = ibm_is_vpc.vpc.id
  zone = "jp-tok-2"
}

resource "ibm_is_public_gateway" "public_gateway_c" {
  name = "public-gateway-zone-c"
  vpc  = ibm_is_vpc.vpc.id
  zone = "jp-tok-3"
}

# Define Address Prefixes for the VPC
resource ibm_is_vpc_address_prefix subnet_prefix_a {
  name       = "prefix-zone-a"
  vpc        = ibm_is_vpc.vpc.id
  zone       = "jp-tok-1"
  cidr       = "10.10.10.0/24"
  is_default = true
}

resource ibm_is_vpc_address_prefix subnet_prefix_b {
  name       = "prefix-zone-b"
  vpc        = ibm_is_vpc.vpc.id
  zone       = "jp-tok-2"
  cidr       = "10.20.10.0/24"
  is_default = true
}

resource ibm_is_vpc_address_prefix subnet_prefix_c {
  name       = "prefix-zone-c"
  vpc        = ibm_is_vpc.vpc.id
  zone       = "jp-tok-3"
  cidr       = "10.30.10.0/24"
  is_default = true
}

# Define Subnets in Each Zone
resource "ibm_is_subnet" "subnet_a" {
  name           = "subnet-zone-a"
  vpc            = ibm_is_vpc.vpc.id
  zone           = ibm_is_vpc_address_prefix.subnet_prefix_a.zone
  public_gateway = ibm_is_public_gateway.public_gateway_a.id
  ipv4_cidr_block = "10.10.10.0/24"
}

resource "ibm_is_subnet" "subnet_b" {
  name           = "subnet-zone-b"
  vpc            = ibm_is_vpc.vpc.id
  zone           = ibm_is_vpc_address_prefix.subnet_prefix_b.zone
  public_gateway = ibm_is_public_gateway.public_gateway_b.id
  ipv4_cidr_block = "10.20.10.0/24"
}

resource "ibm_is_subnet" "subnet_c" {
  name           = "subnet-zone-c"
  vpc            = ibm_is_vpc.vpc.id
  zone           = ibm_is_vpc_address_prefix.subnet_prefix_c.zone
  public_gateway = ibm_is_public_gateway.public_gateway_c.id
  ipv4_cidr_block = "10.30.10.0/24"
}