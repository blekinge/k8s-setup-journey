#set -x
set -e


DOMAIN=$1
[ -z "$DOMAIN" ] && exit 1 

echo "Get the target disk"
TARGETS=$(virsh domblklist "$DOMAIN" --details | grep disk | awk '{print $3}')

echo "Get the names of the backup images"
BACKUPIMAGES=$(virsh domblklist "$DOMAIN" --details | grep disk | awk '{print $4}')

echo "Merge changes back"
for TARGET in $TARGETS; do
	echo virsh blockcommit "$DOMAIN" "$TARGET" --wait --active --pivot --verbose
done

echo "Cleanup left over backups"
for BACKUP in $BACKUPIMAGES; do
	echo rm -f -- "$BACKUP"
done

