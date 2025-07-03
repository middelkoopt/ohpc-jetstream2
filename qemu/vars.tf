variable "ssh_public_key" {
    type = string
}

variable "head_user" {
    type = string
    default = "admin"
}

variable "node_count" {
    type = number
    default = 1
}
