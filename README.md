# frzr

frzr is a deployment and automatic update mechanism for operating systems. It deploys pre-built systems via read-only btrfs subvolumes, thus ensuring safe and atomic updates.

`/home` and `/var` are separate subvolumes mounted into the read-only root.
`/etc` is made read-write via overlayfs.

Updates are checked once at boot time. If there is an update available the full image is downloaded and deployed to an entirely separate subvolume so as not to interfere with the running system. The updated subvolume will be used when the system is next restarted and the old subvolume deleted once it is no longer in use.
