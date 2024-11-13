# Cloud Posse VPN
This is a deployment of a VPN on AWS based off of the following Terraform module by Cloud Posse

https://github.com/cloudposse/terraform-aws-vpn-connection

## Explanation of Variable Values

### vpn_gateway_amazon_side_asn

```hcl
variable "vpn_gateway_amazon_side_asn" {
    description = "The Autonomous System Number (ASN) for the Amazon side of the VPN gateway. If you don't specify an ASN, the Virtual Private Gateway is created with the default ASN"
    type = number
}
```

**vpn_gateway_amazon_side_asn**

- **Description**: This variable sets the Autonomous System Number (ASN) for the Amazon side of the VPN gateway. The ASN is used in Border Gateway Protocol (BGP) to identify routing domains.

- **Purpose**:
  - In BGP, each network or routing domain is assigned an ASN. This ASN helps in routing decisions when traffic needs to pass between different autonomous systems. 
  - For AWS, this number identifies the Virtual Private Gateway (VGW) in BGP exchanges.

- **Default Value**: 
  - The default value is set to `64512`, which is one of the private ASNs recommended by IANA for use in private networks.

- **Why Change It?**
  - **Custom Routing**: If you're dealing with complex BGP routing scenarios or if you need to match an existing BGP setup with your on-premises equipment or other cloud providers, you might want to choose a different ASN.
  - **Avoid Conflicts**: If your on-premises network or another VPN connection already uses this ASN, you'd need a different one to avoid routing conflicts.
  - **Public ASN**: If you're using or plan to use public BGP routing in your setup, you might want to use a public ASN instead of the default private one.

- **Considerations**:
  - **Non-Overlapping**: The ASN for the Amazon side should not overlap with the ASN used by your Customer Gateway or any other network that you intend to connect.
  - **Consistency**: If you're managing multiple VPN connections, ensure that the ASNs are consistently managed to avoid configuration errors.
  - **Future Scalability**: If there's potential for future network expansions or changes, consider if this default private ASN will suffice or if you should plan for a public ASN.

- **Setting the Value**:
  - If you have no specific requirements and you're setting up a simple VPN connection, sticking with the default `64512` might be fine.
  - If your network architecture or future plans require a specific ASN, you would change this value. For instance, if you're integrating with another service provider or need to maintain consistency with an existing BGP configuration, you'd set this to your chosen ASN.

In your Terraform configuration, you can either keep it as the default or explicitly set it:

```yaml
vpn_gateway_amazon_side_asn = 64512  # Or your chosen ASN
```

This variable is crucial for BGP-enabled VPN setups where routing information is dynamically exchanged between your network and AWS, ensuring that traffic can be correctly routed between your on-premises network and the AWS VPC.


### customer_gateway_bgp_asn

```hcl
variable "customer_gateway_bgp_asn" {
    description = "The Customer Gateway's Border Gateway Protocol (BGP) Autonomous System Number (ASN)"
    type = number
}
```

**customer_gateway_bgp_asn**

- **Description**: This variable specifies the Border Gateway Protocol (BGP) Autonomous System Number (ASN) for the Customer Gateway. 

- **Purpose**:
  - The ASN for the Customer Gateway identifies your on-premises network or the network where your VPN device (customer gateway) resides within the BGP routing system.
  - It's used to exchange routing information with AWS, allowing for dynamic routing where both sides (AWS and your network) can automatically update each other on available routes.

- **Default Value**: 
  - The default value is set to `65000`, which falls within the range of private ASNs (64512 to 65534 for 16-bit and 4,200,000,000 to 4,294,967,294 for 32-bit). 

- **Why Change It?**
  - **Existing ASN**: If your organization already has an assigned public ASN from an Internet Registry, you would use that number to maintain consistency with your existing network setup.
  - **Avoid Conflicts**: To ensure there's no conflict with the AWS side ASN or with other networks you connect to. The Customer Gateway ASN must be different from the Amazon side ASN.
  - **Specific Requirements**: Certain network designs or ISP requirements might dictate the need for a particular ASN.

