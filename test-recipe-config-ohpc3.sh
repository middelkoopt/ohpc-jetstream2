## Test Recipe Configuration for OpenHPC 3.x
# This gets sourced by the recipie.sh by setting OHPC_INPUT_LOCAL

## Head node configuration
ntp_server=pool.ntp.org
sms_name=$(hostname -f)
sms_ip=10.5.0.8
internal_netmask=255.255.0.0
internal_network=10.5.0.0
ipv4_gateway=10.5.0.1
dns_servers=8.8.8.8

## Internal network
sms_eth_internal=$(ip -j addr show to ${internal_network}/${internal_netmask} | jq -r '.[].ifname')

## Compute node configuration
eth_provision=eth0

## Cluster configuration
compute_prefix=c
num_computes=1
c_ip[0]=10.5.1.1
c_ip[1]=10.5.1.2
c_ip[2]=10.5.1.3
c_ip[3]=10.5.1.4
c_mac[0]=52:54:00:05:01:01
c_mac[1]=52:54:00:05:01:02
c_mac[2]=52:54:00:05:01:03
c_mac[3]=52:54:00:05:01:04
c_name[0]=c1
c_name[1]=c2
c_name[2]=c3
c_name[3]=c4

## Testing configuration
enable_nvidia_gpu_driver=0
provision_wait=1
update_slurm_nodeconfig=1
slurm_node_config="NodeName=c[1-4] State=UNKNOWN"

## Update MAC based on IP for pre-allocated nodes (Openstack)
for ((i=0; i<$num_computes; i++)) ; do
  ping -q -c 1 -W 0.2 ${c_ip[$i]}
  mac=$(ip -json neigh | jq -r ".[] | select(.dst == \"${c_ip[$i]}\").lladdr")
  if [[ $mac != "null" ]] ; then
    c_mac[$i]=$mac
  fi
done
echo ${c_mac[@]}

## Setup OpenHPC Repo
# Local: Enable development repo (3.4)
dnf config-manager --add-repo http://obs.openhpc.community:82/OpenHPC3:/3.4:/Factory/EL_9/
rpm --import http://obs.openhpc.community:82/OpenHPC3:/3.4:/Factory/EL_9/repodata/repomd.xml.key

# 3.1 Enable OpenHPC repository (not in recipe.sh)
ARCH=$(uname -m)
dnf install -y http://repos.openhpc.community/OpenHPC/3/EL_9/${ARCH}/ohpc-release-3-1.el9.${ARCH}.rpm
