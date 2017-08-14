# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils cmake-utils

DESCRIPTION="A recent Antimicro that works with gcc-6"
HOMEPAGE="https://github.com/AntiMicro/antimicro"
SRC_URI="https://github.com/AntiMicro/antimicro/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="qt5 +sdl2 test"

CDEPENDS="
		x11-libs/Xi
"
RDEPEND="${CDEPEND}
		test? ( x11-libs/libXi ) 
		sdl2? ( media-libs/libsdl2[X,joystick] )
		!sdl2? ( media-libs/libsdl[X,joystick] )
	    qt5? ( 
			dev-qt/qtcore:5  
			x11-libs/libX11 
		)     
        !qt5? ( dev-qt/qtcore:4 ) 
		"
DEPEND="${RDEPENDS}"


S=${WORKDIR}/${PV}

src_configure() {
				local mycmakeargs=(
				-DUSE_SDL2="$(usex sdl2)"
				)
				
				if use qt5 ; then
					QT_SELECT=5 cmake-utils_src_configure
				fi 

				if ! use qt5 ; then
					QT_SELECT=4 cmake-utils_src_configure 
				fi
}


