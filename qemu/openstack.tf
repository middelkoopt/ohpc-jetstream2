## Local data

resource "local_file" "ansible" {
  filename = "local.ini"
  content = <<-EOF
    ## auto-generated
    [ohpc]
    head ansible_host=localhost ansible_port=8022 ansible_user=${var.head_user} arch=x86_64

    [ohpc:vars]
    sshkey=${var.ssh_public_key}
    internal_network=10.5.0.0
    internal_netmask=255.255.0.0
    internal_gateway=10.5.0.8
    EOF
}

## Output

output "ohpc_head_ipv4" {
  value = "127.0.0.1"
}

output "ohpc_head_ipv6" {
  value = "::1"
}

output "ohpc_head_dns" {
  value = "localhost"
}

output "ohpc_head" {
  value = "localhost"
}

output "ohpc_port" {
  value = "8022"
}

output "ohpc_user" {
  value = var.head_user
}
