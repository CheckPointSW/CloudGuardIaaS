locals {
  images_yaml_regionMap = yamldecode(split("Resources", file("${path.module}/images.yaml"))[0]).Mappings.RegionMap
  images_yaml_converterMap = yamldecode(split("Resources", file("${path.module}/images.yaml"))[0]).Mappings.ConverterMap


  //  Variables example:
  //  version_license = "R81-BYOL-GW"
  //  RESULT:
  //  version_license_key = "R81-BYOL-GW"
  //  version_license_value = "R81BYOLGW"

  version_license_key = format("%s%s", var.version_license, var.chkp_type == "gateway" ? "-GW" : var.chkp_type == "management" ? "-MGMT" : "")
  version_license_value = local.images_yaml_converterMap[local.version_license_key]["Value"]

  //  Variables example:
  //  region = "us-east-1"
  //  version_license_key - see above
  //  RESULT: local.image_id = "m-1234567"
  image_id = local.images_yaml_regionMap[local.region][local.version_license_value]
}