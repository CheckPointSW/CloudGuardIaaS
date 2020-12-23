locals {
  amis_yaml_regionMap = yamldecode(split("Resources", data.http.amis_yaml_http.body)[0]).Mappings.RegionMap
  amis_yaml_converterMap = yamldecode(split("Resources", data.http.amis_yaml_http.body)[0]).Mappings.ConverterMap


  //  Variables example:
  //  version_license = "R80.30-PAYG-NGTX-GW"
  //  RESULT: version_license_key = "R8030PAYGNGTXGW"
  version_license_key = local.amis_yaml_converterMap[var.version_license]["Value"]

  //  Variables example:
  //  region = "us-east-1"
  //  version_license_key - see above
  //  RESULT: local.ami_id = "ami-1234567"
  ami_id = local.amis_yaml_regionMap[local.region][local.version_license_key]
}