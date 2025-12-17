#!/bin/sh
SRCTOP='apool'
TGTTOP='bpool'
SRCTREE="$SRCTOP/treetop"
TGTTREE="$TGTTOP/backups/treetop"

etch () {
	zfs list -Hro name -t filesystem $SRCTREE | tr '\n' '\0' | xargs -0 -I% -n1 \
		dd if=/dev/random of='/%/file' bs=64k count=1 > /dev/null 2>&1
	zfs list -Hro name -t volume $SRCTREE | tr '\n' '\0' | xargs -0 -I% -n1 \
		dd if=/dev/random of='/dev/zvol/%' bs=64k count=1 > /dev/null 2>&1
	zfs snapshot -r "$SRCTREE"@snap$1
}

# Clean house
zfs destroy -vR "$SRCTOP"
zfs destroy -vR "$TGTTOP"

# Create the setup tree
TGTSETUP="$TGTTOP/temp"
zelta backup "$SRCTOP" "$TGTSETUP"/sub1
zelta backup "$SRCTOP" "$TGTSETUP"/sub2/orphan
zelta backup "$SRCTOP" "${TGTSETUP}/sub3/space name"
zfs create -vsV 16G -o volmode=dev $TGTSETUP'/vol1'
# TO-DO: Add encrypted dataset

# Sync the temp tree to $SRCTREE
zelta snapshot "$TGTSETUP"@set
zelta revert --snap-name "go" "$TGTSETUP"
zelta backup --snap-name "one" "$TGTSETUP" "$SRCTREE"
zelta backup --no-snapshot "$SRCTREE" "$TGTTREE"
# TO-DO: Sync with exclude pattern


# Riddle source with special cases

# A child with no snapshot
zfs create "$SRCTREE"/sub1/child

# An orphan
zfs destroy "$SRCTREE"/sub2@one

# A diverged target
zfs snapshot "$TGTTREE/sub3/space name@blocker"

# Incremental source
zelta snapshot "$SRCTREE"/sub3@two

# Divergent snapshots of the same name
zelta snapshot "$SRCTREE"/sub2@two
zelta snapshot "$TGTTREE"/sub2@two

zelta match $SRCTREE "$TGTTREE"


#dd if=/dev/urandom of=/tmp/zelta-test-key bs=1m count=512

#zfs create -vp $SRCTREE/'minus/two/one/0/lift off'
#zfs create -vp $SRCTREE/'minus/two/one/0/lift off'
#for num in `jot 2`; do
#	etch $num
#done
#etch 1; etch 2; etch 3

#etch 8
#zelta sync "$SRCTREE" "$TGTTREE"
#zelta match "$SRCTREE" "$TGTTREE"
