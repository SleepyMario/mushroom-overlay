# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A meta ebuild for all the custom meta ebuilds. Cuz why not."
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="amd64"
IUSE="+chess +cinnamon +fonts +games +i3 +ibus +lczero +mutt +streaming +system +vim"

DEPEND="${CDEPEND}"
RDEPEND="${DEPEND}
		chess? ( games-board/chess-meta )
		cinnamon? ( app-admin/cinnamon-meta )
		fonts? ( app-admin/fonts-meta )
		games? ( app-admin/games-meta )
		i3? ( app-admin/i3-meta )
		ibus? ( app-admin/ibus-meta )
		lczero? ( games-board/lczero-meta )
		mutt? ( app-admin/mutt-meta )
		streaming? ( app-admin/streaming-meta )
		system? ( app-admin/system-meta )
		vim? ( app-admin/vim-meta ) 
		"
