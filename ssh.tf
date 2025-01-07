# Create an SSH Key in IBM Cloud if it does not exist
resource "ibm_is_ssh_key" "ssh-key" {
  name       = "${var.vpc_name}-ssh"
  public_key = local.ssh_public_key
}