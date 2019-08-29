# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit xdg-utils

DESCRIPTION="Chat software specifically made for Twitch, in the spirit of a classic IRC Client."
HOMEPAGE="https://chatty.github.io/"
SRC_URI="https://github.com/chatty/chatty/releases/download/v0.9.6/Chatty_0.9.6.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
		>=virtual/jre-1.8
		"
RDEPEND="${DEPEND}"
BDEPEND=""

S=${WORKDIR}

src_install () {
	addwrite /usr/bin # ugly workaround, fix someday
	addwrite /usr/local/bin/ # ugly workaround, fix someday
	addwrite /usr/share/applications # ugly workaround, fix someday
	cp ${S}/Chatty.jar /usr/bin/${PN}.jar || die
	cp ${FILESDIR}/${PN} /usr/local/bin/${PN}
	cp ${FILESDIR}/${PN}.desktop /usr/share/applications/${PN}.desktop
	chmod +x /usr/local/bin/${PN}
	}

pkg_postinst() {
	xdg_icon_cache_update
	xdg_mimeinfo_database_update
	xdg_desktop_database_update
	}

pkg_postrm() {
	xdg_icon_cache_update
	xdg_mimeinfo_database_update
	xdg_desktop_database_update
	}

