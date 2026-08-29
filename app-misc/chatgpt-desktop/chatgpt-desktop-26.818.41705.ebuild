# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker xdg

DESCRIPTION="Official ChatGPT desktop app for Linux"
HOMEPAGE="https://chatgpt.com/ https://learn.chatgpt.com/docs/linux/linux-app"
SRC_URI="https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${PV}_amd64.deb"

S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-arch/xz-utils
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libusb:1
	dev-libs/nspr
	dev-libs/nss
	dev-libs/wayland
	media-libs/alsa-lib
	media-libs/libglvnd[X]
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	virtual/udev
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3[X,wayland]
	x11-libs/libdrm
	x11-libs/libnotify
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/pango
	x11-misc/xdg-utils
"

QA_PREBUILT="*"
# Upstream bundles unused musl, Android, arm, and arm64 Node prebuilds alongside
# the amd64 glibc modules selected at runtime.
REQUIRES_EXCLUDE="
	usr/lib/chatgpt/resources/app.asar.unpacked/node_modules/@worklouder/device-kit-oai/*/prebuilds/android-*/*
	usr/lib/chatgpt/resources/app.asar.unpacked/node_modules/@worklouder/device-kit-oai/*/prebuilds/*linux-arm*/*
	*musl*
"

pkg_pretend() {
	[[ ${ELIBC} == glibc ]] || die "The official ChatGPT binary requires glibc"
}

src_prepare() {
	default

	# Debian-only package-manager metadata has no place on Gentoo.
	rm -r usr/share/lintian || die
	mv usr/share/doc/chatgpt usr/share/doc/${PF} || die
}

src_install() {
	dodir /
	cp -a etc usr "${ED}"/ || die
}
