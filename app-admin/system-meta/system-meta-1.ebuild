# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A meta ebuild for indispensible system utilities."
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="amd64"
IUSE="X +btrfs +cronie +efi +firmware +intel-microcode +lightdm +networkmanager +openrc +sensors +systemrescuecd-x86 +zsh"

DEPEND="${CDEPEND}"
RDEPEND="${DEPEND}
		app-admin/sudo
		app-misc/screen
		app-misc/screenfetch
		app-portage/eix
		app-portage/genlop
		app-portage/gentoolkit
		app-portage/pfl
		app-portage/repoman
		app-text/wgetpaste
		net-fs/nfs-utils
		net-misc/axel
		sys-apps/usbutils
		sys-apps/mlocate
		sys-boot/grub
		sys-boot/os-prober
		sys-kernel/genkernel-next
		sys-kernel/gentoo-sources
		btrfs? ( app-backup/snapper 
				 sys-fs/btrfsmaintenance )
		cronie? ( sys-process/cronie )
		efi? ( sys-fs/dosfstools )
		firmware? ( sys-kernel/linux-firmware )
		intel-microcode? ( sys-firmware/intel-microcode 
						   sys-apps/iucode_tool )
		lightdm? ( x11-misc/lightdm 
                   x11-misc/lightdm-settings
                   x11-misc/lightdm-slick-greeter )
		networkmanager? ( net-misc/networkmanager )
		openrc? ( sys-boot/plymouth-openrc-plugin )
		systemrescuecd-x86? ( app-admin/systemrescuecd-x86 )
		sensors? ( app-admin/hddtemp
				   sys-apps/lm_sensors )
		zsh? ( app-doc/zsh-lovers
			   app-shells/zsh-completions 
			   )
		X? ( x11-base/xorg-server )
		"
