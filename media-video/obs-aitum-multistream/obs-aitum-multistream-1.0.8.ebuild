# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="OBS Studio plugin for streaming to multiple services"
HOMEPAGE="https://aitum.tv/products/multi https://github.com/Aitum/obs-aitum-multistream"
SRC_URI="https://github.com/Aitum/obs-aitum-multistream/archive/refs/tags/${PV}.tar.gz
	-> ${P}.tar.gz"
S="${WORKDIR}/obs-aitum-multistream-${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=media-video/obs-studio-31.0.0:=
	dev-qt/qtbase:6[gui,widgets]
	net-misc/curl
"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/${P}-qt6-version.patch"
)

src_configure() {
	local mycmakeargs=(
		-DBUILD_OUT_OF_TREE=ON
	)

	cmake_src_configure
}
