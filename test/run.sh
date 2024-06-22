#! /bin/bash

source ../__frzr

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
check 'should select the system image asset in stable'            $(cat test1.dat  | get_img_url stable) 'chimeraos-1_0000000.img.tar.xz'
check 'should prioritize latest stable asset'                     $(cat test2.dat  | get_img_url stable) 'chimeraos-1_0000004.img.tar.xz'
check 'should prioritize stable asset over newer testing asset'   $(cat test2.dat  | get_img_url stable) 'chimeraos-1_0000004.img.tar.xz'
check 'should prioritize stable asset over newer unstable asset'  $(cat test2.dat  | get_img_url stable) 'chimeraos-1_0000004.img.tar.xz'
check 'should prioritize uploaded stable asset over not-uploaded' $(cat test3a.dat | get_img_url stable) 'chimeraos-1_0000001.img.tar.xz'
check 'should handle non existing stable channel'                 $(cat test6.dat  | get_img_url stable) ''

echo
echo '==== testing channel'
check 'should select the system image asset in testing'            $(cat test1.dat  | get_img_url testing) 'chimeraos-2_0000000.img.tar.xz'
check 'should prioritize stable asset over older testing asset'    $(cat test2.dat  | get_img_url testing) 'chimeraos-1_0000004.img.tar.xz'
check 'should prioritize stable asset over newer unstable asset'   $(cat test2.dat  | get_img_url testing) 'chimeraos-1_0000004.img.tar.xz'
check 'should return stable when no testing asset exists'          $(cat test5.dat  | get_img_url testing) 'chimeraos-1_0000000.img.tar.xz'
check 'should prioritize uploaded testing asset over not-uploaded' $(cat test3b.dat | get_img_url testing) 'chimeraos-2_0000001.img.tar.xz'
check 'should handle non existing stable channel'                  $(cat test6.dat  | get_img_url testing) 'chimeraos-1_0000001.img.tar.xz'

echo
echo '==== unstable channel'
check 'should select the system image asset in unstable'            $(cat test1.dat  | get_img_url unstable) 'chimeraos-3_0000000.img.tar.xz'
check 'should prioritize stable asset over older testing asset'     $(cat test2.dat  | get_img_url unstable) 'chimeraos-1_0000004.img.tar.xz'
check 'should prioritize stable asset over older unstable asset'    $(cat test2.dat  | get_img_url unstable) 'chimeraos-1_0000004.img.tar.xz'
check 'should return stable when no unstable asset exists'          $(cat test5.dat  | get_img_url unstable) 'chimeraos-1_0000000.img.tar.xz'
check 'should prioritize uploaded unstable asset over not-uploaded' $(cat test3c.dat | get_img_url unstable) 'chimeraos-2_0000001.img.tar.xz'
check 'should handle non existing stable channel'                   $(cat test6.dat  | get_img_url unstable) 'chimeraos-2_0000001.img.tar.xz'

echo
echo '==== direct'
check 'should select newest version by default'                  $(cat test4.dat  | get_img_url stable) 'chimeraos-2_0000002.img.tar.xz'
check 'should be able to select older versions'                  $(cat test4.dat  | get_img_url 1)      'chimeraos-1_0000001.img.tar.xz'
check 'should be able to select older point versions'            $(cat test4.dat  | get_img_url 1-1)    'chimeraos-1-1_0000011.img.tar.xz'
check 'should select latest matching asset'                      $(cat test4a.dat | get_img_url 1)      'chimeraos-1_0000002.img.tar.xz'

echo
