# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A meta ebuild for games."
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="amd64"
IUSE="+dolphin +dosbox +fceux +mednafen +mupen64plus +openra +steam +supermariowar +supertuxkart"

DEPEND="${CDEPEND}"
RDEPEND="${DEPEND}
		supermariowar? ( games-action/supermariowar )
		supertuxkart? ( games-action/supertuxkart )
		dolphin? ( games-emulation/dolphin )
		dosbox? ( games-emulation/dosbox )
		fceux? ( games-emulation/fceux )
		mednafen? ( games-emulation/mednafen )
		mupen64plus? ( games-emulation/mupen64plus )
		openra? ( games-strategy/openra )
		steam? ( games-util/steam-meta )
		"
