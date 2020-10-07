data "vsphere_datacenter" "dc" {
  name = var.vsphere_options.vsphere_datacenter
}
data "vsphere_datastore_cluster" "datastore_cluster" {
  name          = var.vsphere_options.datastore_cluster_name
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_resource_pool" "pool" {
  name          = var.vsphere_options.resource_pool_name
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_network" "network" {
  name          = "OCP"
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_virtual_machine" "master-worker-template" {
  name          = "Templates/CSPLAB-Supported/rhcos-4.3.0-x86_64-vmware-template"
  datacenter_id = data.vsphere_datacenter.dc.id
}
resource "vsphere_virtual_machine" "bootstrap" {
  name   = "bootstrap"
  folder = var.vsphere_options.cluster_folder
  resource_pool_id     = data.vsphere_resource_pool.pool.id
  datastore_cluster_id = data.vsphere_datastore_cluster.datastore_cluster.id

  num_cpus         = 8
  memory           = 16384
  guest_id         = data.vsphere_virtual_machine.master-worker-template.guest_id
  scsi_type        = data.vsphere_virtual_machine.master-worker-template.scsi_type
  enable_disk_uuid = true

  network_interface {
    network_id     = data.vsphere_network.network.id
    adapter_type   = data.vsphere_virtual_machine.master-worker-template.network_interface_types[0]
    mac_address    = var.mac_addresses.bootstrap
    use_static_mac = true
  }
  disk {
    label            = "disk0"
    size             = 120
    eagerly_scrub    = data.vsphere_virtual_machine.master-worker-template.disks[0].eagerly_scrub
    thin_provisioned = true
    keep_on_remove   = false
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.master-worker-template.id
  }
  vapp {
    properties = {
      "guestinfo.ignition.config.data.encoding" = "base64"
      "guestinfo.ignition.config.data"          = var.ignition_files.append
    }
  }
}
resource "vsphere_virtual_machine" "masters" {
  depends_on = [vsphere_virtual_machine.bootstrap]
  count = length(var.mac_addresses.masters)

  name   = "masters-${count.index}"
  folder = var.vsphere_options.cluster_folder
  resource_pool_id     = data.vsphere_resource_pool.pool.id
  datastore_cluster_id = data.vsphere_datastore_cluster.datastore_cluster.id

  num_cpus                  = 16
  memory                    = 65536
  guest_id                  = data.vsphere_virtual_machine.master-worker-template.guest_id
  scsi_type                 = data.vsphere_virtual_machine.master-worker-template.scsi_type
  enable_disk_uuid          = true
  wait_for_guest_ip_timeout = 10

  network_interface {
    network_id     = data.vsphere_network.network.id
    adapter_type   = data.vsphere_virtual_machine.master-worker-template.network_interface_types[0]
    mac_address    = var.mac_addresses.masters[count.index]
    use_static_mac = true
  }
  disk {
    label            = "disk0"
    size             = 128
    eagerly_scrub    = data.vsphere_virtual_machine.master-worker-template.disks[0].eagerly_scrub
    thin_provisioned = true
    keep_on_remove   = false
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.master-worker-template.id
  }
  vapp {
    properties = {
      "guestinfo.ignition.config.data.encoding" = "base64"
      "guestinfo.ignition.config.data"          = var.ignition_files.master
    }
  }
}
resource "vsphere_virtual_machine" "workers" {
  depends_on = [vsphere_virtual_machine.masters]
  count = length(var.mac_addresses.workers)

  name   = "worker-${count.index}"
  folder = var.vsphere_options.cluster_folder
  resource_pool_id     = data.vsphere_resource_pool.pool.id
  datastore_cluster_id = data.vsphere_datastore_cluster.datastore_cluster.id

  num_cpus                  = 16
  memory                    = 65536
  guest_id                  = data.vsphere_virtual_machine.master-worker-template.guest_id
  scsi_type                 = data.vsphere_virtual_machine.master-worker-template.scsi_type
  enable_disk_uuid          = true
  wait_for_guest_ip_timeout = 10

  network_interface {
    network_id     = data.vsphere_network.network.id
    adapter_type   = data.vsphere_virtual_machine.master-worker-template.network_interface_types[0]
    mac_address    = var.mac_addresses.workers[count.index]
    use_static_mac = true
  }
  disk {
    label            = "disk0"
    size             = 128
    eagerly_scrub    = data.vsphere_virtual_machine.master-worker-template.disks[0].eagerly_scrub
    thin_provisioned = true
    keep_on_remove   = false
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.master-worker-template.id
  }
  vapp {
    properties = {
      "guestinfo.ignition.config.data.encoding" = "base64"
      "guestinfo.ignition.config.data"          = var.ignition_files.worker
    }
  }
}
resource "vsphere_virtual_machine" "storage" {
  depends_on = [vsphere_virtual_machine.workers]
  count = length(var.mac_addresses.storage)

  name   = "storage-${count.index}"
  folder = var.vsphere_options.cluster_folder

  resource_pool_id     = data.vsphere_resource_pool.pool.id
  datastore_cluster_id = data.vsphere_datastore_cluster.datastore_cluster.id

  num_cpus                  = 16
  memory                    = 65536
  guest_id                  = data.vsphere_virtual_machine.master-worker-template.guest_id
  scsi_type                 = data.vsphere_virtual_machine.master-worker-template.scsi_type
  enable_disk_uuid          = true
  wait_for_guest_ip_timeout = 15

  network_interface {
    network_id     = data.vsphere_network.network.id
    adapter_type   = data.vsphere_virtual_machine.master-worker-template.network_interface_types[0]
    mac_address    = var.mac_addresses.storage[count.index]
    use_static_mac = true
  }
  disk {
    label            = "disk0"
    size             = 250
    unit_number      = 0
    eagerly_scrub    = data.vsphere_virtual_machine.master-worker-template.disks[0].eagerly_scrub
    thin_provisioned = true
    keep_on_remove   = false
  }
  disk {
    label            = "disk1"
    size             = 500
    unit_number      = 1
    eagerly_scrub    = false
    thin_provisioned = true
    keep_on_remove   = false
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.master-worker-template.id
  }
  vapp {
    properties = {
      "guestinfo.ignition.config.data.encoding" = "base64"
      "guestinfo.ignition.config.data"          = var.ignition_files.worker
    }
  }
}