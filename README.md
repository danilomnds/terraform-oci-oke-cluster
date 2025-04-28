# Module - Oracle Container Engine (OKE)
[![COE](https://img.shields.io/badge/Created%20By-CCoE-blue)]()
[![HCL](https://img.shields.io/badge/language-HCL-blueviolet)](https://www.terraform.io/)
[![OCI](https://img.shields.io/badge/provider-OCI-red)](https://registry.terraform.io/providers/oracle/oci/latest)

Module developed to standardize the creation of Oracle Container Engine (OKE).

## Compatibility Matrix

| Module Version | Terraform Version | OCI Version     |
|----------------|-------------------| --------------- |
| v1.0.0         | v1.10.1           | 6.18.0          |
| v1.1.0         | v1.11.3           | 6.35.0          |

## Update Notes

| Module Version | Note | 
|----------------|-------------------|
| v1.1.0         | For automation of autoscaling and images pulling, a dynamic group created by this module. For image pulling, please use the statup_script added [here](./extra/cloudinit-system.sh). The image pulling is based on this [project](https://github.com/oracle-devrel/oke-credential-provider-for-ocir).| 


## Specifying a version

To avoid that your code get the latest module version, you can define the `?ref=***` in the URL to point to a specific version.
Note: The `?ref=***` refers a tag on the git module repo.

## Use case + RBAC
```hcl
module "oci-oke-<system>-<env>" {
  source = "git::https://github.com/danilomnds/terraform-oci-oke-cluster?ref=v1.1.0"  
  compartment_id = var.compartment_id
  defined_tags   = var.defined_tags
  endpoint_config = {    
    # endpoint subnet
    subnet_id = <subnet id>
  }
  kubernetes_version = <kubernetes_version>
  name               = oci-oke-<system>-<env>  
  options = {
    # services subnet
    service_lb_subnet_ids = [<subnet id>]
  }
  # nodes subnet
  vcn_id = <subnet id>
  # GRP_OCI_APP-ENV is the Azure AD group that you are going to grant the permissions
  groups = ["OracleIdentityCloudService/GRP_OCI_APP-ENV", "group name 2"]
}
output "cluster_id" {
  value = module.oci-oke-<system>-<env>.cluster_id
}
```

## Input variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tenancy_ocid | Tenancy ID where the Dynamic group for the OKE instances will be created | `string` | n/a | No |
| network_compartment_id | Compartment ID where the network resources are | `string` | n/a | No |
| cluster_pod_network_options | Available CNIs and network options for existing and new node pools of the cluster | `object({})` | `FLANNEL_OVERLAY` | No |
| compartment_id | The OCID of the compartment in which to create the cluster | `string` | n/a | `Yes` |
| defined_tags | Defined tags for this resource | `map(string)` | n/a | No |
| endpoint_config | The network configuration for access to the Cluster control plane | `object({})` | n/a | No |
| freeform_tags | Free-form tags for this resource | `map(string)` | n/a | No |
| image_policy_config | The image verification policy for signature validation | `object({})` | n/a | No |
| kms_key_id | The OCID of the KMS key to be used as the master encryption key for Kubernetes secret encryption | `string` | n/a | No |
| kubernetes_version | The version of Kubernetes to install into the cluster masters | `string` | n/a | `Yes` |
| name | The name of the cluster | `string` | n/a | `Yes` |
| options | Optional attributes for the cluster | `object({})` | n/a | No |
| type | Type of cluster | `string` | n/a | No |
| vcn_id | The OCID of the virtual cloud network (VCN) in which to create the cluster | `string` | n/a | `Yes` |
| groups | list of groups that will access the resource | `list(string)` | `[]` | No |

# Object variables for blocks

Please check the documentation [here](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_cluster)

## Output variables

| Name | Description |
|------|-------------|
| cluster_id | oke cluster id|

## Documentation
Oracle Container Engine: <br>
[https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_cluster](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_cluster)