data "ibm_resource_group" "resource-group-name" {
  name = var.resource_group
}

resource "ibm_resource_group" "resource-group-name" {
  count = data.ibm_resource_group.resource-group-name.id != "" ? 0 : 1

  name = var.resource_group
}