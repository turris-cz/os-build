include(utils.m4)dnl
_FEATURE_GUARD_

-- Kernel --
Install("kmod-ata-ahci", { priority = 40 })
-- File systems
forInstall(kmod-fs,autofs4,btrfs,cifs,exfat,exportfs,ext4,hfs,hfsplus,msdos,nfs,nfsd,ntfs,vfat,xfs)
-- Native language support
forInstall(kmod-nls,cp1250,cp1251,cp437,cp775,cp850,cp852,cp862,cp864,cp866,cp932,iso8859-1,iso8859-13,iso8859-15,iso8859-2,iso8859-6,iso8859-8,koi8r,utf8)
-- Disk maintenance
Install("blkdiscard", "fstrim", { priority = 40 })
-- Fix for SATA card sent with Omnia NAS pack
if board == "omnia" then
	Install("asm1062-fix", { priority = 40 })
end

-- Tools --
Install("mount-utils", "losetup", "lsblk", "blkid", "file", { priority = 40 })
Install("fdisk", "cfdisk", "hdparm", "resize2fs", "partx-utils", { priority = 40 })
Install("acl", "attr", { priority = 40 })
Install("blockd" , "smartd", "smartmontools", { priority = 40 })
Install("swap-utils", { priority = 40 })

-- File systems userspace utilities
Install("lvm2", "dosfstools", "mkhfs", "btrfs-progs", "davfs2", "e2fsprogs", "fuse-utils", "xfs-mkfs", { priority = 40 })
Install("block-mount", "badblocks", "cifsmount", "hfsfsck", "xfs-fsck", "xfs-growfs", { priority = 40 })
Install("nfs-kernel-server", "nfs-kernel-server-utils", { priority = 40 })
Install("ntfs-3g", "ntfs-3g-utils", { priority = 40 })
Install("sshfs", { priority = 40 })

-- Network
Install("wget", "rsync", "rsyncd", { priority = 40 })

-- Luci
Install("luci-app-hd-idle", { priority = 40 })

-- Samba --
if options and options.samba then
	forInstall(samba4,client,server,admin,utils)
	Install("luci-app-samba4", { priority = 40 })
end

-- DLNA --
if options and options.dlna then
	Install("luci-app-minidlna", { priority = 40 })
end

-- Transmission --
if options and options.transmission then
	Install("transmission-daemon", { priority = 40 })
	Install("luci-app-transmission", { priority = 40 })
end

-- Raid --
if options and options.raid then
	forInstall(kmod-md,linear,multipath,raid0,raid1,raid10,raid456)
	Install("mdadm", { priority = 40 })
end

-- Encryption --
if options and options.encrypt then
	Install("cryptsetup", "kmod-cryptodev", "kmod-crypto-user", { priority = 40 })
	forInstall(kmod-crypto,cbc,ctr,pcbc,des,ecb,xts)
	forInstall(kmod-crypto,cmac,crc32c,sha1,sha256,sha512,md4,md5,hmac)
	forInstall(kmod-crypto,seqiv,ccm,deflate)
end

_END_FEATURE_GUARD_
