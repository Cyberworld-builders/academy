module "vpn" {
    source = "cloudposse/vpn-connection/aws"
    version = "0.20.0"

    namespace = var.namespace
    stage = var.stage
    name = var.name

    vpc_id = var.vpc_id
    vpn_gateway_amazon_side_asn = var.vpn_gateway_amazon_side_asn
    customer_gateway_bgp_asn = var.customer_gateway_bgp_asn
    customer_gateway_ip_address = var.customer_gateway_ip_address
    route_table_ids = var.route_table_ids
    vpn_connection_static_routes_only = var.vpn_connection_static_routes_only
    vpn_connection_static_routes_destinations = var.vpn_connection_static_routes_destinations
}
