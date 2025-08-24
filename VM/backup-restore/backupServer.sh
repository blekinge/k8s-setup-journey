tar --create \
	--verbose \
	--exclude /media \
	--exclude /dev \
	--exclude /run \
	--exclude /sys \
	--exclude /proc \
	--exclude /mnt \
	--exclude /tmp \
	--gzip \
	--preserve-permissions \
	--acls \
	--xattrs \
	-f server.tgz \
	/
