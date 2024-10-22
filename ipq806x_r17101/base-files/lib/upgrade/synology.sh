#
# Copyright (C) 2016 lede-project.org
#


#we will need e2fsck in imageMakefile and COPY_BINplatform.sh > can live without short term...












synology_get_cmdlinerootfs() {

	local rootfsdev

	if read cmdline < /proc/cmdline; then
		case "$cmdline" in
			*root=*)
				rootfsdev="${cmdline##*root=}"
				rootfsdev="${rootfsdev%% *}"
			;;
		esac


		echo "${rootfsdev}"
	fi
}









synology_get_rootfspartu() {

	local wrturootfspart
	mkdir -p /var/lock
	touch /var/lock/fw_printenv.lock

	#wrturootfspart=$(/usr/sbin/fw_printenv -n wrtbootdev 2>/dev/null)
	wrturootfspart=$(/usr/sbin/fw_printenv -n wrtrootfspart 2>/dev/null)
	echo "${wrturootfspart}"

}



synology_get_bootpartu() {

	local wrtbootpart

	mkdir -p /var/lock
	touch /var/lock/fw_printenv.lock
	wrtbootpart=$(/usr/sbin/fw_printenv -n wrtbootpart 2>/dev/null)
	echo "$wrtbootpart"
}






synology_get_bootpart() {
	echo "/dev/sda1"
}
synology_get_rootfspart() {
	#echo "sda3"
	echo "/dev/sda3"
}



synology_do_flash_usb() {

	FN="synology_do_flash"

	local tar_file=$1
	local tar_pfx="./"
	local bootpart=$2
	local rootfspart=$3

	local kernelunpack="/var/kernelunpack"					#.bin unpack


    #local kernelmax=5194304
	#local rootfsmax=36885612						#26885612 = 25.6M




    ########################## SET BASED ON mmc or sda and or the size of the destination partition



    #NO df or tr AVAILABLE #echo "which e2fsck: $(which e2fsck)"; sleep 5 NOWHICH


    #NOPE NEEDS TO BE MOUNTED FIRST!!! < fsck if command -v etc...
    bootpartavail=$(df | grep "^$bootpart" | tr -s '\t' ' ' | cut -d' ' -f2)
    rootfspartavail=$(df | grep "^$rootfspart" | tr -s '\t' ' ' | cut -d' ' -f2)



    case "$bootpart" in
        *"/dev/mmcblk"*)
                echo "set max sizes based on internal mmc"; sleep 3
                local kernelmax=5194304
                local rootfsmax=36885612						#26885612 = 25.6M
            ;;
        *"/dev/sd"*)
                echo "set max sizes based on usb and or actual device size"; sleep 3
                local kernelmax=5194304
                local rootfsmax=76885612
                #kernelmax=$bootpartavail-100000/ORfree
                #rootfsmax=$rootfsavail-10000/ORfree-50000000(akatypicallargelastrootfs)
            ;;
        *)
                echo "set max sizes based on unknown bootpart: $bootpart"; sleep 3
                local kernelmax=5194304
                local rootfsmax=36885612						#26885612 = 25.6M
        ;;
    esac; sleep 2







    ########################################manualtest
	#tar_file="/firmware.bin"
	#tar_pfx="./"
	#kernelmax=5194304 #4194304 # ~ 4M
	#rootfsmax=36885612 #26885612 = 25.6M
	#synology_do_flash_usb
	################################################


	echo "$FN> begin"; sleep 2



	echo ""
	echo "         tarfile: $1"
	echo "        bootpart: $bootpart"
	echo "      rootfspart: $rootfspart"
	echo ""
    sleep 3




    echo "   bootpartavail: $bootpartavail"
	echo " rootfspartavail: $rootfspartavail"
    sleep 3





    #####################################################################################################################
	#sysuprade -X "many extra opts" > if [ ! -z -X ] then export EXTRAOPTIONS >
	#COMMAND='/lib/upgrade/do_stage2 $EXTRAOPTIONS? > plaform >' #fold='init' #<cleanrootfsloop
    #####################################################################################################################
	#export EXTRAOPTIONSa="dodo"
	#COMMAND='/lib/upgrade/do_stage2 $EXTRAOPTIONSa'
	#NOPE > unless maybe use param in do_stage2
	######################THERE but all static... could technically "copydataflagfiles" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	#RAMFS_COPY_BIN='fw_printenv fw_setenv e2fsck'
	#RAMFS_COPY_DATA='/etc/fw_env.config /var/lock/fw_printenv.lock'
	#RAM_ROOT='/tmp/root'
    ####################################################################################################################
	#COMMAND='/lib/upgrade/do_stage2' #fold='init' #<cleanrootfsloop
	#cat /lib/upgrade/do_stage2
    ####################################################################################################################









    #echo "whats my PATH: $PATH"; sleep 5 #PATH: /usr/sbin:/usr/bin:/sbin:/bin
    #########################################################################################################
	#echo "find / | grep e2fsck"; sleep 2; find / | grep e2fsck #/tmp/root/usr/sbin/e2fsck + /usr/sbin/e2fsck ?
    if command -v e2fsck; then
        echo "e2fsck [present]" && sleep 5
    fi
	#e2fsck || fsck.ext2 etc symlinks #echo "e2fsck"; sleep 2; e2fsck; sleep 2 #echo "fsck.ext2"; sleep 2; fsck.ext2; sleep 2
	#ext2 var?


    ######################## WE SHOULD DO INITIAL TAR CONTENT VALIDATION EARLIERHERE



    mkdir -p /boot #NEEDS TO BE REMOVED LATER... ??? one too may boot/ somewhere either p1?



	echo "mount -t ext2 $bootpart /boot"
	if ! mount -t ext2 $bootpart /boot; then
		echo "mounting of bootpart: $bootpart failed"; sleep 3; return 1
	fi



	if [ ! -f /boot/.wrtboot ]; then
		echo "${bootpart} > .wrtboot [no]"; sleep 2; return 1
		#echo "${bootpart}@/boot/.wrtboot [create]"; sleep 2; touch /boot/.wrtboot #tmpfix
	else
		echo "${bootpart} .wrtboot [ok]"
	fi
	sleep 2





	#echo "ls -lah /boot"; sleep 2; ls -lah /boot; sleep 5
	    #################echo "mount"; sleep 1; mount; sleep 3
	    ################### echo "df -h | grep boot"; df -h | grep boot; sleep 3





	mkdir -p /rootfs


	echo "mount -t ext4 $rootfspart /rootfs"
	if ! mount -t ext4 $rootfspart /rootfs; then
		echo "mounting of rootfspart: $rootfspart failed" && sleep 2 && return 1
	fi




	if [ ! -f /rootfs/.wrtrootfs ]; then
		echo "${rootfspart} .wrtrootfs [no]"; sleep 2; return 1
		#echo "${rootfspart} .wrtrootfs [create]"; sleep 2; touch /rootfs/.wrtrootfs #tmpfix
	else
		echo "${rootfspart} .wrtrootfs [ok]"
	fi
	sleep 2