- **Considerations**:
  - **Uniqueness**: This ASN should be unique in your routing environment to prevent routing loops or misconfigurations.
  - **Public vs. Private**: 
    - **Public ASN**: If your customer gateway needs to be advertised publicly or if you're planning to expand your network reach, you might use a public ASN.
    - **Private ASN**: If the connection is solely between your network and AWS, a private ASN might suffice, especially if you're not planning on BGP peering with other external networks.
  - **Compliance**: Some organizations might have policies or regulatory requirements that mandate the use of a specific ASN range.

- **Setting the Value**:
  - If you have no specific routing needs beyond connecting to AWS, using the default private ASN might be adequate. However, if you're already using BGP with other networks or if there's a possibility of future expansion requiring BGP peering with other ISPs or cloud providers, you should consider:
    - Using your organization's existing public ASN if you have one.
    - Selecting a new public ASN if you plan on needing one in the future.

```yaml
customer_gateway_bgp_asn = 65000  # Or your chosen ASN
```

When setting this value, consider your overall network architecture, future scalability, and whether you'll be using this same ASN in other parts of your network infrastructure. If you choose to use BGP for dynamic routing with AWS, this ASN will be crucial for establishing and managing that BGP session.


### customer_gateway_ip_address

```hcl
variable "customer_gateway_ip_address" {
    description = "The IP address of the Customer Gateway's Internet-routable external interface. Set to null to not create the Customer Gateway"
    type = string
}
```

**customer_gateway_ip_address**

- **Description**: This variable specifies the IP address for the Customer Gateway's Internet-routable external interface. 

- **Purpose**:
  - This IP address is used by AWS to initiate the VPN connection to your on-premises network or your chosen VPN endpoint. 
  - It represents the public, static IP address of your VPN device or the internet-facing interface of your network that AWS will communicate with for the VPN setup.

- **Why It's Required**:
  - For AWS to establish a VPN connection, it needs to know where to send the encrypted traffic. This address is the endpoint on your network for AWS to connect to.

- **Considerations**:
  - **Static IP**: The IP must be static. Dynamic IPs can cause connectivity issues since AWS would need to know the current IP to maintain the VPN connection.
  - **Public IP**: This should be a public IP address because it needs to be accessible from the internet. If your VPN device is behind a NAT, you would use the public IP of the NAT device.
  - **NAT-T**: If your customer gateway is behind a NAT device, ensure that NAT-T (NAT Traversal) is supported by both your VPN device and AWS's configuration to deal with the NAT environment.
  - **Security**: Ensure that this IP address is securely managed because it's a critical point of entry from your network to AWS.

- **Setting the Value**:
  - You need to provide the IP address of your VPN device's external interface. This could be:
    - The public IP of your firewall, router, or dedicated VPN appliance that interfaces with the internet.
    - If behind NAT, the public IP of the NAT device.
  
  Here's how you might set it in your Terraform configuration:

  ```yaml
  customer_gateway_ip_address = "203.0.113.100"  # Replace with your actual IP
  ```

  - If you're not ready to establish the VPN or if you're just testing configurations, you might leave this empty or use a placeholder, but remember that AWS will not be able to initiate the VPN connection without a valid IP address.

- **Notes**:
  - If you change this IP address in the future (e.g., due to ISP changes or security updates), you'll need to either update the Customer Gateway configuration or recreate it with the new IP.
  - This IP address serves as the termination point for the VPN tunnels, so ensure it's reachable from AWS's network, and that your local network security policies allow incoming VPN connections from AWS's IP addresses.

By setting this variable correctly, you're ensuring that AWS knows exactly where to direct the VPN traffic, thus establishing a secure tunnel between your network and AWS's VPC.

### route_table_ids

```hcl
variable "route_table_ids" {
    description = "Route Table IDs"
    type = list(string)
}
```

