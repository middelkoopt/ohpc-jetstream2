# Developer Notes

Ongoing developer notes.
WARNING: Some of this may be out of date, missing things, or flat out wrong!
Don't forget to delete your lease when you are done.

## Openstack Debug

```bash
openstack console log show c1
ssh -i ~/.ssh/id_rsa -R 8180 c1
scontrol update nodename=c1 state=RESUME
```

Connect to the serial port directly (second is a full console, including ctl-c).
```bash
websocat -b $(openstack console url show -f json --serial c1 | jq -r .url)
(stty raw ; websocat -b $(openstack console url show -f json --serial c1 | jq -r .url) ; stty sane)
```

## Warewulf Debug

```bash
wwctl node create debug
wwctl overlay cat --render=debug debug /tstruct.md.ww
```

## Chameleon
https://www.chameleoncloud.org/

### Create credentials

Application Credentials.  Create with all defaults, download clouds.yaml, and make sure `yq` is installed
```bash
./login.sh ~/Downloads/clouds.yaml cloud/chi.tacc.chameleoncloud.org.env
./login.sh ~/Downloads/clouds.yaml cloud/chi.uc.chameleon.env
```

### Create a reservation

Select IB based nodes with at least two active network cards (for example, `compute_cascadelake_r_ib` or `compute_haswell_ib`).  Tested at CHI@UC and CHI@TACC.  Reserve one IP, no need to reserve any network.

### Manual Config

* Create a network w/ a subnet (ohpc), disable default gateway and turn off DHCP.  Use `10.5.0.0/16` as the subnet. 
* When creating the instance, select sharednet1 as #1 and ohpc as #2.
* Turn off firewall

### Openstack
Login to OpenStack

Pick one based on the system your using
```bash
. ./auth-env.sh cloud/chi.tacc.chameleoncloud.org.env
. ./auth-env.sh cloud/chi.uc.chameleon.env
openstack project list
```

### Build Rocky9 Image

Build Image
* brew install cdrtools
* Linux OVMF file /usr/share/ovmf/OVMF.fd

```bash
touch meta-data
touch network-config
cat << EOF > user-data
#cloud-config
package_update: true
package_upgrade: true
packages:
  - kernel
  - linux-firmware
runcmd:
  - passwd -d root
power_state:
  delay: now
  mode: poweroff
  message: Powering off
  timeout: 2
  condition: true
EOF

mkisofs \
    -output seed.img \
    -volid cidata -rational-rock -joliet \
    user-data meta-data network-config

qemu-system-x86_64 -machine q35 -cpu Haswell-v4 -m 2G -smp 1 -bios OVMF.fd -drive file=head.qcow2,format=qcow2,if=virtio -drive file=seed.img,index=1,media=cdrom -nic user,model=virtio-net-pci -nographic
```

## IB

```bash
dnf install -y spack-ohpc ohpc-gnu13-openmpi5-parallel-libs \
    ohpc-gnu13-python-libs ohpc-gnu13-runtimes

dnf install -y infiniband-diags
modprobe mlx4_ib 
modprobe ib_umad 
modprobe ib_ipoib
ibstat
ibnodes

```

## OHPC Documentation

Docs build dep (Rocky)
```bash
sudo dnf install -y git epel-release
sudo dnf install -y make gawk latexmk texlive-collection-latexrecommended texlive-multirow texlive-tcolorbox
```

Doc build deps (Ubuntu/Debian/Colima)
```bash
colima ssh -- sudo apt install --yes make gawk latexmk texlive-latex-recommended texlive-latex-extra
colima ssh make
```

### Rocky clean image

Run from a base Rocky image and use `head_image = "Rocky-$VERSION-GenericCloud-Base"` in `local.tf`
```bash
VERSION=10
openstack image delete Rocky-${VERSION}-GenericCloud-Base
wget -c https://dl.rockylinux.org/pub/rocky/${VERSION}/images/x86_64/Rocky-${VERSION}-GenericCloud-Base.latest.x86_64.qcow2
openstack image create --progress --disk-format qcow2 --file Rocky-${VERSION}-GenericCloud-Base.latest.x86_64.qcow2 --property hw_firmware_type='uefi' --property hw_scsi_model='virtio-scsi' --property hw_machine_type=q35 Rocky-${VERSION}-GenericCloud-Base
openstack image show Rocky-${VERSION}-GenericCloud-Base
```

### AlmaLinux clean image

