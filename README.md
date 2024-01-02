# Zelta Testing

For convenience, I’ve provided a vm-bhyve configuration including a blank pool file called “zelta” which you can pipe into “zfs receive” to get you started:

```cat zelta-tests.zfs | zfs receive -v boot/vm/zelta.test```

(Where boot/vm is vm-bhyve’s VM configuration directory.) The  VM is configured to use the “zroot.img” file, which isn’t included (so I can practice with different OSes). To try with FreeBSD 14, you can do the following. If you use a VM name other than “zelta.test”, be sure to change the VM config file name. 

```sh
fetch https://download.freebsd.org/releases/VM-IMAGES/14.0-RELEASE/amd64/Latest/FreeBSD-14.0-RELEASE-amd64-zfs.raw.xz -o - | unxz - > /boot/vm/zelta.test/zroot.img
vm start zelta.tests
vm console zelta.tests
```

Inside the VM:

```sh
zpool import zelta
````

Next, paste or download the zelta-tests script, edit the variables at the top and run zelta-tests.

Once complete, run zelta-test again to update the three backup targets. If you see zelta/Backups/myhost, zelta/BackupsReplicate, and zelta/BackupsDepth snapshots, the tests were probably successful.

Expected errors include git and ssh warnings, "nothing to replicate" after zpull, and a "zfs create" related error in the "check all features"zelta run. Check out the example*.out files to see what some successful tests look like.

Please report any other bugs to https://github.com/bellhyve/zelta
