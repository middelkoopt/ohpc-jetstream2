/systemctl disable --now firewalld/d
s/ipmitool/: # ipmitool/g
s/pdsh/: # pdsh/g
/dnf -y install spack-ohpc/d
/dnf -y install lmod-defaults-gnu15-openmpi5-ohpc/d
s/dnf -y install ohpc-gnu15-/: # dnf -y install ohpc-gnu15-/g
