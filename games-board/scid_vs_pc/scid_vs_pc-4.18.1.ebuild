# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A fork of Shane's Chess Information Database, a powerful Chess Toolkit"
HOMEPAGE="http://scidvspc.sourceforge.net"
SRC_URI="https://downloads.sourceforge.net/project/scidvspc/source/scid_vs_pc-4.18.1.tgz"

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
			SHAREDIR="/usr/local/share/scid" || die "Install Failed"  
}

pkg_postinst() {
		elog "The stockfish engine is located in /usr/bin and is called 'stockfish'"
		elog "!!DO NOT INSTALL 'games-board/scid' FROM PORTAGE AS IT WILL OVERWRITE THIS INSTALL!!"
}

# To-Do:
# 1) location of stockfish
# 2) scid should !games-board/scid_vs_pc
# 3)  
# * QA Security Notice: world writable file(s):
# *   /usr/local/share/scid/engines/phalanx/eco.phalanx
# *   /usr/local/share/scid/books/Elo2400.bin
# *   /usr/local/share/scid/books/Performance.bin
# *   /usr/local/share/scid/books/gm2600.bin
# *   /usr/local/share/scid/books/readme.txt
# *   /usr/local/share/scid/books/varied.bin
# *   /usr/local/share/scid/bases/endings.sg4
# *   /usr/local/share/scid/bases/endings.si4
# *   /usr/local/share/scid/bases/endings.sn4
# *   /usr/local/share/scid/bases/matein1.sg4
# *   /usr/local/share/scid/bases/matein1.si4
# *   /usr/local/share/scid/bases/matein1.sn4
# *   /usr/local/share/scid/bases/matein2.sg4
# *   /usr/local/share/scid/bases/matein2.si4
# *   /usr/local/share/scid/bases/matein2.sn4
# *   /usr/local/share/scid/bases/matein3.sg4
# *   /usr/local/share/scid/bases/matein3.si4
# *   /usr/local/share/scid/bases/matein3.sn4
# *   /usr/local/share/scid/bases/matein4andmore.sg4
# *   /usr/local/share/scid/bases/matein4andmore.si4
# *   /usr/local/share/scid/bases/matein4andmore.sn4
# *   /usr/local/share/scid/bases/tactics.sg4
# *   /usr/local/share/scid/bases/tactics.si4
# *   /usr/local/share/scid/bases/tactics.sn4
# * This may or may not be a security problem, most of the time it is one.
# * Please double check that scid_vs_pc-4.18.1 really needs a world writeable bit and file bugs accordingly.

