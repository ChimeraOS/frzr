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
check 'should select asset that is in `uploaded` state' $(cat test3a.dat | get_img_url stable) 'chimeraos-1_0000001.img.tar.xz'

echo
echo '==== testing channel'
check 'should select the system image asset'               $(cat test1.dat | get_img_url testing) 'chimeraos-1_0000000.img.tar.xz'
check 'should prioritize stable asset over older testing asset'  $(cat test2.dat | get_img_url testing) 'chimeraos-1_0000004.img.tar.xz'
check 'should prioritize stable asset over newer unstable asset' $(cat test2.dat | get_img_url testing) 'chimeraos-1_0000004.img.tar.xz'
check 'should select asset that is in `uploaded` state' $(cat test3b.dat | get_img_url testing) 'chimeraos-1_0000001.img.tar.xz'

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
echo '== get_boot_cfg'
check 'should return expected boot config' "$(get_boot_cfg '12_abcdef' 'initrd /12_abcdef/amd-ucode.img' 'initrd /12_abcdef/intel-ucode.img' 'ibt=off split_lock_detect=off')" \
'title 12_abcdef
linux /12_abcdef/vmlinuz-linux
initrd /12_abcdef/amd-ucode.img
initrd /12_abcdef/intel-ucode.img
initrd /12_abcdef/initramfs-linux.img
options root=LABEL=frzr_root rw rootflags=subvol=deployments/12_abcdef quiet splash loglevel=3 rd.systemd.show_status=auto rd.udev.log_priority=3 ibt=off split_lock_detect=off'



echo
echo '== get_deployment_to_delete'

base='/tmp/frzr_test/get_deployment_to_delete'
mkdir -p "${base}/config"
mkdir -p "${base}/deployments"

mkdir "${base}/deployments/3_a"
check 'should return empty if a valid deployment to delete is not found (no other deployments, no deployments in config)' $(get_deployment_to_delete '3_a' "${base}/config/boot.cfg" "${base}/deployments") ""

mkdir "${base}/deployments/4_a"
check 'should return a deployment if it is not the current version and not referenced in the boot config (one other deployment, no deployments in config)' $(get_deployment_to_delete '3_a' "${base}/config/boot.cfg" "${base}/deployments") '4_a'

get_boot_cfg '4_a' > "${base}/config/boot.cfg"
check 'should return empty if a valid deployment to delete is not found (one other deployment which is referenced in the config)' $(get_deployment_to_delete '3_a' "${base}/config/boot.cfg" "${base}/deployments") ""

mkdir "${base}/deployments/1_a"
mkdir "${base}/deployments/2_a"
check 'should select a single deployment which is not active and will not become active on next boot (three other deployments, one which is in config)' $(get_deployment_to_delete '3_a' "${base}/config/boot.cfg" "${base}/deployments") '1_a'

rm -rf "${base}"

echo
