provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

module "amis" {
  source = "../modules/amis"

  version_license = var.gateway_version
  chkp_type = "gateway"
}

module "common_permissive_sg" {
  source = "../modules/common/permissive_sg"

  vpc_id = var.vpc_id
  resources_tag_name = var.resources_tag_name
  gateway_name = var.gateway_name
}

resource "aws_iam_instance_profile" "cluster_instance_profile" {
  path = "/"
  role = local.create_iam_role == 1 ? join("", module.cluster_iam_role.*.cluster_iam_role_name) : var.predefined_role
}

module "cluster_iam_role" {
  source = "../modules/cluster-iam-role"
  count = local.create_iam_role
}

module "attach_cloudwatch_policy" {
  source = "../modules/cloudwatch-policy"
  count = local.enable_cloudwatch_policy
  role = aws_iam_instance_profile.cluster_instance_profile.role
  tag_name = var.resources_tag_name != "" ? var.resources_tag_name : var.gateway_name
}

resource "aws_network_interface" "member_a_external_eni" {
  subnet_id = var.public_subnet_id
  security_groups = [module.common_permissive_sg.permissive_sg_id]
  description = "Member A external"
  source_dest_check = false
  lifecycle {
    ignore_changes = [private_ips_count,]
  }
  private_ips_count = 1
  tags = {
    Name = format("%s-Member_A_ExternalInterface", var.resources_tag_name != "" ? var.resources_tag_name : var.gateway_name) }
}

resource "aws_network_interface" "member_b_external_eni" {
  subnet_id = var.public_subnet_id
  security_groups = [module.common_permissive_sg.permissive_sg_id]
  description = "Member B external"
  source_dest_check = false
  tags = {
    Name = format("%s-Member_B_ExternalInterface", var.resources_tag_name != "" ? var.resources_tag_name : var.gateway_name) }
}

resource "aws_network_interface" "member_a_internal_eni" {
  subnet_id = var.private_subnet_id
  security_groups = [module.common_permissive_sg.permissive_sg_id]
  description = "Member A internal"
  source_dest_check = false
  lifecycle {
    ignore_changes = [private_ips_count,]
  }
  private_ips_count = 1
  tags = {
    Name = format("%s-Member_A_InternalInterface", var.resources_tag_name != "" ? var.resources_tag_name : var.gateway_name) }
}

resource "aws_network_interface" "member_b_internal_eni" {
  subnet_id = var.private_subnet_id
  security_groups = [module.common_permissive_sg.permissive_sg_id]
  description = "Member B internal"
  source_dest_check = false
  tags = {
    Name = format("%s-Member_B_InternalInterface", var.resources_tag_name != "" ? var.resources_tag_name : var.gateway_name) }
}

resource "aws_route" "internal_default_route" {
  count = local.internal_route_table_condition
  route_table_id = var.private_route_table
  lifecycle {
    ignore_changes = [network_interface_id,]
  }
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id = aws_network_interface.member_a_internal_eni.id
}

resource "aws_route_table_association" "private_rtb_to_private_subnet" {
  count = var.private_route_table == "" ? 0 : 1
  route_table_id = var.private_route_table
  subnet_id = var.private_subnet_id
}

resource "aws_instance" "member-a-instance" {
  depends_on = [
    aws_network_interface.member_a_external_eni,
    aws_network_interface.member_a_internal_eni
  ]

  network_interface {
    network_interface_id = aws_network_interface.member_a_external_eni.id
    device_index = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.member_a_internal_eni.id
    device_index = 1
  }

  tags = merge({
    Name = format("%s-Member-A",var.gateway_name)
  }, var.instance_tags)

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_type = "gp2"
    volume_size = var.volume_size
    encrypted = local.volume_encryption_condition
    kms_key_id = local.volume_encryption_condition ? var.volume_encryption : ""
  }
  lifecycle {
    ignore_changes = [ebs_block_device,]
  }
  instance_type = var.gateway_instance_type
  key_name = var.key_name
  iam_instance_profile = aws_iam_instance_profile.cluster_instance_profile.id

  disable_api_termination = var.disable_instance_termination

  ami = module.amis.ami_id
  user_data = templatefile("${path.module}/cluster_member_a_userdata.yaml", {
    // script's arguments
    Hostname = var.gateway_hostname,
    PasswordHash = local.gateway_password_hash_base64,
    AllowUploadDownload = var.allow_upload_download,
    EnableCloudWatch = var.enable_cloudwatch,
    NTPPrimary = var.primary_ntp,
    NTPSecondary = var.secondary_ntp,
    Shell = var.admin_shell,
    EnableInstanceConnect = var.enable_instance_connect,
    GatewayBootstrapScript = local.gateway_bootstrap_script64,
    SICKey = local.gateway_SICkey_base64,
    TokenA = var.memberAToken,
    MemberAPublicAddress =  aws_eip.member_a_eip[0].public_ip,
    AllocateAddress = var.allocate_and_associate_eip,
    OsVersion = local.version_split
  })
}

