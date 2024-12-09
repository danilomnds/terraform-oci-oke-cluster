locals {
  default_tags = {
    "IT.create_date" : formatdate("DD/MM/YY hh:mm", timeadd(timestamp(), "-3h"))
  }
  tags = merge(var.defined_tags, local.default_tags)
}
