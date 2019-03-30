# netbsd-chroot-simple

NetBSD chroot wrapper for convenience. 
It is a very tiny and simple script to use.

## Usage

```
netbsd-chroot-simple.sh [-r release] [-h] command [arguments]

init		download the binaries which version is same as this host
		(version show by "uname -r").
                *caution* You need to run "init" once for the first time.
create NAME	create  a chroot-ed system named as NAME.
enter  NAME	enter the chroot-ed system named as NAME.
list		list up chroot-ed systems.
ls		same as list command.

[EXAMPLE]
# sh netbsd-chroot-simple.sh init
# sh netbsd-chroot-simple.sh create test-001
# sh netbsd-chroot-simple.sh enter  test-001
```
By defualt, it works without -r option for the default version 
known by running "uname -r" (e.g. 8.0 / 8.0 for 8.0_STABLE).
To use a lower version system e.g. NetBSD-7.0,
```
# sh netbsd-chroot-simple.sh -r 7.0 init
# sh netbsd-chroot-simple.sh -r 7.0 create test-001
# sh netbsd-chroot-simple.sh -r 7.0 enter  test-001
```
