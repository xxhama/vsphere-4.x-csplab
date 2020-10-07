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

variable "mac_addresses" {
  type = object({
    bootstrap = string
    masters = list(string)
    workers = list(string)
    storage = list(string)
  })
}

variable "ignition_files" {
  type = object({
    append = string
    master = string
    worker = string
  })
}