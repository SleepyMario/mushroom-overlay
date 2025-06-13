# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A meta ebuild for chess-related ebuilds."
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="chessx crafty eboard emacs fruit gambit gmchess gnome-chess gnuchess gnuchess-book gnushogi knights natch phalanx pouetchess pychess scid scid_vs_pc scidb sjeng +stockfish tablebase-syzygy xboard"

DEPEND="${CDEPEND}"
RDEPEND="${DEPEND}
		chessx? ( games-board/chessx )
		crafty?	( games-board/crafty )
		eboard?	( games-board/eboard )
		emacs? ( app-emacs/chess )
		fruit? ( games-board/fruit )
		gambit? ( games-board/gambit )
		gmchess? ( games-board/gmchess )
		gnome-chess? ( games-board/gnome-chess )
		gnuchess? ( games-board/gnuchess )
		gnuchess-book? ( games-board/gnuchess-book )
		gnushogi? ( games-board/gnushogi )
		knights? ( games-board/knights )
		natch? ( games-board/natch )
		phalanx? ( games-board/phalanx )
		pouetchess? ( games-board/pouetchess )
		pychess? ( games-board/pychess )
		scid? ( games-board/scid )
		scid_vs_pc? ( games-board/scid_vs_pc )
	    scidb? ( games-board/scidb )
		sjeng? ( games-board/sjeng )
		stockfish? ( games-board/stockfish )
		tablebase-syzygy? ( games-board/tablebase-syzygy )
		xboard? ( games-board/xboard ) 
"

pkg_postinst() {
	elog "Enjoy!"
}
