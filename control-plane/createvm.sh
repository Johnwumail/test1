sudo mkdir -p /var/lib/libvirt/images/base
sudo cp ../payload/ubuntu-20.10-server-cloudimg-amd64.img /var/lib/libvirt/images/base/
sudo rm -rf /var/lib/libvirt/images/cp
sudo mkdir -p /var/lib/libvirt/images/cp
sudo qemu-img create -f qcow2 -F qcow2 -o backing_file=/var/lib/libvirt/images/base/ubuntu-20.10-server-cloudimg-amd64.img /var/lib/libvirt/images/cp/cp.qcow2
sudo qemu-img resize /var/lib/libvirt/images/cp/cp.qcow2 50G
sudo qemu-img info /var/lib/cp/cp.qcow2 
cat >meta-data <<EOF
local-hostname:cp
EOF

export PUB_KEY=$(cat ~/.ssh/id_rsa.pub)
echo $PUB_KEY
cat >user-data <<EOF
#cloud-config
users:
  - name: ubuntu
    ssh-authorized-keys:
      - $PUB_KEY
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: sudo
    shell: /bin/bash
runcmd:
  - echo "AllowUsers ubuntu" >> /etc/ssh/sshd_config
  - restart ssh
EOF

sudo genisoimage -output /var/lib/libvirt/images/cp/cp-cidata.iso -volid cidata -joliet -rock user-data meta-data 
virsh create cp-vm-template.xml
virsh domifaddr cp

# sudo virt-install --virt-type kvm --name cp --memory 2048 -vcpus=2 \
#  --os-variant ubuntu20.10 --disk /var/lib/libvirt/images/cp/cp.qcow2,format=qcow2,device=disk,bus=virtio \
#  --disk /var/lib/libvirt/images/cp/cp-cidata.iso,device=cdrom --import --network network=default --graphics none