Run from a base AlmaLinux image and use `head_image = "AlmaLinux-$VERSION-GenericCloud-Base" and head_user=almalinux` in `local.tf`
```bash
VERSION=10
openstack image delete AlmaLinux-${VERSION}-GenericCloud-Base
wget -c https://repo.almalinux.org/almalinux/${VERSION}/cloud/x86_64/images/AlmaLinux-${VERSION}-GenericCloud-latest.x86_64.qcow2
openstack image create --progress --disk-format qcow2 --file AlmaLinux-${VERSION}-GenericCloud-latest.x86_64.qcow2 --property hw_firmware_type='uefi' --property hw_scsi_model='virtio-scsi' --property hw_machine_type=q35 AlmaLinux-${VERSION}-GenericCloud-Base
openstack image show AlmaLinux-${VERSION}-GenericCloud-Base
```

### OBS

OBS binary builds
* http://obs.openhpc.community:82/OpenHPC3:/3.3:/Factory/EL_9/ (dev branch)
* http://obs.openhpc.community:82/OpenHPC3:/3.x:/Dep:/Release/EL_9/x86_64/ (ohpc-release, ohpc-release-factory)

### Run a Recipe

Generate CI `recipe.sh` in target folder
```bash
../../../../parse_doc.pl steps.tex > recipe.sh
```

```bash
./test-recipe-run.sh ~/source/ohpc/docs/recipes/install/almalinux9/x86_64/warewulf4/slurm/recipe.sh
```

## HPC Ecosystems Lab 3.0

Resources
* https://github.com/HPC-Ecosystems/openhpc-3.x-virtual-lab

```bash
sms_name=head
sms_ip=10.5.0.8
internal_network=10.5.0.0/16
```

## JupyterBook

Setup local Jupyter notebook
```bash
./jupyter-lab.sh
```

After Jupyter is installed, setup remote kernel. 
This will create/overwrite a new temporary ssh key without password (`~/.ssh/id_ohpc`) to ssh into the node as root.

```bash
./jupyter-remote.sh
```

## Ubuntu Images

local.tfvars
```ini
head_image = "Featured-Minimal-Ubuntu24"
head_user = "ubuntu"
```

```bash
./create.sh
OHPC_DNS=$(tofu output -raw ohpc_dns)
while ! ssh ubuntu@$OHPC_DNS hostname ; do echo . ; sleep .2 ; done
ansible-playbook -v playbooks/system-ubuntu.yaml
ansible-playbook -v playbooks/warewulf-head.yaml
ansible-playbook -v playbooks/image-ubuntu.yaml
ansible-playbook -v playbooks/nodes.yaml
```

## OpenHPC build

Build Notes
```bash
sudo dnf update -y
/usr/bin/needs-restarting -r || sudo systemctl reboot

sudo dnf install -y git
git clone https://github.com/openhpc/ohpc.git source/ohpc
cd source/ohpc

sudo ./tests/ci/prepare-ci-environment.sh
sudo ./tests/ci/run_build.py $USER ./components/admin/docs/SPECS/docs.spec
sudo ./tests/ci/run_build.py $USER ./components/provisioning/warewulf/SPECS/warewulf.spec
```

## Warewulf OpenHPC Upgrade

* https://warewulf.org/docs/v4.6.x/server/upgrade.html
```bash
## Warning: This upgrade script is only lightly tested on a plain OpenHPC install.
## Backup your warewulf.conf and nodes.conf - these should be backed up regularly.

## Upgrade configuration (warewulf.conf, nodes.conf) 
wwctl upgrade config
wwctl upgrade nodes --with-warewulfconf=/etc/warewulf/warewulf.conf-old  --add-defaults --replace-overlays

## Verify that NFS mounts got moved over correctly (check resources in nodes.conf)

## Create a new "nodes" profile and include "generic" overlay 
wwctl profile create nodes
wwctl profile set --yes --system-overlays generic nodes
wwctl profile set --yes --profile nodes default

## Reconfig/restart
wwctl configure --all
wwctl overlay build
systemctl restart warewulfd slurmctld

## Upgrade node image
wwctl image exec --build=false rocky-9.4 -- /usr/bin/dnf config-manager --add-repo http://obs.openhpc.community:82/OpenHPC3:/3.3:/Factory/EL_9/
wwctl image exec --build=false rocky-9.4 -- /usr/bin/dnf update -y
wwctl image build rocky-9.4
```

## GPU

Check GPU
```python
import torch
# Check if CUDA is available
print(f"CUDA available: {torch.cuda.is_available()}")
if torch.cuda.is_available():
    print(f"CUDA version: {torch.version.cuda}")
    print(f"Device count: {torch.cuda.device_count()}")
    print(f"Current device: {torch.cuda.current_device()}")
    print(f"Device name: {torch.cuda.get_device_name()}")
    
    # Actually use the GPU
    x = torch.rand(5, 3).cuda()
    y = torch.rand(5, 3).cuda()
    z = x + y  # Perform an operation on GPU
    print("GPU operation successful!")
    print(z)  # Print result to verify
```

