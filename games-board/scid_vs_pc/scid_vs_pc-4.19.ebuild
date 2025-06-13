# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils gnome2-utils

DESCRIPTION="A fork of Shane's Chess Information Database, a powerful Chess Toolkit"
HOMEPAGE="http://scidvspc.sourceforge.net"
SRC_URI="https://downloads.sourceforge.net/project/scidvspc/source/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="Xfcc sound +stockfish"

CDEPEND="
		>=dev-lang/tcl-8.6
		>=dev-lang/tk-8.6
		"
DEPEND="${CDEPEND}"
RDEPEND="${DEPEND}
		Xfcc? ( dev-tcltk/tdom )
		sound? ( =dev-tcltk/snack-2.2.10 )
		"

src_configure() {
# configure is not an autotools script
			./configure \
			BINDIR="/usr/local/bin/" \
			SHAREDIR="/usr/local/share/${PN}" || die "Install Failed"  
}

src_compile() {
	emake all_scid
}

src_install() {
		emake DESTDIR="${D}" install_scid
}

pkg_preinst() {
        gnome2_icon_savelist
}

pkg_postinst() {
		mv /usr/local/bin/scid /usr/local/bin/${PN}
        gnome2_icon_cache_update
}

