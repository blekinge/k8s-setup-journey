set -x
set -e
## NOTE THAT IF THIS FAILS, YOU NEED TO FIX THE VM

#https://gist.github.com/cabal95/e36c06e716d3328b512b

DOMAIN=$1
[ -z "$DOMAIN" ] && exit 1 

BACKUPFOLDER="${2:-$PWD/$DOMAIN}"

# Get the target disk
TARGETS=$(virsh domblklist "$DOMAIN" --details | grep disk | awk '{print $3}')

# Get the image page
IMAGES=$(virsh domblklist "$DOMAIN" --details | grep disk | awk '{print $4}')

# Create the snapshot/disk specification
DISKSPEC=""

for TARGET in $TARGETS; do
	DISKSPEC="$DISKSPEC --diskspec $TARGET,snapshot=external"
done

virsh snapshot-create-as --domain $DOMAIN --name "backup-$DOMAIN" --no-metadata --atomic --disk-only $DISKSPEC 

## DANGER WILL ROBINSON, YOU NEED TO SET THE DISKS BACK IF THIS FAILS
# Copy disk image
for IMAGE in $IMAGES; do
	NAME=$(basename "$IMAGE")
	echo "${IMAGE} -> ${NAME}"
	mkdir -p "$BACKUPFOLDER"
	#tar -c -v -z --sparse --preserve -f "${BACKUPFOLDER}/${NAME}".tar.gz "${IMAGE}"  	
	if [ -e "${BACKUPFOLDER}/${NAME}" ]; then 
		rsync --archive --human-readable --whole-file --inplace --progress "$IMAGE" "${BACKUPFOLDER}/${NAME}"
	else 
		rsync --archive --human-readable --whole-file --ignore-existing --sparse --progress "$IMAGE" "${BACKUPFOLDER}/${NAME}"
	fi
	
done


#Get the names of the backup images
BACKUPIMAGES=$(virsh domblklist "$DOMAIN" --details | grep disk | awk '{print $4}')

# Merge changes back
for TARGET in $TARGETS; do
	virsh blockcommit "$DOMAIN" "$TARGET" --wait --active --pivot --verbose
done

## DANGER PAST

# Cleanup left over backups
for BACKUP in $BACKUPIMAGES; do
	rm -f -- "$BACKUP"
done

# Dump the configuration information.
virsh dumpxml "$DOMAIN" > "$BACKUPFOLDER/$DOMAIN.xml"
