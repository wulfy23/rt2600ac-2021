
setenv kload 0x44000000
setenv rload 0x46000000
setenv dload 0x48000000
setenv sload 0x49000000
setenv uload 0x50000000

setenv loadcmd ext2load
setenv bootpart 0

setenv wrt_console ttyMSM0,115200n8
setenv wrt_extra rootwait
setenv wrt_init /sbin/init
setenv wrt_boottxt booty.txt


if test -n "$wrtbootalt"; then
	echo wrtbootalt is set ${wrtbootalt}
else
	setenv wrtbootalt 0
	echo wrtbootalt setting to 0 as not defined: ${wrtbootalt}
fi


setenv wrtkernelusb kernel
setenv wrtkernelusbalt kernel2

setenv wrtkernelmmc kernel
setenv wrtkernelmmcalt kernel2

setenv wrtrfspartusb 3
setenv wrtrfspartusbalt 5

setenv wrtrfspartmmc 7
setenv wrtrfspartmmcalt 6


if test -n "$wrtbootalt"; then
	echo fix these devsets if is number
	setenv wrtkernelusb ${wrtkernelusbalt}
	setenv wrtrfspartusb ${wrtrfspartusbalt}
	setenv wrtrfspartmmc ${wrtrfspartmmcalt}
fi


setenv usb_scan_list 1 2 3 4
setenv usb_scan_1 usb=0:1 dev=sda${wrtrfspartusb}
setenv usb_scan_2 usb=1:1 dev=sdb${wrtrfspartusb}
setenv usb_scan_3 usb=2:1 dev=sdc${wrtrfspartusb}
setenv usb_scan_4 usb=3:1 dev=sdd${wrtrfspartusb}


setenv usb_device 0:1
setenv usb_root /dev/sda3
echo TEST1ACTUALSTATIC setenv usb_root /dev/sda3
echo TEST1PROPOSEDVARIABLE setenv usb_root /dev/sda${wrtrfspartusb}


setenv usb_rootfstype ext4,squashfs
setenv usb_rootdelay 7


setenv mmc_device 0:1
setenv mmc_root /dev/mmcblk0p6

setenv mmc_rootfstype ext4,squashfs
setenv mmc_rootdelay 3


setenv usb_boot bootm ${kload}
setenv usb_set_bootargs 'setenv bootargs console=$wrt_console root=$usb_root rootdelay=$usb_rootdelay rootfstype=$usb_rootfstype init=$wrt_init $usb_custom_params'

setenv mmc_boot bootm ${kload}
setenv mmc_set_bootargs 'setenv bootargs console=$wrt_console root=$mmc_root rootdelay=$mmc_rootdelay rootfstype=$mmc_rootfstype init=$wrt_init $mmc_custom_params'


echo "boot.scr starting usb"
usb start


echo check usb_set_bootargs is still variables ${usb_set_bootargs} printenv debugwashere


echo "2scanning for ${wrt_boottxt} on usb this will skip all script loading"
for scan in $usb_scan_list; do
	run usb_scan_$scan
	if $loadcmd usb $usb ${uload} $wrt_boottxt; then
		echo Importing USB $wrt_boottxt from $usb
		if env import -t ${uload} ${filesize}; then
			echo env import success
			setenv boottxtufound 1
		else
			echo env import failed
		fi
	else
		echo no $wrt_boottxt on usb $usb
	fi
done


if test -n $boottxtufound; then
	echo skip mmc boot openwrt as we found boottxt on usb

	echo test run bootcmd now
	if test -n ${wrtgo}; then
		echo wrtgo is set running
		run wrtgo; run bootcmd
	else
		echo wrtgo not defined in boot txt see what uboot bootcmd does hand back put printenv at start on all bootcmds
	fi
else

	if test ${wrtbootalt} -eq 2; then
		echo wrtbootalt istwo:${wrtbootalt}
	else
		echo wrtbootalt isnottwo: ${wrtbootalt}

		echo no boot txt on usb so we will try openwrt on mmc
		echo use fw_setenv wrtbootalt 2 to switch to oem

		if $loadcmd mmc 0:1 ${kload} ${wrtkernelmmc}; then
			echo found kernel on mmc booting openwrt
			setenv mmc_device 'mmc 0:1'; setenv mmc_root /dev/mmcblk0p6
			run mmc_set_bootargs
			run mmc_boot
		else
			echo no kernel on mmc 0:1
		fi

	fi
fi


echo hand over to uboot to run bootcmd
echo check final wrtusbkernel name: ${wrtkernelusb}
echo check final wrtusbkernelalt name: ${wrtkernelusbalt}
echo check final usb_device ${usb_device}
echo check final usb_root ${usb_root}
echo another final printenv debug



