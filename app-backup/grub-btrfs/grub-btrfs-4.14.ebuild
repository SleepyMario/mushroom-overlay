# Copyright 2019-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit optfeature

DESCRIPTION="Improves Grub by adding btrfs snapshots to the Grub menu"
HOMEPAGE="https://github.com/Antynea/grub-btrfs"
SRC_URI="https://github.com/Antynea/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="systemd"

DEPEND="
	sys-fs/btrfs-progs
	sys-boot/grub
	app-alternatives/awk
	>=app-shells/bash-4
	sys-fs/inotify-tools
"
RDEPEND="${DEPEND}"

src_compile() {
	true
}

src_install() {
	local conf
	if use systemd; then
		conf+="GRUB_UPDATE_EXCLUDE=true INSTALL_DOCS=false SYSTEMD=true OPENRC=false"
	else
		conf+="GRUB_UPDATE_EXCLUDE=true INSTALL_DOCS=false OPENRC=true SYSTEMD=false"
	fi
	emake DESTDIR="${D}" ${conf} install || die
	dodoc README.md
	mv ./initramfs/readme.md initramfs-overlayfs.md || die
	dodoc initramfs-overlayfs.md
	doman temp/grub-btrfs.8
	doman temp/grub-btrfsd.8
}

pkg_postinst() {
	elog "Run 'grub-mkconfig -o /boot/grub/grub.cfg' to update the GRUB menu."
	elog "Review the /etc/grub.d/41_snapshots-btrfs script after package updates."
	optfeature "LVM/LUKS support" sys-boot/grub[device-mapper]
}
