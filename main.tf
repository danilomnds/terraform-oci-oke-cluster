resource "oci_identity_dynamic_group" "oke_dg" {
  #if you are deploying the resource outside your home region uncomment the line below
  #provider   = oci.home-region
  compartment_id = var.tenancy_ocid
  description    = "Dynamic group used by ${var.name}"
  matching_rule  = "ALL {instance.compartment.id = '${var.compartment_id}'}"
  name           = "dg-${var.name}"
}

resource "oci_identity_policy" "policy_dg_oke_compartment" {
  #if you are deploying the resource outside your home region uncomment the line below
  #provider   = oci.home-region
  depends_on     = [oci_identity_dynamic_group.oke_dg]
  compartment_id = var.compartment_id
  name           = "policy_${var.name}_autoscaler"
  description    = "allow scaling operations by the oke autoscaler"
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_dg.name} to manage cluster-node-pools in compartment id ${var.compartment_id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_dg.name} to manage instance-family in compartment id ${var.compartment_id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_dg.name} to use subnets in compartment id ${var.compartment_id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_dg.name} to use vnics in compartment id ${var.compartment_id}",
  "Allow dynamic-group ${oci_identity_dynamic_group.oke_dg.name} to inspect compartments in compartment id ${var.compartment_id}"]
}

resource "oci_identity_policy" "policy_dg_network_compartment" {
  #if you are deploying the resource outside your home region uncomment the line below
  #provider   = oci.home-region
  depends_on     = [oci_identity_dynamic_group.oke_dg]
  compartment_id = var.network_compartment_id
  name           = "policy_${var.name}_autoscaler"
  description    = "allow scaling operations by the oke autoscaler"
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_dg.name} to use subnets in compartment id ${var.network_compartment_id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_dg.name} to read virtual-network-family in compartment id ${var.network_compartment_id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_dg.name} to use vnics in compartment id ${var.network_compartment_id}",
  "Allow dynamic-group ${oci_identity_dynamic_group.oke_dg.name} to inspect compartments in compartment id ${var.network_compartment_id}"]
}

