# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit xdg-utils

DESCRIPTION="A Twitch chat display that uses the fonts of various video games."
HOMEPAGE="https://chatty.github.io/"
SRC_URI="https://github.com/GlitchCog/ChatGameFontificator/raw/master/jar/ChatGameFontificator.jar"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="**"
IUSE=""

DEPEND="
		>=virtual/jre-1.8
		"
RDEPEND="${DEPEND}"
BDEPEND=""

S=${DISTDIR}

src_install() {
	cp ${S}/ChatGameFontificator.jar /usr/bin/${PN}.jar || die
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
