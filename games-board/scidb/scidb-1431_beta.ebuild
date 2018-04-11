# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A Chess Database inspired by scid but built from scratch"
HOMEPAGE="http://http://scidb.sourceforge.net/index.html"
SRC_URI="https://sourceforge.net/projects/scidb/files/${PN}-beta-code-r1431.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	>=dev-lang/tk-8.5
	>=dev-lang/tcl-8.5
	sys-libs/zlib
	dev-libs/zziplib
	dev-libs/expat
	sys-libs/gdbm
"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${PN}-beta-code-r1431

src_configure() {
	./configure \
		--prefix=/usr \
		--exec-prefix=/usr \
		--enginesdir=/usr/bin \
		--destdir=/$pkgdir
}

