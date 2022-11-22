resource "aws_instance" "gateway_instance" {

  network_interface {
    network_interface_id = var.external_eni_id
    device_index = 0
  }

  network_interface {
    network_interface_id = var.internal_eni_id
    device_index = 1
  }

  tags = merge({
    Name = var.gateway_name
    x-chkp-tags = format("management=%s:template=%s:ip-address=%s", var.management_server, var.configuration_template, var.control_gateway_over_public_or_private_address)
  }, var.instance_tags)


  ebs_block_device {
    device_name = "/dev/xvda"
    volume_type = "gp2"
    volume_size = var.volume_size
    encrypted = local.volume_encryption_condition ? true : false
    kms_key_id = local.volume_encryption_condition ? var.volume_encryption : ""
  }

  instance_type = var.gateway_instance_type
  key_name = var.key_name
  iam_instance_profile = var.iam_instance_profile_id

  disable_api_termination = var.disable_instance_termination

  ami = var.ami_id
  user_data = templatefile("${path.module}/gateway_userdata.yaml", {
    // script's arguments
    PasswordHash = local.gateway_password_hash_base64,
    Shell = var.admin_shell,
    SICKey = local.gateway_SICkey_base64,
    GatewayBootstrapScript = local.gateway_bootstrap_script64,
    Hostname = var.gateway_hostname,
    AllowUploadDownload = var.allow_upload_download,
    EnableCloudWatch = var.enable_cloudwatch,
    NTPPrimary = var.primary_ntp,
    NTPSecondary = var.secondary_ntp,
    EnableInstanceConnect = var.enable_instance_connect,
    OsVersion = local.version_split
  })
}