resource "aws_instance" "member-b-instance" {
  depends_on = [
    aws_network_interface.member_b_external_eni,
    aws_network_interface.member_b_internal_eni
  ]

  network_interface {
    network_interface_id = aws_network_interface.member_b_external_eni.id
    device_index = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.member_b_internal_eni.id
    device_index = 1
  }

  tags = merge({
    Name = format("%s-Member-B",var.gateway_name)
  }, var.instance_tags)

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_type = "gp2"
    volume_size = var.volume_size
    encrypted = local.volume_encryption_condition
    kms_key_id = local.volume_encryption_condition ? var.volume_encryption : ""
  }
  lifecycle {
    ignore_changes = [ebs_block_device,]
  }
  instance_type = var.gateway_instance_type
  key_name = var.key_name
  iam_instance_profile = aws_iam_instance_profile.cluster_instance_profile.id

  disable_api_termination = var.disable_instance_termination

  ami = module.amis.ami_id
  user_data = templatefile("${path.module}/cluster_member_b_userdata.yaml", {
    // script's arguments
    Hostname = var.gateway_hostname,
    PasswordHash = local.gateway_password_hash_base64,
    AllowUploadDownload = var.allow_upload_download,
    EnableCloudWatch = var.enable_cloudwatch,
    NTPPrimary = var.primary_ntp,
    NTPSecondary = var.secondary_ntp,
    Shell = var.admin_shell,
    EnableInstanceConnect = var.enable_instance_connect,
    GatewayBootstrapScript = local.gateway_bootstrap_script64,
    SICKey = local.gateway_SICkey_base64,
    TokenB = var.memberBToken,
    MemberBPublicAddress =  aws_eip.member_b_eip[0].public_ip,
    AllocateAddress = var.allocate_and_associate_eip,
    OsVersion = local.version_split
  })
}

resource "aws_eip" "cluster_eip" {
  vpc = true
}
resource "aws_eip" "member_a_eip" {
  count = var.allocate_and_associate_eip ? 1 : 0
  vpc = true
}
resource "aws_eip" "member_b_eip" {
  count = var.allocate_and_associate_eip ? 1 : 0
  vpc = true
}

resource "aws_eip_association" "cluster_address_assoc" {
  depends_on = [aws_instance.member-a-instance]
  allocation_id = aws_eip.cluster_eip.id
  lifecycle {
    ignore_changes = [
      network_interface_id, private_ip_address
    ]
  }
  network_interface_id = aws_network_interface.member_a_external_eni.id
  private_ip_address =  length(tolist(aws_network_interface.member_a_external_eni.private_ips)) > 1 ? element(tolist(setsubtract(tolist(aws_network_interface.member_a_external_eni.private_ips), [aws_network_interface.member_a_external_eni.private_ip])), 0) : ""//extracting member's secondary ip which represent the cluster ip
}
resource "aws_eip_association" "member_a_address_assoc" {
  depends_on = [aws_instance.member-a-instance]
  count = var.allocate_and_associate_eip ? 1 : 0
  allocation_id = aws_eip.member_a_eip[0].id
  network_interface_id = aws_network_interface.member_a_external_eni.id
  private_ip_address = aws_network_interface.member_a_external_eni.private_ip //primary
}
resource "aws_eip_association" "member_b_address_assoc" {
  depends_on = [aws_instance.member-b-instance]
  count = var.allocate_and_associate_eip ? 1 : 0
  allocation_id = aws_eip.member_b_eip[0].id
  network_interface_id = aws_network_interface.member_b_external_eni.id
  private_ip_address = aws_network_interface.member_b_external_eni.private_ip //primary
}

