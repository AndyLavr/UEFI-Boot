#1. Remount EFS partition as /boot
# Move all kernel's files to ESP partition (that is mounted in /boot/efi)
mv /boot/*-generic* /boot/efi/
# Unmount ESP partition
umount /boot/efi
# Remove all rest from /boot (it will be just mount point)
rm -rf /boot/*
# Change ESP mount path from '/boot/efi' to '/boot' 
sed -i 's/\/boot\/efi/\/boot/' /etc/fstab
# Mount ESP partition as /boot
mount /boot

#2. Copy utility files
cp usr/bin/uefiboot-update /usr/bin/
cp etc/uefiboot.conf /etc/

#3. Link utility into folders of postinst.d and postrm.d kernel triggers
ln -s /usr/bin/uefiboot-update /etc/kernel/postinst.d/uefiboot-update
ln -s /usr/bin/uefiboot-update /etc/kernel/postrm.d/uefiboot-update

#4. Make sure the utility has exec right
chmod a+x /usr/bin/uefiboot-update 

#5. Remove bootloaders
apt-get purge grub* shim os-prober

#6. Instruct APT do not install recommended dependencies (a kernel package
#   has grub in recommends but we don't need it anymore)
echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/zz-no-recommends

#7. Update UEFI boot options
uefiboot-update

#8. Set UEFI boot time-out to zero
efibootmgr -t0
