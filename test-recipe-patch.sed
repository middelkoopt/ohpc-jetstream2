## Fixups for local environment
/systemctl disable --now firewalld/d
s/ipmitool/: # ipmitool/g
s/pdsh/: # pdsh/g
/sleep 90/d

## Remove extra packages
/dnf -y install ohpc-gnu15-perf-tools/d

## RHEL 9
s/^ip address add/echo ip address add/g

## Local Install
#s|dnf -y install warewulf-ohpc|dnf -y install /home/admin/warewulf-ohpc-4.6.4-19999.ci.ohpc.aarch64.rpm|g
