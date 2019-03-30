#!/bin/sh
#
# Copyright (C) 2018,2019 Ken'ichi Fukamachi
#   All rights reserved. This program is free software; you can
#   redistribute it and/or modify it under 2-Clause BSD License.
#   https://opensource.org/licenses/BSD-2-Clause
#
# mailto: fukachan@fml.org
#    web: http://www.fml.org/
#
# $FML$
# $Revision$
#        NAME: netbsd-chroot-utils.sh
# DESCRIPTION: NetBSD specific chroot wrapper for convenience.
# CODINGSTYLE: POSIX compliant (checked by running "bash --posix" this script)
#

#
# global configuration
#
 nbdist_url='ftp://ftp.jaist.ac.jp/pub/NetBSD/NetBSD-$rel/$arch/binary/sets/'
nbdist_list="base.tgz etc.tgz"
  nbpkg_url=http://basepkg.netbsd.fml.org/pub/NetBSD/nbpkg/tools/0.3.0/


#
# LIBRARIES
#
usage () {
    cat <<_USAGE_
$0 [-r release] [-h] command [arguments]

init		download the binaries which version is same as this host
		(version show by "uname -r").
                *caution* You need to run "init" once for the first time.
create NAME	create  a chroot-ed system named as NAME.
enter  NAME	enter the chroot-ed system named as NAME.
list		list up chroot-ed systems.
ls		same as list command.

[EXAMPLE]
# sh $0 init
# sh $0 create test-001
# sh $0 enter  test-001

By defualt, it works without -r option for the default version 
known by running "uname -r" (e.g. 8.0 / 8.0 for 8.0_STABLE).
To use a lower version system e.g. NetBSD-7.0,

# sh $0 -r 7.0 init
# sh $0 -r 7.0 create test-001
# sh $0 -r 7.0 enter  test-001
_USAGE_
}

env_init () {
          arch=$(uname -m)
       release=$(uname -r 					|
                 sed s/_STABLE//				|
                 awk '{printf("%2.1f\n", $1)}'			)

          name=test-$(date +%s)
    master_dir=./master/
      work_dir=./work
}

init () {
    local    arch=$1
    local     rel=$2
    local dst_dir=$master_dir/$rel

    if [ -d $dst_dir ];then
	echo "***error: $dst_dir already exists"
	exit 1
    fi

    eval nbdist_url=$nbdist_url
    (
	test -d $dst_dir || mkdir -p $dst_dir
	cd $dst_dir      || exit 1
	(
	    apply echo $nbdist_list | xargs -I % echo get %
	    echo quit
	) | /usr/bin/ftp $nbdist_url
    )
}

create () {
    local name=$1
    local  dir=$work_dir/$name

    # assert
    if [ ! -f $master_dir/$release/base.tgz ];then
	echo "***fatal: no binary to extract" 1>&2
	exit 1
    fi

    # extract *.tgz
    test -d $dir || mkdir -p $dir
    test -d $dir || exit 1
    for x in $master_dir/$release/*tgz
    do
	echo ">>> tar -C $dir -zxpf $x"
	          tar -C $dir -zxpf $x
    done

    # least init 
    name=$(basename $dir)
    touch $dir/__jail__${name}__
    
    cp -vp /etc/resolv.conf  $dir/etc/resolv.conf
    if [ -x /usr/pkg/bin/tcsh ];then
        cp -vp /usr/pkg/bin/tcsh $dir/bin/tcsh
    fi
    
    (
       cd $dir/tmp/ || exit 1
       ftp $nbpkg_url/nbpkg.sh
    )
    
    (cd $dir/dev; sh MAKEDEV all)
}    

enter () {
    local name=$1
    local  dir=$work_dir/$name

    if [ -x $dir/bin/tcsh -o -x $dir/bin/sh ];then
	/usr/sbin/chroot $dir /bin/tcsh || /usr/sbin/chroot $dir /bin/sh
    else
	echo not found $dir 1>&2
	exit 1
    fi
}

list () {
    ls $work_dir | cat
}


#
# MAIN
#
set -u

env_init

# parse options
while getopts hr: _opt
do
    case $_opt in
       h | \?) usage;   exit 0;;
       r)      release=$OPTARG;;
    esac
done
shift $(expr $OPTIND - 1)
proc=${1:-help}
name=${2:-$name}

case $proc in
        init )   init $arch $release;;
      create ) create $name         ;;
       enter )  enter $name         ;;
   list | ls )   list               ;;
           * )  usage               ;;
esac

exit 0;
