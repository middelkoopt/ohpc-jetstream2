ssh_public_key = "ssh-rsa ...= auser@machine"

#head_image = "Featured-Minimal-Ubuntu24"
#head_user = "ubuntu"
#head_image = "AlmaLinux-9-GenericCloud-Base"
#head_user = "almalinux"
head_image = "Rocky-9-GenericCloud-Base"
head_user = "rocky"

#head_size = "m3.medium" # needed for GPU 
head_size = "m3.small"

node_count = 1
#node_size = "g3.xl" # GPU
#node_size = "m3.small" # Warewulf
node_size = "m3.quad" # OpenHPC diskless