#IDENTICAL!!!
##################################################################################### FROMrt2600acFAILEDoldfilemmcattempt202007
#	local board_dir=$(tar tf $tar_file | grep -m 1 '^'$tar_pfx'sysupgrade-.*/$')
#	board_dir=${board_dir%/}
#	echo "board_dir: $board_dir"; sleep 2
#################################	#echo "shouldnoexist: ls -lah $board_dir/"; ls -lah $board_dir/; sleep 2




	local board_dir=$(tar tf $tar_file | grep -m 1 '^'$tar_pfx'sysupgrade-.*/$')
	board_dir=${board_dir%/}
	echo "board_dir: $board_dir"; sleep 2


	####################################### 2020 while bug is checked
	if [ -z "$board_dir" ]; then
		echo "board_dir: [nope] in $tar_file [abort]"; sleep 10


        echo "dbg: lets have a look"; sleep 2; tar tf $tar_file; sleep 20


        return 1
	fi





	#echo "shouldnoexist: ls -lah $board_dir/"; ls -lah $board_dir/; sleep 2








    ################### DO WE NEED TO UNPACK IT? ##########################################################
	################### THEONLYREASON ??? >>> tar xzf ${kernelunpack}/${board_dir}/rootfs.tar.gz -C /rootfs
    #######################################################################################################



	if [ -d "$kernelunpack" ]; then echo "there is an unpack dir present already: $kernelunpack"; sleep 5; fi




	echo "mkdir -p $kernelunpack"; sleep 2
	mkdir -p $kernelunpack


	echo "creating tar extract dir: $kernelunpack"; sleep 1
	echo "tar xf $tar_file -C ${kernelunpack}/"; sleep 2
	tar xf $tar_file -C ${kernelunpack}/
	echo "ls -lah $kernelunpack/"; ls -lah $kernelunpack/; sleep 5






    #local has_env=0








	local has_kernel=1

	echo "tar xf $tar_file ${board_dir}/kernel -O | wc -c"; sleep 2
	local kernel_length=`(tar xf $tar_file ${board_dir}/kernel -O | wc -c) 2> /dev/null`





    echo "kernel_length: $kernel_length"


	[ "$kernel_length" = 0 ] && has_kernel=0
	[ "$kernel_length" = 0 ] && (echo "kernel_length: 0" && sleep 3 && return 1)
	#[ "$kernel_length" = 0 ] && echo "kernel_length: 0 EXIT IS OFF FOR TESTING"; sleep 3




	if [ "$kernel_length" -gt $kernelmax ]; then
		echo "kernel_length: $kernel_length -gt! kernelmax: $kernelmax"; sleep 3
		return 1 #|| has_kernel=0 etc
	else
		echo "kernel_length: $kernel_length -lt kernelmax: $kernelmax"; sleep 3
	fi







	local has_rootfs=1
    local rootfs_length=`(tar xf $tar_file ${board_dir}/rootfs.tar.gz -O | wc -c) 2> /dev/null`

	echo "tar xf $tar_file ${board_dir}/rootfs.tar.gz -O | wc -c"; sleep 2


    [ "$rootfs_length" = 0 ] && has_rootfs=0
	[ "$rootfs_length" = 0 ] && (echo "rootfs_length: 0" && sleep 3 && return 1)

    echo "rootfs_length: $rootfs_length"



    if [ "$rootfs_length" -gt $rootfsmax ]; then
		echo "rootfs_length: $rootfs_length -gt! rootfsmax: $rootfsmax"; sleep 3
		return 1 #|| has_kernel=0 etc
	else
		echo "rootfs_length: $rootfs_length -lt rootfsmax: $rootfsmax"; sleep 3
	fi





	echo "tar xf $tar_file ${board_dir}/CONTROL -O"; sleep 1;
    tar xf $tar_file ${board_dir}/CONTROL -O; sleep 2




    echo "DBG cat ${kernelunpack}/$board_dir/CONTROL"; sleep 1; cat ${kernelunpack}/$board_dir/CONTROL; sleep 2



	echo "######################################  point of no return"; sleep 2

	echo "ls -lah /rootfs PRE"; ls -lah /rootfs; sleep 3
	#mount; echo "early force exit from usb_do"; sleep 2; return 1











    ################### DBG EXIT DONTFLASH
    #return 1
    #exit 0
    ################### DBG EXIT DONTFLASH










	cleanrootfsdirs "/rootfs"
	sleep 2

	echo "ls -lah /rootfs POST"; ls -lah /rootfs; sleep 5

	#echo "mount"; mount; sleep 3 #NOTAVAILABLE+platform.shcopybin echo "df -h | grep rootfs"; df -h | grep rootfs; sleep 3


	#>MOUNTSTART>HERE
	echo "tar xzf ${kernelunpack}/${board_dir}/rootfs.tar.gz -C /rootfs"; sleep 2
	tar xzf ${kernelunpack}/${board_dir}/rootfs.tar.gz -C /rootfs
	sleep 2
    #sync ?





	#set
	#set > /rootfs/sysupSET






	echo ""
	echo "writing wrtboottoggle $rootfspart > /usr/sbin/wrtboottoggle"; sleep 2
	writewrtboottoggle "/rootfs/usr/sbin/wrtboottoggle"
	sleep 1


	echo ""
	echo "->>> /rootfs/etc/fw_env.config + /rootfs/usr/sbin/wrtboottoggle"; sleep 2
	echo ""
	sleep 2






    #@@@ no unpack
	echo "cp -a ${kernelunpack}/${board_dir}/kernel /boot/"; sleep 2
	cp -a ${kernelunpack}/${board_dir}/kernel /boot/
	sleep 2









	#echo "TBA cp -a ${kernelunpack}/booty.txt /boot/ NOTE: booty.txt on USB is still manual (retained) for now"; sleep 2
	#cp -a ${kernelunpack}/boot.scr /boot/
	#sleep 2

    #@@@if wanted|mmcupdate[yepotherwiseneed2bootmounts]|opposite for booty.txt
    #@@@ where did the validation go? -f



    ####################################################### 202007
    #FORNOW if -f && bootpart mmc
    if [ "$bootpart" = "/dev/mmcblk0p1" ]; then
        if [ -f "${kernelunpack}/boot.scr" ]; then
            echo "cp -a ${kernelunpack}/boot.scr /boot/"; sleep 2
	        cp -a ${kernelunpack}/boot.scr /boot/
        #else no scr in update
        fi
    #else not updating scr
    fi
	sleep 2


    if [ "$bootpart" = "/dev/sda1" ]; then
            if [ -f "${kernelunpack}/booty.txt" ]; then
                echo "cp -a ${kernelunpack}/booty.txt /boot/booty.txt.new"; sleep 2
	            cp -a ${kernelunpack}/booty.txt /boot/booty.txt.new
            #else no booty in update
            fi
    #else not updating booty
    fi
    sleep 2





	if [ ! -f "$UPGRADE_BACKUP" ]; then
		echo "$UPGRADE_BACKUP [no keep settings] > skip cp to /rootfs/$BACKUP_FILE"; sleep 3
	else
		echo "cp -v $UPGRADE_BACKUP /rootfs/$BACKUP_FILE"; sleep 3
		cp -v $UPGRADE_BACKUP /rootfs/$BACKUP_FILE
		sleep 2
	fi


	sync
	umount -a || sleep 5 && umount -a
	reboot -f

}








