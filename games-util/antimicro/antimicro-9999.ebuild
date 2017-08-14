# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils cmake-utils

DESCRIPTION="The Github version of Antimicro with fixes for gcc-6"
HOMEPAGE="https://github.com/AntiMicro/antimicro"
SRC_URI="https://github.com/AntiMicro/antimicro/archive/master.zip -> ${P}.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="qt5 +sdl2 test"

CDEPENDS="
		x11-libs/Xi
"
DEPENDS="${CDEPENDS}"
RDEPEND="${DEPEND}
		test? ( x11-libs/libXi ) 
		sdl2? ( media-libs/libsdl2[X,joystick] )
		!sdl2? ( media-libs/libsdl[X,joystick] )
	    qt5? ( 
			dev-qt/qtcore:5  
			x11-libs/libX11 
		)     
        !qt5? ( dev-qt/qtcore:4 ) 
		"

S=${WORKDIR}/antimicro-master

src_configure() {
				if use qt5 ; then
					QT_SELECT=5 cmake-utils_src_configure
				fi 

				if ! use qt5 ; then
					QT_SELECT=4 cmake-utils_src_configure 
				fi
}


