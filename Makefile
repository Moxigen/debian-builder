ifndef DEB_VER
	DEB_VER:=7.1.0
endif

ifndef DEB_ARCH
	DEB_ARCH:=amd64
endif

ifndef CUSTOM_USERNAME
	CUSTOM_USERNAME:=moxie-user
endif

ifndef CUSTOM_FULLNAME
	CUSTOM_FULLNAME:=Moxie User
endif

ifndef CUSTOM_DOMAIN
	CUSTOM_DOMAIN:=moxigen.com
endif

ifndef CUSTOM_HOSTNAME
	CUSTOM_HOSTNAME:=moxie-testhost
endif

ifndef CUSTOM_TIMEZONE
	CUSTOM_TIMEZONE:=US/Central
endif

ifndef TARGET_BUILD
	TARGET_BUILD:=dev
endif
	

ISO_SOURCE_FILE:=debian-$(DEB_VER)-$(DEB_ARCH)-netinst.iso
ISO_SOURCE_URL:=http://cdimage.debian.org/debian-cd/$(DEB_VER)/$(DEB_ARCH)/iso-cd/$(ISO_SOURCE_FILE)
ISO_TARGET_FILE:=moxie-$(ISO_SOURCE_FILE);
WHO:=$(shell whoami)

default: iso
	@echo "*\n*\n*  Successfully built $(ISO_TARGET_FILE) using:"; \
	echo "*    CUSTOM_USERNAME: $(CUSTOM_USERNAME)"; \
	echo "*    CUSTOM_FULLNAME: $(CUSTOM_FULLNAME)"; \
	echo "*    CUSTOM_HOSTNAME: $(CUSTOM_HOSTNAME)"; \
	echo "*    CUSTOM_DOMAIN:   $(CUSTOM_DOMAIN)";   \
	echo "*    CUSTOM_TIMEZONE: $(CUSTOM_TIMEZONE)";   \
	echo "*    TARGET_BUILD:    $(TARGET_BUILD)";    \
	echo "*\n*";

help:
	less README

check_root:
	@if test `whoami` != 'root'; then \
		echo "*\n*\n*     You need to run as root. e.g. sudo make\n*\n*"; \
		exit 1; \
	fi

prompt:
	./prompt.sh

wget_source_iso:
	- mkdir iso_source
	wget -P iso_source -N $(ISO_SOURCE_URL);

copy_source_files:
	- mkdir mnt
	mount -o loop iso_source/$(ISO_SOURCE_FILE) mnt/
	- mkdir isofiles
	rsync -vaH mnt/ isofiles
	umount mnt

generate_preseed:
	cat preseed.d/$(DEB_VER).$(TARGET_BUILD).preseed \
	| sed -e 's|<CUSTOM_USERNAME>|$(CUSTOM_USERNAME)|' \
				-e 's|<CUSTOM_FULLNAME>|$(CUSTOM_FULLNAME)|' \
				-e 's|<CUSTOM_TIMEZONE>|$(CUSTOM_TIMEZONE)|' \
				-e 's|<CUSTOM_HOSTNAME>|$(CUSTOM_HOSTNAME)|' \
				-e 's|<CUSTOM_DOMAIN>|$(CUSTOM_DOMAIN)|' \
	> preseed.cfg

repackage_initrd_with_preseed.cfg: generate_preseed
	- mkdir workspace
	cd workspace; zcat ../isofiles/install.amd/initrd.gz | cpio -idv
	cp preseed.cfg workspace
	cd workspace; \
		find . | cpio -o -H 'newc' | gzip -c > ../isofiles/install.amd/initrd.gz

iso: check_root wget_source_iso copy_source_files  repackage_initrd_with_preseed.cfg
	cd isofiles; \
		md5sum `find -follow -type f` > md5sum.txt # Ignore file system loop error
	cp isolinux.cfg isofiles/isolinux/isolinux.cfg
	genisoimage -r -J \
		-no-emul-boot \
		-boot-load-size 4 \
		-boot-info-table \
		-b isolinux/isolinux.bin \
		-c isolinux/boot.cat \
		-o moxie-debian-${DEB_VER}-${DEB_ARCH}-netinst.iso \
		isofiles
	chmod 666 moxie-debian-${DEB_VER}-${DEB_ARCH}-netinst.iso

#
# Clean everything but the original ISO Image - Saves download time
#
cleanish: check_root
	- rm preseed.cfg
	- rm *.iso
	- rm -rf mnt
	- rm -rf workspace
	- rm -rf isofiles

clean: check_root
	- rm preseed.cfg
	- rm *.iso
	- rm -rf iso_source
	- rm -rf mnt
	- rm -rf workspace
	- rm -rf isofiles