cleanrootfsdirs() {

	local rootfsmnt="$1"

	#NOTWORKIN>var->tmp-L    run init boot; do
	for fold in etc root lib bin overlay sbin usr proc sys tmp mnt dev www rom var run init; do
		if [ -e ${rootfsmnt}/$fold ]; then
			echo -n " /${fold}"
			rm -rf ${rootfsmnt}/${fold}
		else
			echo -n " -/${fold}";
		fi; sleep 1
	done; echo ""
	#echo "######################### postclean check"; sleep 2; ls -la $rootfsmnt/; sleep 5

}







writewrtboottoggle() {

if [ -z "$1" ]; then logit "writetoggle-empty-fpath" && terminate FAIL "writeboottoggle z"; fi
writefile="$1"

if [ -f "$writefile" ]; then
    echo "wrtboottoggle: $writefile [overw]"; sleep 2
else
	echo "wrtboottoggle: $writefile [write]"; sleep 2
fi



cat <<'EiopK' > $writefile
#!/bin/sh

#NB: v2.1 only edit in updater !!!


usage() {
#`basename $0`
#get
#toggle
#set <0|1|2> 0=wrtmmc 1=tba 2=mmcoem
cat <<'ETK'


	[get|toggle|set <0|1|2> (0=wrtmmc 1=tba 2=mmcoem)]

ETK
exit 0
}


#@@@ wrtbootaltmmc 0 @ >>> bootaltmmcvalname #>>> was wrtbootalt@-zSTATIC
bootaltmmcvalname="wrtbootalt" #@@@> wrtbootaltmmc #(0=openwrt 2=oem 1=openwrtalt)

case "$1" in
	-h|--help) usage; ;;
