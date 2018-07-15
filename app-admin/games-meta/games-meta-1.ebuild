# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A meta ebuild for games and handy gaming utilities."
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="amd64"
IUSE="antimicro +dolphin +dosbox +fceux +lutris +mednafen +mupen64plus +openra +qjoypad +steam +supermariowar +supertuxkart"

DEPEND="${CDEPEND}"
RDEPEND="${DEPEND}
		antimicro? ( games-util/antimicro )
		supermariowar? ( games-action/supermariowar )
		supertuxkart? ( games-action/supertuxkart )
		dolphin? ( games-emulation/dolphin )
		dosbox? ( games-emulation/dosbox )
		fceux? ( games-emulation/fceux )
		lutris? ( games-util/lutris )
		mednafen? ( games-emulation/mednafen )
		mupen64plus? ( games-emulation/mupen64plus )
		openra? ( games-strategy/openra )
		qjoypad? ( games-util/qjoypad )
		steam? ( games-util/steam-meta )
		"
