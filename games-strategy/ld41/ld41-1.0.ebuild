# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Collect arrows to reconfigure the sliding puzzle so that it is solved. Collect power-ups to help you."
HOMEPAGE="https://github.com/bentglasstube/ld41/ https://ldjam.com/events/ludum-dare/41/$74927"
SRC_URI="https://github.com/bentglasstube/ld41/archive/v${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
    dev-util/bazel
    >=media-libs/libsdl2-2.0.5
    media-libs/sdl2-mixer
    media-libs/sdl2-image
"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_compile() {
	bazel build :${PN}
#	mv ${S}/${P} /usr/bin/${PN}
}

src_install() {
	addwrite /usr/bin #ugly solution to sandbox violation
	mv ${S}/${P} /usr/bin/${PN}
}
