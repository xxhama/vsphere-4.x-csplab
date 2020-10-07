output "kubeadm_password" {
  value = data.local_file.kubeadmin_password.content
}

output "append_ignition" {
  value = data.local_file.append_ign.content
}

output "ignition_files" {
  value = local.ignition_files
}

output "kubeadmin_password" {
  value = data.local_file.kubeadmin_password.content
}

output "kubeconfig" {
  value = data.local_file.kubeconfig.content_base64
}