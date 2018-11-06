# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3 linux-info

DESCRIPTION="Driver for AC1200 (801.11ac) Wireless Dual-Band USB Adapter, works with 4.19"
HOMEPAGE="https://github.com/gordboy/rtl8812au"
EGIT_REPO_URI="https://github.com/gordboy/rtl8812au.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_compile() {
	set_arch_to_kernel
	KSRC="${KV_DIR}" KVER="$(uname -r)" emake
}

src_install() {
	insinto "/lib/modules/$(uname -r)/kernel/drivers/net/wireless/"
	doins 8812au.ko
	#emake MODDESTDIR="${ED}/lib/modules/${KV_FULL}/kernel/drivers/net/wireless/" install
}
