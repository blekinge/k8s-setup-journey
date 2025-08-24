
# https://www.virtkick.com/docs/how-to-restore-live-backup-on-kvm-virtual-machine.html

#Ensure that the machine to restore is not currently existing in libvirt, as they cannot coexist

#1. Copy the qcow files to the correct locations in /media/hdd-data/...
# The correct locations can be found from $DOMAIN.xml


#2. virsh define /mnt/backup/$DOMAIN/$DOMAIN.xml

#3. virsh start $DOMAIN


## NOTE ABOUT RECLAIMING SPACE


#https://www.jamescoyle.net/how-to/323-reclaim-disk-space-from-a-sparse-image-file-qcow2-vmdk
name=centos7.0
mv $name.qcow2 $name.qcow2_backup
qemu-img convert -O qcow2 $name.qcow2_backup $name.qcow2


## Next step is to reduce the nextcloud fs to a more manageable 5.5TB
https://www.systutorials.com/124416/shrinking-a-ext4-file-system-on-lvm-in-linux/
https://access.redhat.com/articles/1196333


https://chrisirwin.ca/posts/discard-with-kvm/
