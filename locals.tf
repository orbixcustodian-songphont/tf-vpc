locals {
  ssh_private_key_ansible = base64encode(file("${path.module}/.ssh/id_rsa_airgap"))
  ssh_private_key_artifactory = base64encode(file("${path.module}/.ssh/id_rsa_airgap"))
  ssh_private_key_file_artifactory = file("${path.module}/.ssh/id_rsa_airgap")
  rhel_image_id = "r022-d5e7a447-981e-4ffe-906e-1ff648690bf9"
  ssh_public_key = file("${path.module}/.ssh/id_rsa_airgap.pub")
  vpc_id = var.existing_vpc_id != "" ? var.existing_vpc_id : (var.create_vpc ? ibm_is_vpc.vpc[0].id : data.ibm_is_vpc.existing_vpc[0].id)
}
