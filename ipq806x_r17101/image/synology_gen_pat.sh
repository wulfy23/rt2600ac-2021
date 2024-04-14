#!/usr/bin/env bash

#1 folder with all the files pre tar
#2 outfile path/name
########################################TBA
#3 optional boot.cmd dir/name???
#5 possible extract rootfs to "mmcblkXpX"
#6 uboot version to check


#writes updater checksum.syno wrtbootgen.sh(in rootfs)? boot.scr booty.txt


devicebootcmdF="bootscript_synology_rt2600ac.cmd"
deviceupdaterF="updater_synology_rt2600ac"
deviceusbboottxtF="synology_booty.txt"



copyupdater() { #NB: Do not chmod +x
echo ""; echo "Copy updater: $1 to $2"; sleep 1; echo ""
if [ ! -f "$1" ]; then echo "updater src no go: $1" && return 1; fi
if [ ! -d "$(dirname $2)" ]; then echo "dest -fw no go: $(dirname $1)" && return 1; fi
cp "${1}" "${2}"
return 0
}
#if [ ! -d "`dirname $2`" ]; then echo "dest -fw no go: `dirname $1`" && return 1; fi


generatebootscr() {

outdir="$(dirname ${2})"

if [ ! -f "${1}" ]; then echo "cmd: ${1} [issue-nf]" && return 1; fi
if [ ! -d "$outdir" ]; then echo "outdir: ${outdir} [issue-nf]" && return 1; fi

echo ""
echo "######################################################"
echo "        cmd: $1"
echo "        scr: $2"
echo "######################################################"
echo ""
#echo "        outdir: $outdir"
#sleep 2

echo "Generating boot.scr from boot.cmd";

sleep 2;
echo "$MKIMAGE -C none -A arm -T script -d \"${1}\" \"${2}\""

$MKIMAGE -C none -A arm -T script -d "${1}" "${2}" || exit 1 #exit 1 untested return?

return 0
}
#echo ""; echo ""; echo "find $outdir"; find $outdir; echo ""; echo ""; #exit 1
#outdir="`dirname ${2}`"
#sleep 2; #echo "$MKIMAGE -C none -A arm -T script -d \"${1}\" \"${2}\""



BBIN="`dirname $BASH`"
FWTOOL="$BBIN/fwtool"; [ -x $FWTOOL ] || (echo "fwtool is NOT okey dokey" && exit 1)
SYNOCKSUM="$BBIN/synochecksum"; [ -x $SYNOCKSUM ] || (echo "synochecksum is NOT okey dokey" && exit 1)
MKIMAGE="$BBIN/mkimage"; [ -x $MKIMAGE ] || (echo "mkimage is NOT okey dokey" && exit 1)
#echo "############### BBIN: $BBIN"


if [ ! -f "$PWD/$devicebootcmdF" ]; then	echo "$PWD/$devicebootcmdF [nope]" && exit 1; fi
if [ ! -f "$PWD/$deviceupdaterF" ]; then	echo "$PWD/$deviceupdaterF [nope]" && exit 1; fi
if [ ! -f "$PWD/$deviceusbboottxtF" ]; then	echo "$PWD/$deviceusbboottxtF [nope]" && exit 1; fi
#deviceusbboottxtF="synology_booty.txt"



generatebootscr "$PWD/$devicebootcmdF" "$1/boot.scr"
copyupdater $PWD/$deviceupdaterF $1/updater
cp $PWD/synology_booty.txt $1/booty.txt


echo "Inspect $1"; echo "#########################################################"; (cd $1; find .)
exit 0



################################################################################
#-(cd $(TARGET_DIR); $(TAR) -cvzf $@-fw/rootfs.tgz .)
#-(cd $@     .boot; $(TAR) -cvzf $@-fw/boot.tgz .)
#-(cd $@-fw; $(TAR) -cvzf $(KDIR_    TMP)/$(IMAGE_PREFIX)-firmware.tgz .)
################################################################################
################################################################################
#+$(TAR) -cvzp --numeric-owner --o   wner=0 --group=0 --sort=name \
#    +$(if $(SOURCE_DATE_EPOCH),--mtime="@$      (SOURCE_DATE_EPOCH)") \
#    +-f $@-fw/rootfs.tgz -C $(TARGET_DIR) .
#+$(T            AR) -cvzp --numeric-owner --owner=0 --group=0 --sort=name \
#    +$(if $(S       OURCE_DATE_EPOCH),--mtime="@$(SOURCE_DATE_EPOCH)") \
#    +-f $@-fw/boot.t        gz -C $@.boot .
#+$(TAR) -cvzp --numeric-owner --owner=0 --group=0 --so  rt=name \
#    +$(if $(SOURCE_DATE_EPOCH),--mtime="@$(SOURCE_DATE_EPOCH)")      \
#    +-f $(KDIR_TMP)/$(IMAGE_PREFIX)-firmware.tgz -C $@-fw .
# endef
################################################################################




