# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A meta ebuild for fonts."
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="amd64"
IUSE="+baekmuk +code2000 +firacode +fontawesome +hack +inconsolata +liberation +noto +source-han-sans +symbola"

DEPEND="${CDEPEND}"
RDEPEND="${DEPEND}
		baekmuk? ( media-fonts/baekmuk-fonts )
		code2000? ( media-fonts/code2000 )
		firacode? ( media-fonts/firacode )
		fontawesome? ( media-fonts/fontawesome )
		hack? ( media-fonts/hack )
		inconsolata? ( media-fonts/inconsolata )
		liberation? ( media-fonts/liberation-fonts )
		noto? ( media-fonts/noto )
		source-han-sans? ( media-fonts/source-han-sans )
		symbola? ( media-fonts/symbola )

"