resource "oci_containerengine_cluster" "oke_cluster" {
  depends_on = [oci_identity_dynamic_group.oke_dg, oci_identity_policy.policy_dg_network_compartment, oci_identity_policy.policy_dg_oke_compartment]
  dynamic "cluster_pod_network_options" {
    for_each = var.cluster_pod_network_options != null ? [var.cluster_pod_network_options] : []
    content {
      cni_type = cluster_pod_network_options.value.cni_type
    }
  }
  compartment_id = var.compartment_id
  defined_tags   = local.tags
  dynamic "endpoint_config" {
    for_each = var.endpoint_config != null ? [var.endpoint_config] : []
    content {
      is_public_ip_enabled = lookup(endpoint_config.value, "is_public_ip_enabled", false)
      nsg_ids              = lookup(endpoint_config.value, "nsg_ids", null)
      subnet_id            = lookup(endpoint_config.value, "subnet_id", null)
    }
  }
  freeform_tags = var.freeform_tags
  dynamic "image_policy_config" {
    for_each = var.image_policy_config != null ? [var.image_policy_config] : []
    content {
      is_policy_enabled = lookup(image_policy_config.value, "is_policy_enabled", false)
      dynamic "key_details" {
        for_each = image_policy_config.value.key_details != null ? [image_policy_config.value.key_details] : []
        content {
          kms_key_id = lookup(key_details.value, "kms_key_id", null)
        }
      }
    }
  }
  kms_key_id         = var.kms_key_id
  kubernetes_version = var.kubernetes_version
  name               = var.name
  dynamic "options" {
    for_each = var.options != null ? [var.options] : []
    content {
      dynamic "add_ons" {
        for_each = options.value.add_ons != null ? [options.value.add_ons] : []
        content {
          is_kubernetes_dashboard_enabled = lookup(add_ons.value, "is_kubernetes_dashboard_enabled", true)
          is_tiller_enabled               = lookup(add_ons.value, "is_tiller_enabled", null)
        }
      }
      dynamic "admission_controller_options" {
        for_each = options.value.admission_controller_options != null ? [options.value.admission_controller_options] : []
        content {
          is_pod_security_policy_enabled = lookup(admission_controller_options.value, "is_pod_security_policy_enabled", null)
        }
      }
      dynamic "kubernetes_network_config" {
        for_each = options.value.kubernetes_network_config != null ? [options.value.kubernetes_network_config] : []
        content {
          pods_cidr     = lookup(kubernetes_network_config.value, "pods_cidr", "172.27.0.0/16")
          services_cidr = lookup(kubernetes_network_config.value, "services_cidr", "172.28.0.0/16")
        }
      }
      dynamic "open_id_connect_token_authentication_config" {
        for_each = options.value.open_id_connect_token_authentication_config != null ? [options.value.open_id_connect_token_authentication_config] : []
        content {
          ca_certificate                  = lookup(open_id_connect_token_authentication_config.value, "ca_certificate", null)
          client_id                       = lookup(open_id_connect_token_authentication_config.value, "client_id", null)
          groups_claim                    = lookup(open_id_connect_token_authentication_config.value, "groups_claim", null)
          groups_prefix                   = lookup(open_id_connect_token_authentication_config.value, "groups_prefix", null)
          is_open_id_connect_auth_enabled = open_id_connect_token_authentication_config.value.is_open_id_connect_auth_enabled
          issuer_url                      = lookup(open_id_connect_token_authentication_config.value, "issuer_url", null)
          dynamic "required_claims" {
            for_each = open_id_connect_token_authentication_config.value.required_claims != null ? [open_id_connect_token_authentication_config.value.required_claims] : []
            content {
              key   = lookup(required_claims.value, "key", null)
              value = lookup(required_claims.value, "value", null)
            }
          }
          signing_algorithms = lookup(open_id_connect_token_authentication_config.value, "signing_algorithms", null)
          username_claim     = lookup(open_id_connect_token_authentication_config.value, "username_claim", null)
          username_prefix    = lookup(open_id_connect_token_authentication_config.value, "username_prefix", null)
        }
      }
      dynamic "open_id_connect_discovery" {
        for_each = options.value.open_id_connect_discovery != null ? [options.value.open_id_connect_discovery] : []
        content {
          is_open_id_connect_discovery_enabled = lookup(open_id_connect_discovery.value, "is_open_id_connect_discovery_enabled", false)
        }
      }
      dynamic "persistent_volume_config" {
        for_each = options.value.persistent_volume_config != null ? [options.value.persistent_volume_config] : []
        content {
          defined_tags  = lookup(persistent_volume_config.value, "defined_tags", local.tags)
          freeform_tags = lookup(persistent_volume_config.value, "freeform_tags", null)
        }
      }
      dynamic "service_lb_config" {
        for_each = options.value.service_lb_config != null ? [options.value.service_lb_config] : []
        content {
          defined_tags  = lookup(service_lb_config.value, "defined_tags", local.tags)
          freeform_tags = lookup(service_lb_config.value, "freeform_tags", null)
        }
      }
      service_lb_subnet_ids = lookup(options.value, "service_lb_subnet_ids", null)
    }
  }
  type   = var.type
  vcn_id = var.vcn_id
  lifecycle {
    ignore_changes = [
      defined_tags["IT.create_date"], options[0].service_lb_config[0].defined_tags["IT.create_date"], options[0].persistent_volume_config[0].defined_tags["IT.create_date"]
    ]
  }
}

resource "oci_identity_policy" "oke_access" {
  #if you are deploying the resource outside your home region uncomment the line below
  #provider   = oci.home-region
  depends_on = [oci_containerengine_cluster.oke_cluster]
  for_each = {
    for group in var.groups : group => group
    if var.groups != [] && var.compartment_id != null
  }
  compartment_id = var.compartment_id
  name           = "policy_${var.name}"
  description    = "allow one or more groups to access oke and repos"
  statements = [
    "Allow group ${each.value} to use clusters in compartment id ${var.compartment_id}",
    "Allow group ${each.value} to read cluster-node-pools in compartment id ${var.compartment_id}",
    "Allow group ${each.value} to manage repos in compartment id ${var.compartment_id}",
    "Allow group ${each.value} to read metrics in compartment id ${var.compartment_id}",
    "Allow group ${each.value} to read file-systems in compartment id ${var.compartment_id}"    
  ]
}