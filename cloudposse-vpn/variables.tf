variable "namespace" {
    description = "Namespace, which could be your organization name or abbreviation"
    type = string
}

variable "stage" {
    description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
    type = string
}

variable "name" {
    description = "Name of the VPN"
    type = string
}

variable "vpc_id" {
    description = "VPC ID"
    type = string
}

variable "vpn_gateway_amazon_side_asn" {
    description = "The Autonomous System Number (ASN) for the Amazon side of the VPN gateway. If you don't specify an ASN, the Virtual Private Gateway is created with the default ASN"
    type = number
}

variable "customer_gateway_bgp_asn" {
    description = "The Customer Gateway's Border Gateway Protocol (BGP) Autonomous System Number (ASN)"
    type = number
}

variable "customer_gateway_ip_address" {
    description = "The IP address of the Customer Gateway's Internet-routable external interface. Set to null to not create the Customer Gateway"
    type = string
}

variable "route_table_ids" {
    description = "Route Table IDs"
    type = list(string)
}

variable "vpn_connection_static_routes_only" {
    description = "VPN Connection Static Routes Only"
    type = bool
}

variable "vpn_connection_static_routes_destinations" {
    description = "VPN Connection Static Routes Destinations"
    type = list(string)
}