# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Aitum canvas and multi-output suite for OBS Studio"
HOMEPAGE="https://aitum.tv/products/stream-suite https://github.com/Aitum/obs-aitum-stream-suite"
SRC_URI="https://github.com/Aitum/obs-aitum-stream-suite/releases/download/${PV}/aitum-stream-suitesource.tar.xz
	-> ${P}.tar.xz"
S="${WORKDIR}/aitum-stream-suite-${PV}-source"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	!media-video/obs-aitum-multistream
	>=media-video/obs-studio-31.1.0:=
	dev-qt/qtbase:6[gui,widgets]
	net-misc/curl
"
DEPEND="${RDEPEND}"

src_configure() {
	local mycmakeargs=(
		-DBUILD_OUT_OF_TREE=ON
	)

	cmake_src_configure
}
