provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}


resource "aws_subnet" "gwlbe_subnet1" {
  vpc_id = var.vpc_id
  availability_zone = element(var.availability_zones, 0)
  cidr_block = var.gwlbe_subnet_1_cidr
  tags = {
    Name = "GWLBe subnet 1"
    Network = "Private"
  }
}
resource "aws_route_table" "gwlbe_subnet1_rtb" {
  vpc_id = var.vpc_id
  route{
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway1.id
  }
  tags = {
    Name = "GWLBe Subnet 1 Route Table"
    Network = "Private"
  }
}
resource "aws_route_table_association" "gwlbe_subnet1_rtb_assoc" {
  subnet_id      = aws_subnet.gwlbe_subnet1.id
  route_table_id = aws_route_table.gwlbe_subnet1_rtb.id
}


resource "aws_subnet" "gwlbe_subnet2" {
  vpc_id = var.vpc_id
  availability_zone = element(var.availability_zones, 1)
  cidr_block = var.gwlbe_subnet_2_cidr
  tags = {
    Name = "GWLBe subnet 2"
    Network = "Private"
  }
}
resource "aws_route_table" "gwlbe_subnet2_rtb" {
  vpc_id = var.vpc_id
  route{
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway2.id
  }
  tags = {
    Name = "GWLBe Subnet 2 Route Table"
    Network = "Private"
  }
}
resource "aws_route_table_association" "gwlbe_subnet2_rtb_assoc" {
  subnet_id      = aws_subnet.gwlbe_subnet2.id
  route_table_id = aws_route_table.gwlbe_subnet2_rtb.id
}


resource "aws_subnet" "gwlbe_subnet3" {
  count = var.number_of_AZs >= 3 ? 1 :0
  vpc_id = var.vpc_id
  availability_zone = element(var.availability_zones, 2)
  cidr_block = var.gwlbe_subnet_3_cidr
  tags = {
    Name = "GWLBe subnet 3"
    Network = "Private"
  }
}
resource "aws_route_table" "gwlbe_subnet3_rtb" {
  count = var.number_of_AZs >= 3 ? 1 :0
  vpc_id = var.vpc_id
  route{
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway3[0].id
  }
  tags = {
    Name = "GWLBe Subnet 3 Route Table"
    Network = "Private"
  }
}
resource "aws_route_table_association" "gwlbe_subnet3_rtb_assoc" {
  count = var.number_of_AZs >= 3 ? 1 :0
  subnet_id      = aws_subnet.gwlbe_subnet3[0].id
  route_table_id = aws_route_table.gwlbe_subnet3_rtb[0].id
}


resource "aws_subnet" "gwlbe_subnet4" {
  count = var.number_of_AZs >= 4 ? 1 :0
  vpc_id = var.vpc_id
  availability_zone = element(var.availability_zones, 3)
  cidr_block = var.gwlbe_subnet_4_cidr
  tags = {
    Name = "GWLBe subnet 4"
    Network = "Private"
  }
}
resource "aws_route_table" "gwlbe_subnet4_rtb" {
  count = var.number_of_AZs >= 4 ? 1 :0
  vpc_id = var.vpc_id
  route{
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway4[0].id
  }
  tags = {
    Name = "GWLBe Subnet 4 Route Table"
    Network = "Private"
  }
}
resource "aws_route_table_association" "gwlbe_subnet4_rtb_assoc" {
  count = var.number_of_AZs >= 4 ? 1 :0
  subnet_id      = aws_subnet.gwlbe_subnet4[0].id
  route_table_id = aws_route_table.gwlbe_subnet4_rtb[0].id
}




