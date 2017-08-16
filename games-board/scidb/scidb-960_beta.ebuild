# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A Chess Database inspired by scid but built from scratch"
HOMEPAGE="http://http://scidb.sourceforge.net/index.html"
SRC_URI="https://downloads.sourceforge.net/project/${PN}/${PN}-beta-code-r960.tar.gz" 

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="
	dev-lang/tk
	dev-lang/tcl
	sys-libs/zlib
	dev-libs/expat
	sys-libs/gdbm
"
RDEPEND="${DEPEND}"

S=${WORKDIR}/scidb-beta-code-r960

scr_configure() {
		./configure \
		--gcc-version=5.4.0-r3
}

