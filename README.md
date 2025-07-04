# Department of Education Victoria - Melbourne Region Network Infrastructure

This repository contains Terraform code for deploying the network infrastructure in the AWS Melbourne region (ap-southeast-4) for the Department of Education Victoria.

## Repository Structure

```
de-vic-terraform-networking-vpc/
├── modules/                      # Reusable Terraform modules
└── workspaces/                   # Terraform Cloud workspaces
    ├── mel-transit-gateway/      # Transit Gateway and IPAM infrastructure
    └── mel-workload-vpcs/        # Workload VPCs and related resources
```

## Prerequisites

- Access to the Department of Education Victoria's AWS accounts
- Access to Terraform Cloud organization
- AWS CLI installed and configured (for local development)
- Git installed
- Permission to assume the `DEVicTerraformDeploymentRole` in target AWS accounts

## Workspace: mel-transit-gateway

This workspace manages core networking components including:

- Transit Gateway
- Transit Gateway route tables
- IP Address Manager (IPAM) pools
- Resource sharing via AWS RAM

### Dependencies

- Requires AWS Organization with RAM enabled
- Requires appropriate permissions to create organization-wide resources

### Key Variables

| Variable | Description | Default Value |
|----------|-------------|---------------|
| transit_gateway_name | Name of the Transit Gateway | dev-vic-mel-tgw |
| transit_gateway_asn | ASN for the Transit Gateway | 64512 |
| enable_dx_gateway | Whether to create a Direct Connect Gateway | false |
| enable_ram_sharing | Whether to share resources via RAM | true |
| principal_account_ids | List of AWS account IDs to share resources with | [] |
| ipam_name | Name of the IPAM | de-vic-ipam |
| ipam_functional_pools | Map of IPAM pools to create | See terraform.tfvars.example |

### Outputs

| Output | Description |
|--------|-------------|
| transit_gateway_id | ID of the created Transit Gateway |
| transit_gateway_route_table_ids | Map of route table IDs by name |
| ipam_pool_ids | Map of IPAM pool IDs by name |

## Workspace: mel-workload-vpcs

This workspace manages workload VPCs that attach to the Transit Gateway:

- Application VPCs with three-tier subnet design
- Transit Gateway attachments
- Security groups
- Flow logs configuration

### Dependencies

- Requires the Transit Gateway workspace to be applied first
- Depends on outputs from the Transit Gateway workspace

### Key Variables

| Variable | Description | Default Value |
|----------|-------------|---------------|
| transit_gateway_id | ID of the Transit Gateway | (Required) |
| use_ipam | Whether to use IPAM for CIDR allocation | true |
| app1_vpc_cidr | CIDR for App1 VPC (if not using IPAM) | 10.100.4.0/24 |
| app1_name | Name for App1 VPC | doevic-mel-workload-1 |
| enable_vpc_flow_logs | Whether to enable VPC Flow Logs | true |

### Outputs

| Output | Description |
|--------|-------------|
| app1_vpc_id | ID of the App1 VPC |
| app1_vpc_cidr | CIDR block of the App1 VPC |
| app1_app_subnet_ids | IDs of App1 application subnets |
| app1_data_subnet_ids | IDs of App1 data subnets |

## Deployment Order

1. First deploy the `mel-transit-gateway` workspace
2. After successful deployment, deploy the `mel-workload-vpcs` workspace

## Additional Resources

For detailed setup instructions, refer to:
- [Terraform Workspace Setup Guide](./docs/terraform-workspace-setup-guide.md)
- [Network Design Document](./docs/network-design.md)

## Support

For issues or questions, contact the Network Team at the Department of Education Victoria.

## Contributors

- Department of Education Victoria Network Team
- AWS ProServe Consulting Team