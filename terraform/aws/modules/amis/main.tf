locals {
  amis_json_regionMap = jsondecode(data.http.amis_json_http.body).Mappings.RegionMap
  amis_json_converterMap = jsondecode(data.http.amis_json_http.body).Mappings.ConverterMap

  //  Variables example:
  //  version_license = "R80.30-PAYG-NGTX-GW"
  //  RESULT: version_license_key = "R8030PAYGNGTXGW"
  version_license_key = local.amis_json_converterMap[var.version_license]["Value"]

  //  Variables example:
  //  region = "us-east-1"
  //  version_license_key - see above
  //  RESULT: local.ami_id = "ami-1234567"
  ami_id = local.amis_json_regionMap[local.region][local.version_license_key]
}