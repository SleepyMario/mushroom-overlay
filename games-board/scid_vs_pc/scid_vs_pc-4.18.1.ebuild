# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A fork of Shane's Chess Information Database, a powerful Chess Toolkit"
HOMEPAGE="http://scidvspc.sourceforge.net"
SRC_URI="https://downloads.sourceforge.net/project/scidvspc/source/scid_vs_pc-4.18.1.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="sound"

CDEPEND="
		>=dev-lang/tcl-8.6
		>=dev-lang/tk-8.6
		!dev-tcltk/snack"
DEPEND="${CDEPEND}"
RDEPEND="${DEPEND}
		sound? ( dev-tcltk/snack-scid )"

src_configure() {
# configure is not an autotools script
			./configure \
			BINDIR="/usr/local/bin/" \
			SHAREDIR="/usr/share/${PN}" || die
}

# todo:
# 1) 2x scidpgn  -- important
# 2) snack flags -- not important 
# 3) integrate stockfish -- not important
