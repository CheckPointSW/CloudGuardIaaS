resource "random_id" "ram_uuid" {
  byte_length = 5
}

resource "alicloud_ram_role" "ram_role" {
  name = local.ram_role_name
  document = <<EOF
    {
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Effect": "Allow",
          "Principal": {
            "Service": [
              "ecs.aliyuncs.com"
            ]
          }
        }
      ],
      "Version": "1"
    }
    EOF
  description = format("%s RAM role", var.gateway_name)
  force = true
}

resource "alicloud_ram_policy" "ram_policy" {
  policy_name = local.ram_policy_name
  policy_document = <<EOF
  {
    "Statement": [
      {
        "Action": [
          "ecs:*",
          "vpc:*",
          "eip:*"
        ],
        "Effect": "Allow",
        "Resource": ["*"]
      }
    ],
      "Version": "1"
  }
  EOF
  description = format("%s RAM policy", var.gateway_name)
  force = true
}

resource "alicloud_ram_role_policy_attachment" "attach" {
  policy_name = alicloud_ram_policy.ram_policy.name
  policy_type = alicloud_ram_policy.ram_policy.type
  role_name = alicloud_ram_role.ram_role.name
}