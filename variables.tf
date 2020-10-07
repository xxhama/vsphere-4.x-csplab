// vSphere Variable
variable "vsphere_options" {
  type = object({
    vcenter_url = string
    resource_pool_name = string
    datastore_cluster_name = string
    vsphere_user = string
    vsphere_password = string
    vsphere_server = string
    vsphere_datacenter = string
    cluster_folder = string
    cluster_name = string
  })
}

// OCP Variables
variable "ocp_options" {
  type = object({
    base_domain = string
    pull_secret = string
    public_ssh_key = string
    ignition_file_server_url = string
    ignition_file_server_port = number
  })
}

variable "mac_addresses" {
  type = object({
    bootstrap = string
    masters = list(string)
    workers = list(string)
    storage = list(string)
  })
}