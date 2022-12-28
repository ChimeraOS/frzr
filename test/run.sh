#! /bin/bash

source ../__frzr-deploy

check() {
	if [ "$2" == "$3" ]; then
		echo "✓ $1"
	else
		echo "✗ $1"
		echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
		echo "expected:"
		echo "$3"
		echo
		echo "actual:"
		echo "$2"
		exit 1
	fi
}



echo
echo '== get_img_url'
echo '==== stable channel'
check 'should select the system image asset'               $(cat test1.dat | get_img_url stable) 'chimeraos-1_0000000.img.tar.xz'
check 'should prioritize latest stable asset'               $(cat test2.dat | get_img_url stable) 'chimeraos-1_0000004.img.tar.xz'
check 'should prioritize stable asset over newer testing asset'  $(cat test2.dat | get_img_url stable) 'chimeraos-1_0000004.img.tar.xz'
check 'should prioritize stable asset over newer unstable asset' $(cat test2.dat | get_img_url stable) 'chimeraos-1_0000004.img.tar.xz'
check 'should select asset that is in `uploaded` state' $(cat test3a.dat | get_img_url unstable) 'chimeraos-1_0000001.img.tar.xz'

echo
echo '==== testing channel'
check 'should select the system image asset'               $(cat test1.dat | get_img_url testing) 'chimeraos-1_0000000.img.tar.xz'
check 'should prioritize stable asset over older testing asset'  $(cat test2.dat | get_img_url testing) 'chimeraos-1_0000004.img.tar.xz'
check 'should prioritize stable asset over newer unstable asset' $(cat test2.dat | get_img_url testing) 'chimeraos-1_0000004.img.tar.xz'
check 'should select asset that is in `uploaded` state' $(cat test3b.dat | get_img_url unstable) 'chimeraos-1_0000001.img.tar.xz'

echo
echo '==== unstable channel'
check 'should select the system image asset'               $(cat test1.dat | get_img_url unstable) 'chimeraos-1_0000000.img.tar.xz'
check 'should prioritize stable asset over older testing asset'  $(cat test2.dat | get_img_url unstable) 'chimeraos-1_0000004.img.tar.xz'
check 'should prioritize stable asset over older unstable asset' $(cat test2.dat | get_img_url unstable) 'chimeraos-1_0000004.img.tar.xz'
check 'should select asset that is in `uploaded` state' $(cat test3c.dat | get_img_url unstable) 'chimeraos-1_0000001.img.tar.xz'

echo
echo '==== direct'
check 'should select newest version by default' $(cat test4.dat | get_img_url stable) 'chimeraos-2_0000002.img.tar.xz'
check 'should be able to select older versions' $(cat test4.dat | get_img_url 1) 'chimeraos-1_0000001.img.tar.xz'
check 'should select latest matching asset' $(cat test4a.dat | get_img_url 1) 'chimeraos-1_0000002.img.tar.xz'
check 'should select asset that is in `uploaded` state' $(cat test4b.dat | get_img_url 1) 'chimeraos-1_0000001.img.tar.xz'



echo
echo '== get_syslinux_dir'
base='/tmp/frzr_test/get_syslinux_dir'

check 'should return empty if no installation exists'  $(get_syslinux_dir ${base}) ""

mkdir -p "${base}/boot/syslinux"
check 'should detect BIOS installation'  $(get_syslinux_dir ${base}) "${base}/boot/syslinux"
rm -rf ${base}

mkdir -p "${base}/boot/EFI/syslinux"
check 'should detect old UEFI installation'  $(get_syslinux_dir ${base}) "${base}/boot/EFI/syslinux"
rm -rf ${base}

mkdir -p "${base}/boot/EFI/syslinux"
mkdir -p "${base}/boot/EFI/BOOT"
check 'should detect old UEFI installation even when new UEFI directory exists'  $(get_syslinux_dir ${base}) "${base}/boot/EFI/syslinux"
rm -rf ${base}

mkdir -p "${base}/boot/EFI/BOOT"
check 'should detect new UEFI installation'  $(get_syslinux_dir ${base}) "${base}/boot/EFI/BOOT"
rm -rf ${base}



echo
echo '== get_syslinux_prefix'
check 'should return correct prefix for legacy BIOS installations'  $(get_syslinux_prefix /frzr_root /frzr_root/boot/syslinux) '..'
check 'should return correct prefix for old UEFI installations'     $(get_syslinux_prefix /frzr_root /frzr_root/boot/EFI/syslinux) '../..'
check 'should return correct prefix for new UEFI installations'     $(get_syslinux_prefix /frzr_root /frzr_root/boot/EFI/BOOT) '../..'



echo
echo '== get_syslinux_cfg'
check 'should return expected syslinux config' "$(get_syslinux_cfg '12_abcdef' '../..')" \
'default 12_abcdef
label 12_abcdef
kernel ../../12_abcdef/vmlinuz-linux
append root=LABEL=frzr_root rw rootflags=subvol=deployments/12_abcdef quiet splash loglevel=3 rd.systemd.show_status=auto rd.udev.log_priority=3 ibt=off
initrd ../../12_abcdef/initramfs-linux.img'



echo
echo '== get_deployment_to_delete'

base='/tmp/frzr_test/get_deployment_to_delete'
mkdir -p "${base}/config"
mkdir -p "${base}/deployments"

mkdir "${base}/deployments/3_a"
check 'should return empty if a valid deployment to delete is not found (no other deployments, no deployments in config)' $(get_deployment_to_delete '3_a' "${base}/config/syslinux.cfg" "${base}/deployments") ""

mkdir "${base}/deployments/4_a"
check 'should return a deployment if it is not the current version and not referenced in the syslinux config (one other deployment, no deployments in config)' $(get_deployment_to_delete '3_a' "${base}/config/syslinux.cfg" "${base}/deployments") '4_a'

get_syslinux_cfg '4_a' '..' > "${base}/config/syslinux.cfg"
check 'should return empty if a valid deployment to delete is not found (one other deployment which is referenced in the config)' $(get_deployment_to_delete '3_a' "${base}/config/syslinux.cfg" "${base}/deployments") ""

mkdir "${base}/deployments/1_a"
mkdir "${base}/deployments/2_a"
check 'should select a single deployment which is not active and will not become active on next boot (three other deployments, one which is in config)' $(get_deployment_to_delete '3_a' "${base}/config/syslinux.cfg" "${base}/deployments") '1_a'

rm -rf "${base}"

echo
