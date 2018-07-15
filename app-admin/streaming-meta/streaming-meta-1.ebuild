# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A meta ebuild for streaming utilities."
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="amd64"
IUSE="+avidemux chatgamefontificator +guvcview +hasciicam llanfair +luvcview +mpv +obs-studio +streamlink "

DEPEND="${CDEPEND}"
RDEPEND="${DEPEND}
		avidemux? ( media-video/avidemux )
		chatgamefontificator? ( games-util/chatgamefontificator )
		guvcview? ( media-video/guvcview )
		hasciicam? ( media-video/hasciicam )
		luvcview? ( media-video/luvcview )
		llanfair? ( games-util/llanfair )
		mpv? ( media-video/mpv )
		obs-studio? ( media-video/obs-studio )
		"
