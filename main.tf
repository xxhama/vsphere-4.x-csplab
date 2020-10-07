provider "vsphere" {
  vsphere_server       = var.vsphere_options.vsphere_server
  user                 = var.vsphere_options.vsphere_user
  password             = var.vsphere_options.vsphere_password
  allow_unverified_ssl = true
  version              = "< 1.16"
}

module "ignition" {
  source = "./ignition"

  openshift_binaries = {
    openshift_installer_url = "https://mirror.openshift.com/pub/openshift-v4/clients/ocp"
    openshift_version = "stable-4.4"
  }

  openshift_options = {
    master_count = length(var.mac_addresses.masters)
    base_domain = var.ocp_options.base_domain
    pull_secret = var.ocp_options.pull_secret
    public_ssh_key = var.ocp_options.public_ssh_key
    ignition_file_server_url = var.ocp_options.ignition_file_server_url
    ignition_file_server_port = var.ocp_options.ignition_file_server_port
  }

  platform_options = {
    vcenter_url = var.vsphere_options.vcenter_url
    username = var.vsphere_options.vsphere_user
    password = var.vsphere_options.vsphere_password
    datacenter = var.vsphere_options.vsphere_datacenter
    datastore = var.vsphere_options.datastore_cluster_name
    cluster_name = var.vsphere_options.cluster_name
  }
}

module "deploy_ocp_cluster" {
  source = "./deploy_ocp_cluster"
  mac_addresses = var.mac_addresses
  vsphere_options = var.vsphere_options
  ignition_files = module.ignition.ignition_files
}