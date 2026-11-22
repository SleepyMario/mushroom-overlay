# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8
PYTHON_COMPAT=( python3_{12..14} )
inherit python-single-r1
MY_P="${PN}-0.1.0-alpha.1"
DESCRIPTION="Mushroom GNOME workspace dock and bottom status panel"
HOMEPAGE="https://github.com/SleepyMario/mushroom-desktop"
SRC_URI="https://github.com/SleepyMario/mushroom-desktop/releases/download/v0.1.0-alpha.1/${MY_P}.tar.xz"
S="${WORKDIR}/${MY_P}"
LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RDEPEND="${PYTHON_DEPS}
 || ( =gnome-base/gnome-shell-46* =gnome-base/gnome-shell-49* =gnome-base/gnome-shell-50* )
 dev-libs/gjs
 net-libs/libsoup:3.0[introspection]
 x11-misc/xdg-utils
"
src_compile() { :; }
src_install() {
 emake DESTDIR="${D}" DOCDIR="/usr/share/doc/${PF}" install
 python_fix_shebang "${ED}/usr/bin/mushroom-desktop" "${ED}/usr/share/gnome-shell/extensions/workspaces-to-dock-codex@local/gpuMonitor.py"
}
pkg_postinst() {
 elog "Extensions are installed but not automatically enabled."
 elog "Run mushroom-desktop status in your GNOME session."
 elog "Existing local copies and all user settings are preserved."
}
