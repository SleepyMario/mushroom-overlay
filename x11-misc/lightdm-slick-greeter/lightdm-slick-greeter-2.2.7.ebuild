# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

VALA_MIN_API_VERSION="0.34"

inherit gnome2-utils meson vala

DESCRIPTION="LightDM greeter forked from Unity by Linux Mint team"
HOMEPAGE="https://github.com/linuxmint/slick-greeter"
SRC_URI="${HOMEPAGE}/archive/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN//lightdm-}-${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	$(vala_depend)
	sys-devel/gettext
"
DEPEND="
	>=x11-misc/lightdm-1.12[introspection,vala]
	media-libs/libcanberra
	x11-libs/cairo
	x11-libs/gtk+:3[X]
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/pixman
"
RDEPEND="
	${DEPEND}
"

src_prepare() {
	default
	vala_setup
}

src_install() {
	meson_src_install

	insinto /etc/lightdm
	doins "${FILESDIR}/${PN//lightdm-}.conf"
}

pkg_preinst() {
	gnome2_schemas_savelist
}

pkg_postinst() {
	gnome2_schemas_update
	elog "To enable slick-greeter, set greeter-session=slick-greeter"
	elog "in /etc/lightdm/lightdm.conf, then restart your session and LightDM."
}

pkg_postrm() {
	gnome2_schemas_update
}
