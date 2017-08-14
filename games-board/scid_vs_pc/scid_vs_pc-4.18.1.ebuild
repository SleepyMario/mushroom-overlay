# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A fork of Shane's Chess Information Database, a powerful Chess Toolkit"
HOMEPAGE="http://scidvspc.sourceforge.net"
SRC_URI="https://downloads.sourceforge.net/project/scidvspc/source/scid_vs_pc-4.18.1.tgz -> scid.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="sound +stockfish"

CDEPEND="
		>=dev-lang/tcl-8.6
		>=dev-lang/tk-8.6
		!games-board/scid
		"
DEPEND="${CDEPEND}"
RDEPEND="${DEPEND}
		sound? ( =dev-tcltk/snack-2.2.10 )
		stockfish? ( games-board/stockfish )
		"
src_configure() {
# configure is not an autotools script
			./configure \
			BINDIR="/usr/local/bin/" \
			SHAREDIR="/usr/local/share/${PN}" || die "Install Failed"  
}

# To-Do:
# 1) location of stockfish 