resource "aws_subnet" "nat_gw_subnet1" {
  vpc_id = var.vpc_id
  availability_zone = element(var.availability_zones, 0)
  cidr_block = var.nat_gw_subnet_1_cidr
  tags = {
    Name = "NAT subnet 1"
    Network = "Private"
  }
}
resource "aws_route_table" "nat_gw_subnet1_rtb" {
  vpc_id = var.vpc_id
  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }
  tags = {
    Name = "NAT Subnet 1 Route Table"
    Network = "Public"
  }
}
resource "aws_route_table_association" "nat_gw_subnet1_rtb_assoc" {
  subnet_id      = aws_subnet.nat_gw_subnet1.id
  route_table_id = aws_route_table.nat_gw_subnet1_rtb.id
}

resource "aws_subnet" "nat_gw_subnet2" {
  vpc_id = var.vpc_id
  availability_zone = element(var.availability_zones, 1)
  cidr_block = var.nat_gw_subnet_2_cidr
  tags = {
    Name = "NAT subnet 2"
    Network = "Private"
  }
}
resource "aws_route_table" "nat_gw_subnet2_rtb" {
  vpc_id = var.vpc_id
  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }
  tags = {
    Name = "NAT Subnet 2 Route Table"
    Network = "Public"
  }
}
resource "aws_route_table_association" "nat_gw_subnet2_rtb_assoc" {
  subnet_id      = aws_subnet.nat_gw_subnet2.id
  route_table_id = aws_route_table.nat_gw_subnet2_rtb.id
}

resource "aws_subnet" "nat_gw_subnet3" {
  count = var.number_of_AZs >= 3 ? 1 :0
  vpc_id = var.vpc_id
  availability_zone = element(var.availability_zones, 2)
  cidr_block = var.nat_gw_subnet_3_cidr
  tags = {
    Name = "NAT subnet 3"
    Network = "Private"
  }
}
resource "aws_route_table" "nat_gw_subnet3_rtb" {
  count = var.number_of_AZs >= 3 ? 1 :0
  vpc_id = var.vpc_id
  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }
  tags = {
    Name = "NAT Subnet 3 Route Table"
    Network = "Public"
  }
}
resource "aws_route_table_association" "nat_gw_subnet3_rtb_assoc" {
  count = var.number_of_AZs >= 3 ? 1 :0
  subnet_id      = aws_subnet.nat_gw_subnet3[0].id
  route_table_id = aws_route_table.nat_gw_subnet3_rtb[0].id
}

resource "aws_subnet" "nat_gw_subnet4" {
  count = var.number_of_AZs >= 4 ? 1 :0
  vpc_id = var.vpc_id
  availability_zone = element(var.availability_zones, 3)
  cidr_block = var.nat_gw_subnet_4_cidr
  tags = {
    Name = "NAT subnet 4"
    Network = "Private"
  }
}
resource "aws_route_table" "nat_gw_subnet4_rtb" {
  count = var.number_of_AZs >= 4 ? 1 :0
  vpc_id = var.vpc_id
  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }
  tags = {
    Name = "NAT Subnet 4 Route Table"
    Network = "Public"
  }
}
resource "aws_route_table_association" "nat_gw_subnet4_rtb_assoc" {
  count = var.number_of_AZs >= 4 ? 1 :0
  subnet_id      = aws_subnet.nat_gw_subnet4[0].id
  route_table_id = aws_route_table.nat_gw_subnet4_rtb[0].id
}

module "gwlb" {
  source = "../gwlb"
    providers = {
    aws = aws
  }
  vpc_id = var.vpc_id
  subnet_ids = var.gateways_subnets

  // --- General Settings ---
  key_name = var.key_name
  enable_volume_encryption = var.enable_volume_encryption
  volume_size = var.volume_size
  enable_instance_connect = var.enable_instance_connect
  disable_instance_termination = var.disable_instance_termination
  metadata_imdsv2_required = var.metadata_imdsv2_required
  allow_upload_download = var.allow_upload_download
  management_server = var.management_server
  configuration_template = var.configuration_template
  admin_shell = var.admin_shell

  // --- Gateway Load Balancer Configuration ---
  gateway_load_balancer_name = var.gateway_load_balancer_name
  target_group_name = var.target_group_name
  connection_acceptance_required = false
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing

