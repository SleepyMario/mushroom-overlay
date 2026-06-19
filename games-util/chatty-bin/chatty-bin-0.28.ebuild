# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg-utils desktop

DESCRIPTION="Chat software specifically made for Twitch, in the spirit of a classic IRC Client."
HOMEPAGE="https://chatty.github.io/"
SRC_URI="https://github.com/chatty/chatty/releases/download/v${PV}/Chatty_${PV}.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=">=virtual/jre-1.8"
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}"

src_unpack() {
	unpack ${A}
}

src_install() {
	# Install jar
	insinto /usr/share/${PN}
	doins Chatty.jar

	# Wrapper script
	newbin - ${PN} <<-EOF
	#!/bin/sh
	exec java -jar /usr/share/${PN}/Chatty.jar "\$@"
	EOF

	# Desktop entry
	cat > "${T}/${PN}.desktop" <<-EOF
		[Desktop Entry]
		Name=Chatty
		Exec=${PN}
		Icon=${PN}
		Type=Application
		Categories=Network;Chat;
		Comment=Twitch chat client in the spirit of IRC
	EOF
	domenu "${T}/${PN}.desktop"

	# Icon (provide chatty.png/svg in overlay)
	doicon -s scalable "${FILESDIR}/${PN}.svg"
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

