resource "alicloud_instance" "gateway_instance" {
  instance_name = var.gateway_name
  instance_type = var.gateway_instance_type
  key_name = var.key_name
  image_id = var.image_id
  vswitch_id = var.vswitch_id
  security_groups = var.security_groups
  system_disk_size = var.volume_size
  system_disk_category = var.disk_category

  tags = merge({
    Name = var.gateway_name
  }, var.instance_tags)

  user_data = templatefile("${path.module}/gw_user_data.sh", {
    // script's arguments
    PasswordHash = var.gateway_password_hash,
    Shell = var.admin_shell,
    SICKey = var.gateway_SICKey,
    GatewayBootstrapScript = var.gateway_bootstrap_script,
    Hostname = var.gateway_hostname,
    AllowUploadDownload = var.allow_upload_download,
    NTPPrimary = var.primary_ntp,
    NTPSecondary = var.secondary_ntp,
    gw_new_config = local.gw_new_config
  })
}
