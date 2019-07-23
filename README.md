# frzr

frzr is a deployment and automatic update mechanism for operating systems. It deploys pre-built systems via read-only btrfs subvolumes, thus ensuring safe and atomic updates that never interrupt the user.

Updated system images are downloaded at boot time and deployed to an entirely separate subvolume so as not to interfere with the currently running system. Upon next boot, the newly installed system is started and the old one is deleted, completely seamlessly and invisibly.

Persistence is handled by making `/home` and `/var` separate subvolumes mounted into the read-only root.
`/etc` is made read-write via overlayfs.
