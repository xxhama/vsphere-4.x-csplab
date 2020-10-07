variable "openshift_binaries" {
  type = object({
    openshift_installer_url = string
    openshift_version = string
  })
}

variable "openshift_options" {
  type = object({
    master_count = number
    base_domain = string
    pull_secret = string
    public_ssh_key = string
    ignition_file_server_url = string
    ignition_file_server_port = string
  })
}

variable "platform_options" {
  type = object({
    vcenter_url = string
    username = string
    password = string
    datacenter = string
    datastore = string
    cluster_name = string
  })
}