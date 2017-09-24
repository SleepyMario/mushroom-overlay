# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils git-r3

DESCRIPTION="A fast and easy-to-use tool for creating status bars"
HOMEPAGE="https://github.com/jaagr/polybar"
EGIT_REPO_URI="https://github.com/jaagr/polybar.git"
EGIT_CLONE_TYPE="shallow"
EGIT_COMMIT="${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
		x11-libs/libxcb
		dev-lang/python:2.7
		x11-proto/xcb-proto
		x11-libs/xcb-util-wm
		x11-libs/xcb-util-image
		media-libs/alsa-lib 
        dev-libs/jsoncpp 
		media-libs/libmpdclient 
		net-misc/curl 
		net-wireless/wireless-tools 
"
DEPEND="${RDEPEND}"

src_configure() {
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
}
