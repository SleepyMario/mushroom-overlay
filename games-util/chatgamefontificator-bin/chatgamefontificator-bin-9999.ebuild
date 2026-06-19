# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg-utils desktop

DESCRIPTION="A Twitch chat display that uses the fonts of various video games"
HOMEPAGE="https://chatty.github.io/"
SRC_URI="https://github.com/GlitchCog/ChatGameFontificator/raw/master/jar/ChatGameFontificator.jar -> ${P}.jar"

LICENSE="Unlicense"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=">=virtual/jre-1.8"
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}"

src_unpack() {
	cp "${DISTDIR}/${P}.jar" "${S}/" || die
}

src_install() {
	# Install jar
	insinto /usr/share/${PN}
	doins "${S}/${P}.jar"

	# Inline wrapper script
	newbin - ${PN} <<-EOF
	#!/bin/sh
	exec java -jar /usr/share/${PN}/${P}.jar "\$@"
	EOF

	# Inline desktop entry
	cat > "${T}/${PN}.desktop" <<-EOF
	[Desktop Entry]
	Name=ChatGameFontificator
	Exec=${PN}
	Icon=${PN}
	Type=Application
	Categories=Network;Chat;
	Comment=Twitch chat display with game fonts
	EOF
	domenu "${T}/${PN}.desktop"

# Install icon (simple letter-style PNG)
	# Here we generate a placeholder icon; in practice you’d ship a real PNG/SVG.
	# For demonstration, we’ll just create a tiny blank PNG with ImageMagick.
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

