data "template_file" "install_config_yaml" {
  template = <<EOF
apiVersion: v1
baseDomain: ${var.openshift_options.base_domain}
compute:
- hyperthreading: Enabled
  name: worker
  replicas: 0
controlPlane:
  hyperthreading: Enabled
  name: master
  replicas: ${var.openshift_options.master_count}
metadata:
  name: ${var.platform_options.cluster_name}
platform:
  vsphere:
    vcenter: ${var.platform_options.vcenter_url}
    username: ${var.platform_options.username}
    password: ${var.platform_options.password}
    datacenter: ${var.platform_options.datacenter}
    defaultDatastore: ${var.platform_options.datastore}
pullSecret: '${chomp(base64decode(var.openshift_options.pull_secret))}'
sshKey: ${var.openshift_options.public_ssh_key}
EOF
}

data "template_file" "append_ignition_template" {
  template = <<EOF
{
"ignition": {
  "config": {
    "append": [
      {
        "source": "http://${var.openshift_options.ignition_file_server_url}:${var.openshift_options.ignition_file_server_port}/ign",
        "verification": {}
      }
    ]
  },
  "timeouts": {},
  "version": "2.1.0"
},
"networkd": {},
"passwd": {},
"storage": {},
"systemd": {}
}
EOF
}

resource "local_file" "install_config_yaml" {
  content  = data.template_file.install_config_yaml.rendered
  filename = "${local.installer_workspace}/install-config.yaml"
  depends_on = [
    null_resource.download_binaries,
  ]
}

resource "local_file" "append_ignition" {
  content = data.template_file.append_ignition_template.rendered
  filename = "${local.installer_workspace}/append.ign"
  depends_on = [
    null_resource.download_binaries
  ]
}