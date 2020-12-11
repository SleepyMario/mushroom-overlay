# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit linux-mod git-r3

DESCRIPTION="Kernel module that fixes the AMD reset bug when using VFIO."
HOMEPAGE="https://github.com/gnif/vendor-reset"
SRC_URI="https://github.com/gnif/vendor-reset"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

#S="{WORKDIR}"
S="/var/tmp/portage/sys-kernel/vendor-reset-0.018/work"
pkg_setup() {
	cd vendor-reset
	make
}

src_install() {

	NEWKV=`eselect kernel show | cut -c 18- | tail -1`
	cd vendor-reset
	OUTDIR=${S}/usr/lib/modules/${NEWKV}/
	mkdir -p $OUTDIR
	cp /lib/modules/${NEWKV}/modules.order $OUTDIR 
	cp /lib/modules/${NEWKV}/modules.builtin $OUTDIR 
	make INSTALL_MOD_PATH="${S}/usr/" install
	rm $OUTDIR/modules*
}