  // --- Check Point CloudGuard IaaS Security Gateways Auto Scaling Group Configuration ---
  gateway_name = var.gateway_name
  gateway_instance_type = var.gateway_instance_type
  minimum_group_size = var.minimum_group_size
  maximum_group_size = var.maximum_group_size
  gateway_version = var.gateway_version
  gateway_password_hash = var.gateway_password_hash
  gateway_maintenance_mode_password_hash = var.gateway_maintenance_mode_password_hash
  gateway_SICKey = var.gateway_SICKey
  gateways_provision_address_type = var.gateways_provision_address_type
  allocate_public_IP = var.allocate_public_IP
  enable_cloudwatch = var.enable_cloudwatch
  gateway_bootstrap_script = var.gateway_bootstrap_script

  // --- Check Point CloudGuard IaaS Security Management Server Configuration ---
  management_deploy = var.management_deploy
  management_instance_type = var.management_instance_type
  management_version = var.management_version
  management_password_hash = var.management_password_hash
  management_maintenance_mode_password_hash = var.management_maintenance_mode_password_hash
  gateways_policy = var.gateways_policy
  gateway_management = var.gateway_management
  admin_cidr = var.admin_cidr
  gateways_addresses = var.gateways_addresses

  volume_type = var.volume_type
}

resource "aws_vpc_endpoint" "gwlb_endpoint1" {
  depends_on = [module.gwlb, aws_subnet.gwlbe_subnet1]
  vpc_id = var.vpc_id
  vpc_endpoint_type = "GatewayLoadBalancer"
  service_name = module.gwlb.gwlb_service_name
  subnet_ids = aws_subnet.gwlbe_subnet1[*].id
  tags = {
    "Name" = "gwlb_endpoint1"
  }
}
resource "aws_vpc_endpoint" "gwlb_endpoint2" {
  depends_on = [module.gwlb, aws_subnet.gwlbe_subnet2]
  vpc_id = var.vpc_id
  vpc_endpoint_type = "GatewayLoadBalancer"
  service_name = module.gwlb.gwlb_service_name
  subnet_ids = aws_subnet.gwlbe_subnet2[*].id
  tags = {
    "Name" = "gwlb_endpoint2"
  }
}
resource "aws_vpc_endpoint" "gwlb_endpoint3" {
  count = var.number_of_AZs >= 3 ? 1 :0
  depends_on = [module.gwlb, aws_subnet.gwlbe_subnet3]
  vpc_id = var.vpc_id
  vpc_endpoint_type = "GatewayLoadBalancer"
  service_name = module.gwlb.gwlb_service_name
  subnet_ids = aws_subnet.gwlbe_subnet3[*].id
  tags = {
    "Name" = "gwlb_endpoint3"
  }
}
resource "aws_vpc_endpoint" "gwlb_endpoint4" {
  count = var.number_of_AZs >= 4 ? 1 :0
  depends_on = [module.gwlb, aws_subnet.gwlbe_subnet4]
  vpc_id = var.vpc_id
  vpc_endpoint_type = "GatewayLoadBalancer"
  service_name = module.gwlb.gwlb_service_name
  subnet_ids = aws_subnet.gwlbe_subnet4[*].id
  tags = {
    "Name" = "gwlb_endpoint4"
  }
}


