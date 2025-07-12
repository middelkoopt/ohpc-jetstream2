# QEMU Cluster

## Dependencies

Debian
```bash
## Tofu
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://get.opentofu.org/opentofu.gpg | sudo tee /etc/apt/keyrings/opentofu.gpg > /dev/null
curl -fsSL https://packages.opentofu.org/opentofu/tofu/gpgkey | sudo gpg --no-tty --batch --dearmor -o /etc/apt/keyrings/opentofu-repo.gpg
sudo chmod a+r /etc/apt/keyrings/opentofu.gpg /etc/apt/keyrings/opentofu-repo.gpg

echo "deb [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" | sudo tee /etc/apt/sources.list.d/opentofu.list 
echo "deb-src [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" | sudo tee -a /etc/apt/sources.list.d/opentofu.list
sudo chmod a+r /etc/apt/sources.list.d/opentofu.list

tofu init

sudo apt-get update
sudo apt-get install -y tofu

## Ansible
sudo apt-get install --yes ansible
ansible-galaxy collection install community.general

## Qemu
sudo apt-get install --yes qemu-system mkisofs
```
