# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit cmake-utils

DESCRIPTION="A graphical program used to map keyboard keys and mouse controls to a gamepad."
HOMEPAGE="https://github.com/AntiMicro/antimicro"
SRC_URI="https://github.com/AntiMicro/antimicro/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="qt5 +sdl2 test"

CDEPEND="
		x11-libs/libXi
"
RDEPEND="${CDEPEND}
		test? ( x11-libs/libXtst ) 
		sdl2? ( 
			media-libs/libsdl2[X,joystick] 
		)
		!sdl2? ( media-libs/libsdl[X,joystick] )
	    qt5? ( 
			dev-qt/qtcore:5  
			dev-qt/qtnetwork:5
			dev-qt/qttranslations:5
			x11-libs/libX11 
					)     
        !qt5? ( dev-qt/qtcore:4 ) 
		"
DEPEND="${RDEPEND}"

src_configure() {
		local mycmakeargs=(
			-DUSE_SDL2="$(usex sdl2)"
		)
			
		if use qt5 ; then
			QT_SELECT=5 cmake-utils_src_configure
		else 
			QT_SELECT=4 cmake-utils_src_configure 
		fi
}


