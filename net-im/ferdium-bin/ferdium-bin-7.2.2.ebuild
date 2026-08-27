# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop optfeature unpacker xdg

MY_DEB="Ferdium-linux-${PV}-amd64.deb"

DESCRIPTION="Desktop app that combines messaging services in one application"
HOMEPAGE="https://ferdium.org https://github.com/ferdium/ferdium-app"
SRC_URI="
	https://github.com/ferdium/ferdium-app/releases/download/v${PV}/${MY_DEB}
	https://raw.githubusercontent.com/ferdium/ferdium-app/v${PV}/LICENSE.md
		-> ${P}-LICENSE.md
"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="wayland"
RESTRICT="splitdebug"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	virtual/udev
	x11-libs/cairo
	x11-libs/gtk+:3[X]
	x11-libs/libnotify
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/pango
	x11-misc/xdg-utils
	wayland? (
		dev-libs/wayland
		x11-libs/gtk+:3[wayland]
		x11-libs/libxkbcommon[wayland]
	)
"

QA_PREBUILT="
	opt/ferdium/chrome-sandbox
	opt/ferdium/chrome_crashpad_handler
	opt/ferdium/ferdium
	opt/ferdium/libEGL.so
	opt/ferdium/libGLESv2.so
	opt/ferdium/libffmpeg.so
	opt/ferdium/libvk_swiftshader.so
	opt/ferdium/libvulkan.so.1
"

src_unpack() {
	unpacker "${MY_DEB}"
	cp "${DISTDIR}/${P}-LICENSE.md" LICENSE.md || die
}

src_prepare() {
	default

	sed -e 's|^Exec=/opt/Ferdium/ferdium|Exec=ferdium|' \
		-i usr/share/applications/ferdium.desktop || die
	gunzip usr/share/doc/ferdium/changelog.gz || die

	cp "${FILESDIR}/ferdium" "${T}/ferdium" || die
	local flags=
	if use wayland; then
		flags=" --enable-features=UseOzonePlatform --ozone-platform=wayland"
	fi
	sed -e "s|@ELECTRON_FLAGS@|${flags}|" -i "${T}/ferdium" || die
}

src_install() {
	insinto /opt/ferdium
	doins -r opt/Ferdium/.

	fperms 0755 \
		/opt/ferdium/chrome_crashpad_handler \
		/opt/ferdium/ferdium \
		/opt/ferdium/libEGL.so \
		/opt/ferdium/libGLESv2.so \
		/opt/ferdium/libffmpeg.so \
		/opt/ferdium/libvk_swiftshader.so \
		/opt/ferdium/libvulkan.so.1
	fperms 4755 /opt/ferdium/chrome-sandbox

	dobin "${T}/ferdium"

	domenu usr/share/applications/ferdium.desktop
	insinto /usr/share/icons
	doins -r usr/share/icons/hicolor

	dodoc LICENSE.md usr/share/doc/ferdium/changelog
}

pkg_postinst() {
	xdg_pkg_postinst
	optfeature "system tray indicator support" dev-libs/libayatana-appindicator

	if use wayland; then
		elog "Native Wayland support is enabled through Electron's Ozone backend."
		elog "If it is less reliable with your compositor, rebuild with USE=-wayland"
		elog "to run Ferdium through X11 or XWayland instead."
	else
		elog "Enable the wayland USE flag to use Electron's native Ozone Wayland backend."
		elog "Native Wayland can occasionally be less reliable than XWayland."
	fi
}
