/systemctl disable --now firewalld/d
s|warewulf-ohpc|/home/admin/warewulf-ohpc-4.6.3-19999.ci.ohpc.aarch64.rpm|g
s/ipmitool/: # ipmitool/g
s/pdsh/: # pdsh/g
/dnf -y install spack-ohpc/d
/dnf -y install lmod-defaults-gnu15-openmpi5-ohpc/d
s/dnf -y install ohpc-gnu15-/: # dnf -y install ohpc-gnu15-/g
