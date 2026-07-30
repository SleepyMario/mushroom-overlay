# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg-utils

MY_PN="PyGPT"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Desktop AI assistant powered by multiple LLM providers"
HOMEPAGE="https://pygpt.net https://github.com/szczyglis-dev/py-gpt"
SRC_URI="https://github.com/szczyglis-dev/py-gpt/releases/download/v${PV}/${MY_P}-x86_64.AppImage -> ${P}-x86_64.AppImage"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip"

RDEPEND="
	sys-fs/fuse:0
"

S="${WORKDIR}"
QA_PREBUILT="opt/${PN}/${MY_P}.AppImage"

src_unpack() {
	cp "${DISTDIR}/${A}" "${S}/${MY_P}.AppImage" || die
}

src_install() {
	exeinto "/opt/${PN}"
	doexe "${MY_P}.AppImage"

	newbin - pygpt <<-EOF
	#!/bin/sh
	export QT_ENABLE_HIGHDPI_SCALING="\${QT_ENABLE_HIGHDPI_SCALING:-1}"
	export QT_SCALE_FACTOR="\${QT_SCALE_FACTOR:-2}"
	exec /opt/${PN}/${MY_P}.AppImage "\$@"
	EOF

	cat > "${T}/pygpt.desktop" <<-EOF
	[Desktop Entry]
	Type=Application
	Name=PyGPT
	Comment=${DESCRIPTION}
	Categories=Utility;Network;
	Exec=pygpt
	TryExec=pygpt
	EOF
	domenu "${T}/pygpt.desktop"
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