esac


if [ "$(fw_printenv | wc -l)" -lt 9 ]; then echo "fw_printenv issue check /etc/fw_env.config" && exit 1; fi
curbootval="$(fw_printenv -n wrtbootalt 2>/dev/null)"

case "$1" in #if [ -z "$1" ]; then #get #fi


	set)
		if [ -z "$2" ]; then usage; fi
		case "$2" in
			default) echo "set > 0 [openwrt] ( default )"; newval=0; ;;
			0) echo "set > 0 [openwrt]"; ;;
			#1) echo "set > 1 [danger]"; ;;
			2) echo "set > 2 [oem]"; ;;
			*) echo "unset--or-invalid: [$curbootval]"; exit 1; ;;
		esac
		if [ -z "$newval" ]; then newval=$2; fi

		if [ "$newval" -eq "$curbootval" ]; then #echo "was...
			echo "nochange";
		else
			#needs verify...
			fw_setenv wrtbootalt $2
		fi
		#exit 0
	;;

	toggle)


		echo "curbootval: ${curbootval:-zilch}"; sleep 1
		if [ -z "$curbootval" ]; then
			echo "$bootaltmmcvalname is z [non-present] > set to default > 0 (openwrt on mmc)"
			#fw_setenv $bootaltmmcvalname 0
			echo "TEST: fw_setenv $bootaltmmcvalname 0"; sleep 2
			fw_setenv wrtbootalt 0
			exit 0
		elif [ "$curbootval" -eq 2 ]; then
			echo "wrtbootalt 2 > 0 (mmc openwrt)"; sleep 2
			fw_setenv wrtbootalt 0
			exit 0
		elif [ "$curbootval" -eq 0 ]; then
			echo "wrtbootalt 0 > 2 (oem)"; sleep 2
			fw_setenv wrtbootalt 2
			exit 0
		else
			echo "current bootvalue (wrtbootalt) is not z, 0 or 2"; sleep 2; exit 1
		fi

	;;
	*)
		echo "> get"
		case "$curbootval" in
			0) echo "0 [openwrt]"; ;;
			#1) echo "1 [danger]"; ;;
			2) echo "2 [oem]"; ;;
			*) echo "unset--or-invalid: [$curbootval]"; exit 1; ;;
		esac
		#exit 0
	;;