**route_table_ids**

- **Description**: This variable takes a list of route table IDs to which routes from the Virtual Private Gateway (VGW) will be propagated.

- **Purpose**:
  - When you create a VPN connection in AWS, you generally want traffic from your VPC to go through the VPN to reach your on-premises network and vice versa. 
  - The route tables associated with your subnets determine where network traffic is sent. By propagating routes from the VGW to these route tables, AWS automatically adds routes to your VPN connection's CIDR blocks (or BGP learned routes) into these route tables. This means traffic destined for your VPN will be routed through the VGW.

- **Why It's Important**:
  - **Route Propagation**: This feature allows for dynamic routing. Instead of manually adding routes to each route table, AWS will automatically propagate the necessary routes, simplifying management in dynamic environments.
  - **Traffic Routing**: It ensures that traffic from your VPC subnets can reach the VPN gateway without manual configuration of each subnet's route table.

- **Considerations**:
  - **Which Route Tables?**:
    - You typically want to include route tables associated with private subnets that need access to your on-premises network through the VPN. 
    - If you have multiple route tables for different purposes (like public vs. private subnets), you'd only propagate to those route tables where the traffic needs to go through the VPN.

  - **VPC Peering and Transit Gateway**:
    - If you're using VPC peering or AWS Transit Gateway, you'll need to consider how route propagation should work in conjunction with these services.

  - **Route Overlapping**: Be mindful of potential route conflicts if you're also using static routes or routes from other services.

- **Setting the Value**:
  - You'll need the IDs of the route tables in your VPC where you want the VPN routes to be propagated. Here's how you might set this in Terraform:

    ```yaml
    route_table_ids = ["rtb-12345678", "rtb-87654321"]
    ```

  - These IDs can be obtained:
    - From the AWS Management Console by navigating to VPC -> Route Tables.
    - Via AWS CLI commands like `aws ec2 describe-route-tables`.
    - If creating route tables dynamically with Terraform, you can reference them like `aws_route_table.example.id`.

- **Notes**:
  - Ensure that these route tables are not conflicting with other routing configurations in your VPC that might prevent or override the VPN routes.
  - For high availability, you might want to propagate to all route tables associated with subnets that need VPN access, ensuring that if one subnet or route table fails, others can still route via the VPN.
  - If you're using BGP, the routes propagated will include both static routes configured on the VPN connection and those dynamically learned via BGP from your on-premises network.

By specifying the `route_table_ids`, you're ensuring that your VPN connection can effectively integrate with your VPC's network routing, allowing seamless communication between AWS resources and your on-premises or external networks.

### vpn_connection_static_routes_only

```hcl
variable "vpn_connection_static_routes_only" {
    description = "VPN Connection Static Routes Only"
    type = bool
}
```

**vpn_connection_static_routes_only**

- **Description**: This boolean variable determines whether the VPN connection should use only static routes or support dynamic routing via BGP.

- **Purpose**:
  - `true`: The VPN connection will use static routes exclusively. This means that routes to your network from AWS will not be dynamically updated; instead, you must manually specify and manage the routes.
  - `false`: The VPN connection supports dynamic routing through BGP, allowing routes to be advertised between your network and AWS automatically. 

- **Default Value**: 
  - The default is set to `true`, indicating that static routes are the initial configuration unless specified otherwise.

- **Why Choose Static Routes?**
  - **Simplicity**: Static routes are simpler to set up for environments where network topology changes infrequently.
  - **Device Compatibility**: Not all VPN devices support BGP. If your device or network does not support BGP, you'll need static routing.
  - **Control**: You might want precise control over which networks are accessible through the VPN without relying on BGP advertisements.

- **Why Use Dynamic Routing (BGP)?**
  - **Scalability**: BGP allows for easier management of routing as your network grows or changes without manual updates to static routes.
  - **Flexibility**: Dynamic routes can adapt to changes in network topology automatically, which is beneficial in dynamic cloud environments or when connecting multiple networks.
  - **Redundancy**: BGP can provide better failover capabilities if there are multiple paths to the same destination.

