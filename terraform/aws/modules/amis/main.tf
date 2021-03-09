locals {
  amis_yaml_regionMap = yamldecode(split("Resources", data.http.amis_yaml_http.body)[0]).Mappings.RegionMap
  amis_yaml_converterMap = yamldecode(split("Resources", data.http.amis_yaml_http.body)[0]).Mappings.ConverterMap


  //  Variables example:
  //  version_license = "R80.40-PAYG-NGTX"
  //  RESULT:
  //  version_license_key = "R80.40-PAYG-NGTX-GW"
  //  version_license_value = "R8040PAYGNGTXGW"

  version_license_key = format("%s%s", var.version_license, var.chkp_type == "gateway" ? "-GW" : var.chkp_type == "management" ? "-MGMT" : var.chkp_type == "mds" ? "-MGMT" : "")
  version_license_value = local.amis_yaml_converterMap[local.version_license_key]["Value"]

  //  Variables example:
  //  region = "us-east-1"
  //  version_license_key - see above
  //  RESULT: local.ami_id = "ami-1234567"
  ami_id = local.amis_yaml_regionMap[local.region][local.version_license_value]
}