esac
exit 0


#if [ -z "$1" ]; then #get
#	case "$curbootval" in
#	0) echo "0 [openwrt]"; ;;
#	#1) echo "1 [danger]"; ;;
#	2) echo "2 [oem]"; ;;
#	*) echo "unset--or-invalid: [$curbootval]"; ;;
#	esac
#	exit 0
#fi
EiopK
chmod +x $writefile

}
#logit "writing wrtboottoggle /usr/sbin/wrtboottoggle"; sleep 2; writewrtboottoggle "!!!filepath!!!"


synology_do_upgrade() {

	#~~~~~~~~~~~~   we assume fw_printenv is taken care of by oem < openwrt.pat... re-use to fix...  ~~~~~~~#
	#tba > unless we expand to dual usb||mmc... the we need it...
	#~~~~~~~~~~~~   we need to handle sdb assignment etc...

	#mkdir -p /var/lock
	#/usr/sbin/fw_printenv -n wrtbootpart

	local tar_file="$1"
	local tar_pfx="./"
	local board=$(board_name)
	local cmdlinerootfs="$(synology_get_cmdlinerootfs)"
	local rootfspart="$(synology_get_rootfspart)"
	local bootpart="$(synology_get_bootpart)"
	local bootpartu="$(synology_get_bootpartu)"
	local rootfspartu="$(synology_get_rootfspartu)"
	local kernelmax=5194304 #4194304 # ~ 4MB


    #are these not used anymore???
    [ -z "${rootfspartu}" ] && echo "rootfspartu: $rootfspartu is not defined (older)"
    [ -z "${bootpartu}" ] && echo "bootpartu: $bootpartu is not defined (older)"

    #newerones? print the uboot value name is empty
    #wrturootfspart=$(/usr/sbin/fw_printenv -n wrtrootfspart 2>/dev/null)
	#wrtbootpart=$(/usr/sbin/fw_printenv -n wrtbootpart 2>/dev/null)
    [ -z "${wrturootfspart}" ] && echo "wrturootfspart: uboot wrturootfspart is not defined (newer)"
    [ -z "${wrtbootpart}" ] && echo "wrtbootpart: uboot wrtbootpart is not defined (newer)"


	if [ -z "$bootpart" ]; then echo "unable to retrieve bootpart"; return 1; fi
	if [ -z "$rootfspart" ]; then echo "unable to retrieve rootfspart"; return 1; fi


	echo "         bootpart: $bootpart"
	echo "       rootfspart: $rootfspart"
	echo ""
	echo "        bootpartu: $bootpartu"
	echo "      rootfspartu: $rootfspartu"

    echo "      wrtbootpart: $wrtbootpart (uboot newer?)"
    echo "   wrturootfspart: $wrturootfspart (uboot newer?)"



    echo ""
	echo "    cmdlinerootfs: $cmdlinerootfs"
	echo "         tar_file: $tar_file"
	echo ""
	echo "             fish: $fish"
	echo ""
	sleep 5


    ################################### dont think this is used... platform.sh has copy data .bootalt...
	if [ -f "/.bootalt" ]; then
		echo "testcopydataflag>/.bootalt found here: `pwd`"
		echo "###################################### cat /.bootalt"
		cat /.bootalt; sleep 3
	else
		echo "/.bootalt found not here: `pwd`"
	fi; sleep 2



	if ! echo "${cmdlinerootfs}" | grep -Eq '(/dev/sd|/dev/mmc)'; then
		echo "cmdlinerootfs: $cmdlinerootfs != sdx or mmc"; sleep 3
		return 1
	fi


	case "$board" in
	synology,rt2600ac)

	    echo "############################### synology_do_upgrade()"; sleep 3




	    if [ "$cmdlinerootfs" != "$rootfspart" ]; then echo "cmdlinerootfs: $cmdlinerootfs != rootfspart: $rootfspart"; fi


        #NEWER?echo "      wrtbootpart: $wrtbootpart (uboot newer?)"
        #NEWER?echo "   wrturootfspart: $wrturootfspart (uboot newer?)"
        ######################################################################### OLDER?
        if [ "$rootfspart" != "$rootfspartu" ]; then echo "rootfspart: $rootfspart != rootfspartu: $rootfspartu (older?)"; fi
        if [ "$bootpart" != "$bootpartu" ]; then echo "bootpart: $bootpart != bootpartu: $bootpartu (older?)"; fi
        ######################################################################### NEWER?
	    if [ "$rootfspart" != "$wrturootfspart" ]; then echo "rootfspart: $rootfspart != wrturootfspart: $wrturootfspart"; fi
	    if [ "$bootpart" != "$wrtbootpart" ]; then echo "bootpart: $bootpart != wrtbootpart: $wrtbootpart"; fi

        sleep 6




		#NB: DO NOT SYSUPGRADE IF YOUR usb boot.txt is using rootfs on mmc !!! aka block devs must reside on same disk for sysup

		case "$cmdlinerootfs" in
			"/dev/mmcblk0p7")
				echo "rootfs on internal mmc: /dev/mmcblk0p7|[notsupported]"; sleep 3
				bootpart="/dev/mmcblk0p1"
				rootfspart="/dev/mmcblk0p7"
				return 1
			;;
			"/dev/mmcblk0p6")
				echo "rootfs on internal mmc: /dev/mmcblk0p6"; sleep 3
				bootpart="/dev/mmcblk0p1"
				rootfspart="/dev/mmcblk0p6"
			;;
			"/dev/sda3")
				echo "rootfs on external: /dev/sda3"; sleep 3
				bootpart="/dev/sda1"
				rootfspart="/dev/sda3"
			;;
			*)
				echo "unsupported rootfspart: $rootfspart"; sleep 2
				return 1
			;;
		esac
		;;
	*)
		echo "unsupported board: $board synology.sh"; sleep 2
		return 1
		;;
	esac

	[ -b "${rootfspart}" ] || echo "rootfspart: $rootfspart is not plugged in"
	[ -b "${rootfspart}" ] || return 1
	[ -b "${bootpart}" ] || echo "bootpart: $bootpart is not plugged in"
	[ -b "${bootpart}" ] || return 1

	echo "         bootpart: $bootpart"
	echo "       rootfspart: $rootfspart"
	sleep 5


    #if -b sdb? return 1? we dont support multple usb yet


	synology_do_flash_usb $tar_file $bootpart $rootfspart

	return 0

}








#local board_dir=$(tar tf $tar_file | grep -m 1 '^'$tar_pfx'sysupgrade-.*/$')
#PWD='/tmp/root'
#RAM_ROOT='/tmp/root'

#RAMFS_COPY_BIN='fw_printenv fw_setenv e2fsck'
#RAMFS_COPY_DATA='/etc/fw_env.config /var/lock/fw_printenv.lock'







#.pat has no json metadata
#'squashfs' has metadata but gets invalid tar magic and cant resolve boarddir kernel wc rootfs wc





################################# http://lists.infradead.org/pipermail/openwrt-devel/2020-July/030260.html
#+vboot_do_upgrade() {
#    +local tar_file="("
#    +
#    +echo "Preparing to flash to /dev/      mmcblk0p{1,2}"
#    +ask_bool 0 "Abort" && exit 1
#    +
#    +tar Oxf "${tar_file}" '*/kernel' | dd of=/dev/mmcblk0p1 bs=1M
#    +tar Oxf "${tar_file}" '*/root' | dd of=/dev/mmcblk0p2 bs=1M