## Warewulf Build RPM

```bash
dnf config-manager --set-enabled crb
dnf install -y rpm-build

cd /usr/src/warewulf
make spec
make dist
install -dpv ~/rpmbuild/SOURCES/
install -Dv ./warewulf-*.tar.gz ~/rpmbuild/SOURCES/
dnf build-dep -y ./warewulf.spec

\rm -rf ~/rpmbuild/RPMS
rpmbuild -bb ./warewulf.spec
```

## Diskless w/ Dracut

From release
```bash
image=$(wwctl profile list nodes --json | jq -r '.nodes."image name"')
chroot=$(wwctl image show $image)
wwctl profile set --yes nodes --tagadd IPXEMenuEntry=dracut

wwctl image exec $image --build=false -- /usr/bin/mkdir -v /boot
wwctl image exec $image --build=false -- /usr/bin/dnf -y install ignition https://github.com/warewulf/warewulf/releases/download/v4.6.1/warewulf-dracut-4.6.1-1.el9.noarch.rpm
wwctl image exec $image -- /usr/bin/dracut --force --no-hostonly --add wwinit --regenerate-all
```

From local build
```bash
image=$(wwctl profile list nodes --json | jq -r '.nodes."image name"')
chroot=$(wwctl image show $image)
wwctl profile set --yes nodes --tagadd IPXEMenuEntry=dracut

install -v ~/rpmbuild/RPMS/noarch/warewulf-dracut-*.noarch.rpm ${chroot}/tmp/warewulf-dracut.rpm
wwctl image exec $image --build=false -- /usr/bin/dnf install -y ignition /tmp/warewulf-dracut.rpm
wwctl image exec $image -- /usr/bin/dracut --force --no-hostonly --add wwinit --regenerate-all
```

Direct from source
```bash
image=$(wwctl profile list nodes --json | jq -r '.nodes."image name"')
chroot=$(wwctl image show $image)
wwctl image exec --build=false $image -- /usr/bin/dnf install -y dracut-network dmidecode

wwctl profile set --yes nodes --tagadd IPXEMenuEntry=dracut
wwctl node set --yes c1 \
  --diskname /dev/vda \
  --partname EFI --partcreate --partnumber 1 --partsize=4096
wwctl node set --yes c1 \
  --diskname /dev/vda \
  --partname rootfs --partcreate --partnumber 2 \
  --fsname rootfs --fswipe --fsformat ext4 --fspath /

wwctl node set c1 --yes --root=/dev/disk/by-partlabel/rootfs
wwctl overlay build

rsync -av /usr/src/warewulf/dracut/modules.d/ $chroot/usr/lib/dracut/modules.d/ && \
  wwctl image exec $image -- \
    /usr/bin/dracut --verbose --force --no-hostonly --add wwinit --regenerate-all \
    --install sfdisk --install blockdev --install udevadm --install mkfs --install mkfs.ext4  --install wipefs

```

```
            start_mib: "1"
            size_mib: "2"
            type_guid: "C12A7328-F81F-11D2-BA4B-00A0C93EC93B"
```

Yq - https://rpmfind.net/linux/rpm2html/search.php?query=yq&submit=Search+...&system=fedora&arch=x86_64

Debugging: `curl` some data
```bash
mac=$(wwctl node list --json | jq -r '.c1."network devices".default.hwaddr')
curl -4 localhost:9873/ipxe/${mac}
curl -4 localhost:9873/overlay-file/debug/tstruct.md.ww?render=c1
curl -4 localhost:9873/overlay-file/sfdisk/warewulf/sfdisk/disks.ww?render=c1
wwctl overlay cat --render=c1 sfdisk /warewulf/sfdisk/disks.ww
wwctl overlay cat --render=c1 sfdisk /warewulf/wwinit.d/10-sfdisk.sh.ww
wwctl overlay cat --render=c1 mkfs /warewulf/wwinit.d/20-mkfs.sh.ww
```

Debug Notes
* Patch for missing file in spec
* Documentation missing for ignition file.
* Commandline must have `root=persistent wwinit.id={{id}} wwinit.ignition=http://{{.Ipaddr}}:{{.Port}}/overlay-file/persistent`
* rd.shell

## Delete

Delete warewulf configuration
```bash
wwctl node delete c[1-4] --yes
wwctl image delete nodeimage --yes
```

## Debug Notes