- **Setting the Value**:
  - If you're using static routes:

    ```yaml
    vpn_connection_static_routes_only = true
    ```

  - For BGP dynamic routing:

    ```yaml
    vpn_connection_static_routes_only = false
    ```

- **Considerations**:
  - **Device Support**: Confirm that your VPN appliance supports BGP if you decide to set this to `false`.
  - **Network Complexity**: Networks with frequent topology changes or those requiring high availability might benefit from BGP.
  - **Route Table Management**: With static routes, you'll need to manage route entries in AWS, whereas with BGP, AWS will automatically update route tables based on BGP advertisements from your network.

- **Implications**:
  - When set to `true`, you will need to explicitly define the static routes using `vpn_connection_static_routes_destinations`.
  - When set to `false`, ensure your VPN device is configured to exchange BGP information with AWS, and you'll need to provide the ASN for both sides of the connection.

Deciding on this setting depends heavily on your network infrastructure, the capabilities of your VPN equipment, your organizational requirements for routing, and how you wish to manage your network's routing policies. If you opt for dynamic routing, remember to configure BGP on your side, ensuring your BGP ASN and other details are correctly set up in both your network device and AWS configuration.

### vpn_connection_static_routes_destinations

```hcl
variable "vpn_connection_static_routes_destinations" {
    description = "VPN Connection Static Routes Destinations"
    type = list(string)
}
```

**vpn_connection_static_routes_destinations**

- **Description**: This variable takes a list of CIDR blocks that define the static routes for the VPN connection. These are the network destinations that AWS should route through the VPN tunnel.

- **Purpose**:
  - When `vpn_connection_static_routes_only` is set to `true`, these CIDR blocks specify which on-premises networks or subnets AWS should reach via the VPN connection.
  - AWS will add these routes to the route tables specified by `route_table_ids`, directing traffic destined for these networks through the VPN.

- **Default Value**: 
  - The default is set to `["10.80.1.0/24"]`, suggesting a single on-premises subnet for VPN traffic.

- **Why Set Static Routes?**
  - **Control**: Allows you to control exactly which networks are accessible via the VPN, providing a clear and static routing policy.
  - **Simplicity**: For environments with predictable, stable network topologies, static routes are straightforward to manage.
  - **Compliance**: In some scenarios, regulatory or security policies might require that only specific networks are reachable through a VPN.

- **Considerations**:
  - **Accuracy**: Ensure the CIDR blocks listed actually correspond to your on-premises networks. Incorrect entries can lead to unreachable networks or inefficient routing.
  - **Routing Order**: Remember that static routes will not dynamically adjust to changes in your on-premises network unless you update the configuration. Overlapping routes or changes in network layout require manual updates here.
  - **Propagation**: If you've enabled route propagation for your route tables, these static routes will be propagated to those tables, but they will override any BGP routes with the same destination.

- **Setting the Value**:
  - You would list all the CIDR blocks you want AWS to route through the VPN:

    ```yaml
    vpn_connection_static_routes_destinations = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
    ```

    Here, you're setting up routes to a large private network (10.0.0.0/8), part of another private network range (172.16.0.0/12), and an entire Class B network (192.168.0.0/16).

- **Notes**:
  - **Multiple Networks**: You can include multiple networks by adding more CIDR blocks to the list.
  - **Route Priority**: AWS route tables give priority to more specific routes over less specific ones. So, a /24 route would take precedence over a /16 if they overlap.
  - **Update Frequency**: If your network structure changes frequently, consider the overhead of managing static routes versus the potential benefits of dynamic routing with BGP.

By defining `vpn_connection_static_routes_destinations`, you're essentially telling AWS which parts of your network should be accessible through the VPN, providing a layer of control over your network traffic routing. Make sure these destinations match your actual on-premises network topology for effective VPN communication.