locals{
    create_external_network_condition = var.external_network_cidr == "" ? false : true
    create_internal_network_condition = var.internal_network_cidr == "" ? false : true
    ICMP_traffic_condition = length(var.ICMP_traffic) == 0 ? false : true
    TCP_traffic_condition = length(var.TCP_traffic) == 0 ? false : true
    UDP_traffic_condition = length(var.UDP_traffic) == 0 ? false : true
    SCTP_traffic_condition = length(var.SCTP_traffic) == 0 ? false : true
    ESP_traffic_condition = length(var.ESP_traffic) == 0 ? false : true
}