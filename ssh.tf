# Create an SSH Key in IBM Cloud if it does not exist
resource "ibm_is_ssh_key" "ssh-key" {
  name       = "my-vsi-ssh"
  public_key = var.ssh_public_key
}