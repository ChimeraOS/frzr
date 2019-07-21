# frzr

frzr is a deployment and automatic update mechanism for operating systems. It deploys pre-built systems via read-only btrfs subvolumes, thus ensuring safe and atomic updates.

`/home` and `/var` are separate subvolumes mounted into the read-only root.
`/etc` is made read-write via overlayfs.
