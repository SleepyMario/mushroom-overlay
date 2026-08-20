# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RPM_COMPRESS_TYPE="xz"
inherit desktop rpm xdg

DESCRIPTION="Desktop client for Proton Mail and Proton Calendar"
HOMEPAGE="https://proton.me/mail https://github.com/ProtonMail/WebClients"
SRC_URI="https://proton.me/download/mail/linux/${PV}/ProtonMail-desktop-beta.rpm -> ${P}.rpm"
S="${WORKDIR}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="strip"

RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	virtual/udev
	x11-libs/cairo
	x11-libs/gtk+:3[X]
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
"

QA_PREBUILT="opt/proton-mail/*"

src_install() {
	insinto /opt/proton-mail
	doins -r usr/lib/proton-mail/.

	fperms 0755 \
		"/opt/proton-mail/Proton Mail Beta" \
		/opt/proton-mail/chrome_crashpad_handler \
		/opt/proton-mail/libEGL.so \
		/opt/proton-mail/libGLESv2.so \
		/opt/proton-mail/libffmpeg.so \
		/opt/proton-mail/libvk_swiftshader.so \
		/opt/proton-mail/libvulkan.so.1
	fperms 4755 /opt/proton-mail/chrome-sandbox

	dosym "../../opt/proton-mail/Proton Mail Beta" /usr/bin/proton-mail
	domenu usr/share/applications/proton-mail.desktop
	newicon usr/share/pixmaps/proton-mail.png proton-mail.png
	dodoc usr/share/doc/proton-mail/copyright
}
