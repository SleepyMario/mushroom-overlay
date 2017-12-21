# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools multilib readme.gentoo-r1 systemd user

if [[ ${PV} == 9999 ]]; then
        inherit git-r3
        EGIT_REPO_URI="https://github.com/Bumblebee-Project/Bumblebee.git"
        EGIT_BRANCH="develop"
        KEYWORDS=""
else
        COMMIT="c322bd849aabe6e48b4304b8d13cc4aadc36a30d"
        SRC_URI="https://github.com/Bumblebee-Project/Bumblebee/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
        KEYWORDS="~amd64 ~x86"

        S="${WORKDIR}/Bumblebee-${COMMIT}"
fi

DESCRIPTION="Service providing elegant and stable means of managing Optimus graphics chipsets"
HOMEPAGE="https://bumblebee-project.org https://github.com/Bumblebee-Project/Bumblebee"

SLOT="0"
LICENSE="GPL-3"

IUSE="+bbswitch +video_cards_nouveau"

COMMON_DEPEND="
        dev-libs/glib:2
        dev-libs/libbsd
        sys-apps/kmod
        x11-libs/libX11
"

RDEPEND="${COMMON_DEPEND}
        virtual/opengl
        x11-base/xorg-drivers
        bbswitch? ( sys-power/bbswitch )
"

DEPEND="${COMMON_DEPEND}
        sys-apps/help2man
        virtual/pkgconfig
"

PDEPEND="
        || (
                x11-misc/primus
                x11-misc/virtualgl
        )
"

REQUIRED_USE="video_cards_nouveau"

pkg_setup() {
        enewgroup bumblebee
}

src_prepare() {
        default
        eautoreconf
}

src_configure() {
        econf \
                ${ECONF_PARAMS}
}

src_install() {
        default

        newconfd "${FILESDIR}"/${PN}.confd ${PN}
        newinitd "${FILESDIR}"/${PN}.initd ${PN}
        newenvd "${FILESDIR}"/${PN}.envd 99${PN}
        systemd_dounit scripts/systemd/bumblebeed.service

        local DOC_CONTENTS="In order to use Bumblebee, add your user to 'bumblebee' group.
                You may need to setup your /etc/bumblebee/bumblebee.conf"
        readme.gentoo_create_doc
}
