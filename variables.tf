variable "tenancy_ocid" {
  type    = string
  default = null
}

variable "network_compartment_id" {
  type    = string
  default = null
}

variable "cluster_pod_network_options" {
  type = object({
    cni_type = string
  })
  default = {
    cni_type = "FLANNEL_OVERLAY"
  }
  description = "The CNI for the cluster. Choose between flannel or npn."
}

variable "compartment_id" {
  description = "The compartment id where to create all resources."
  type        = string
}

variable "defined_tags" {
  type    = map(string)
  default = null
}

variable "endpoint_config" {
  type = object({
    is_public_ip_enabled = optional(bool)
    nsg_ids              = optional(list(string))
    subnet_id            = optional(string)
  })
  default = null
}

variable "freeform_tags" {
  type    = map(string)
  default = null
}

variable "image_policy_config" {
  type = object({
    is_policy_enabled = optional(bool)
    key_details = optional(object({
      kms_key_id = optional(string)
    }))
  })
  default = null
}

variable "kms_key_id" {
  type    = string
  default = null
}

variable "kubernetes_version" {
  type = string
}

variable "name" {
  type = string
}

variable "options" {
  type = object({
    add_ons = optional(object({
      is_kubernetes_dashboard_enabled = optional(bool)
      is_tiller_enabled               = optional(bool)
    }))
    admission_controller_options = optional(object({
      is_pod_security_policy_enabled = optional(bool)
    }))
    kubernetes_network_config = optional(object({
      pods_cidr     = optional(string)
      services_cidr = optional(string)
    }))
    open_id_connect_token_authentication_config = optional(object({
      ca_certificate                  = optional(string)
      client_id                       = optional(string)
      groups_claim                    = optional(list(string))
      groups_prefix                   = optional(string)
      is_open_id_connect_auth_enabled = bool
      issuer_url                      = optional(string)
      required_claims = optional(object({
        key   = optional(string)
        value = optional(string)
      }))
      signing_algorithms = optional(string)
      username_claim     = optional(string)
      username_prefix    = optional(string)
    }))
    open_id_connect_discovery = optional(object({
      is_open_id_connect_discovery_enabled = optional(bool)
    }))
    persistent_volume_config = optional(object({
      defined_tags  = optional(map(string))
      freeform_tags = optional(map(string))
    }))
    service_lb_config = optional(object({
      defined_tags  = optional(map(string))
      freeform_tags = optional(map(string))
    }))
    service_lb_subnet_ids = optional(list(string))
  })
  default = {
    add_ons = {
      is_kubernetes_dashboard_enabled = true
    }
    kubernetes_network_config = {
      pods_cidr     = "172.27.0.0/16"
      services_cidr = "172.28.0.0/16"
    }
  }
}

variable "type" {
  type    = string
  default = null
}

variable "vcn_id" {
  type        = string
  description = "Existing VCN id where the resources will be created"
}

variable "groups" {
  type    = list(string)
  default = []
}