resource "aws_route_table" "tgw_attachment_subnet1_rtb" {
  vpc_id = var.vpc_id
  route{
    cidr_block = "0.0.0.0/0"
    vpc_endpoint_id = aws_vpc_endpoint.gwlb_endpoint1.id
  }
  tags = {
    Name = "TGW Attachment Subnet 1 Route Table"
    Network = "Private"
  }
}
resource "aws_route_table_association" "tgw_attachment1_rtb_assoc" {
  subnet_id      = var.transit_gateway_attachment_subnet_1_id
  route_table_id = aws_route_table.tgw_attachment_subnet1_rtb.id
}
resource "aws_route_table" "tgw_attachment_subnet2_rtb" {
  vpc_id = var.vpc_id
  route{
    cidr_block = "0.0.0.0/0"
    vpc_endpoint_id = aws_vpc_endpoint.gwlb_endpoint2.id
  }
  tags = {
    Name = "TGW Attachment Subnet 2 Route Table"
    Network = "Private"
  }
}
resource "aws_route_table_association" "tgw_attachment2_rtb_assoc" {
  subnet_id      = var.transit_gateway_attachment_subnet_2_id
  route_table_id = aws_route_table.tgw_attachment_subnet2_rtb.id
}
resource "aws_route_table" "tgw_attachment_subnet3_rtb" {
  count = var.number_of_AZs >= 3 ? 1 :0
  vpc_id = var.vpc_id
  route{
    cidr_block = "0.0.0.0/0"
    vpc_endpoint_id = aws_vpc_endpoint.gwlb_endpoint3[0].id
  }
  tags = {
    Name = "TGW Attachment Subnet 3 Route Table"
    Network = "Private"
  }
}
resource "aws_route_table_association" "tgw_attachment3_rtb_assoc" {
  count = var.number_of_AZs >= 3 ? 1 :0
  subnet_id      = var.transit_gateway_attachment_subnet_3_id
  route_table_id = aws_route_table.tgw_attachment_subnet3_rtb[0].id
}
resource "aws_route_table" "tgw_attachment_subnet4_rtb" {
  count = var.number_of_AZs >= 4 ? 1 :0
  vpc_id = var.vpc_id
  route{
    cidr_block = "0.0.0.0/0"
    vpc_endpoint_id = aws_vpc_endpoint.gwlb_endpoint4[0].id
  }
  tags = {
    Name = "TGW Attachment Subnet 4 Route Table"
    Network = "Private"
  }
}
resource "aws_route_table_association" "tgw_attachment4_rtb_assoc" {
  count = var.number_of_AZs >= 4 ? 1 :0
  subnet_id      = var.transit_gateway_attachment_subnet_4_id
  route_table_id = aws_route_table.tgw_attachment_subnet4_rtb[0].id
}


resource "aws_eip" "nat_gw_public_address1" {
}
resource "aws_eip" "nat_gw_public_address2" {
}
resource "aws_eip" "nat_gw_public_address3" {
  count = var.number_of_AZs >= 3 ? 1 : 0
}
resource "aws_eip" "nat_gw_public_address4" {
  count = var.number_of_AZs >= 4 ? 1 : 0
}

resource "aws_nat_gateway" "nat_gateway1" {
  depends_on = [aws_subnet.nat_gw_subnet1, aws_eip.nat_gw_public_address1]
  allocation_id = aws_eip.nat_gw_public_address1.id
  subnet_id     = aws_subnet.nat_gw_subnet1.id

  tags = {
    Name = "NatGW1"
  }
}
resource "aws_nat_gateway" "nat_gateway2" {
  depends_on = [aws_subnet.nat_gw_subnet2, aws_eip.nat_gw_public_address2]
  allocation_id = aws_eip.nat_gw_public_address2.id
  subnet_id     = aws_subnet.nat_gw_subnet2.id

  tags = {
    Name = "NatGW2"
  }
}
resource "aws_nat_gateway" "nat_gateway3" {
  count = var.number_of_AZs >= 3 ? 1 :0
  depends_on = [aws_subnet.nat_gw_subnet3, aws_eip.nat_gw_public_address3]
  allocation_id = aws_eip.nat_gw_public_address3[0].id
  subnet_id     = aws_subnet.nat_gw_subnet3[0].id

  tags = {
    Name = "NatGW3"
  }
}
resource "aws_nat_gateway" "nat_gateway4" {
  count = var.number_of_AZs >= 4 ? 1 :0
  depends_on = [aws_subnet.nat_gw_subnet4, aws_eip.nat_gw_public_address4]
  allocation_id = aws_eip.nat_gw_public_address4[0].id
  subnet_id     = aws_subnet.nat_gw_subnet4[0].id

  tags = {
    Name = "NatGW4"
  }
}