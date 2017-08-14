# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A utility for mapping keyboard keys and mouse controls to a gamepad with fixes for gcc-6"
HOMEPAGE="https://github.com/AntiMicro/antimicro"
SRC_URI="https://github.com/AntiMicro/antimicro/archive/master.zip -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="qt5 +sdl2 test"

CDEPENDS="
		dev-util/cmake
		x11-libs/Xi
"
DEPENDS="${CDEPENDS}"
RDEPEND="${DEPEND}
		test? ( x11-libs/libXi ) 
		sdl2? ( media-libs/libsdl2[X,joystick] )
		!sdl2? ( media-libs/libsdl )
	    qt5? ( 
			dev-qt/qtcore:5  
			x11-libs/libX11 
		)     
        !qt5? ( dev-qt/qtcore:4 ) 
		"

src_configure() {
				QT_SELECT=5 cmake-utils_src_configure
}


