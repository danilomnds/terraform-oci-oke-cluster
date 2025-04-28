locals {
  default_tags = {
    "IT.create_date" : formatdate("DD/MM/YY hh:mm", timeadd(timestamp(), "-3h"))
  }
  tags = merge(var.defined_tags, local.default_tags)
  statement1 = [for group in var.groups : "Allow group ${group} to use clusters in compartment id ${var.compartment_id}"]
  statement2 = [for group in var.groups : "Allow group ${group} to read cluster-node-pools in compartment id ${var.compartment_id}"]  
  statement3 = [for group in var.groups : "Allow group ${group} to manage repos in compartment id ${var.compartment_id} where ALL {request.operation != 'UpdateContainerRepository', request.operation != 'UpdateDockerRepositoryMetadata', request.operation != 'CreateContainerRepository', request.operation != 'CreateDockerRepository', request.operation != 'DeleteContainerRepository'}"]
  statement4 = [for group in var.groups : "Allow group ${group} to read metrics in compartment id ${var.compartment_id}"]
  statement5 = [for group in var.groups : "Allow group ${group} to read file-systems in compartment id ${var.compartment_id}"]
  statement6 = [for group in var.groups : "Allow group ${group} to read network-load-balancers in compartment id ${var.compartment_id}"]
  statement7 = [for group in var.groups : "Allow group ${group} to read load-balancers in compartment id ${var.compartment_id}"]
  statements = concat(local.statement1, local.statement2, local.statement3, local.statement4, local.statement5, local.statement6, local.statement7)
}
