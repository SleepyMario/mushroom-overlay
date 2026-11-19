# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )
inherit desktop distutils-r1 git-r3 xdg-utils

DESCRIPTION="WebKitGTK desktop client for a central Kylin service"
HOMEPAGE="https://github.com/SleepyMario/mushroom-overlay/tree/main/src/kylin-client"
EGIT_REPO_URI="https://github.com/SleepyMario/mushroom-overlay.git"
EGIT_BRANCH="main"
S="${WORKDIR}/${P}/src/${PN}"

LICENSE="MIT"
SLOT="0"
IUSE="+gui"

RDEPEND="gui? (
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	x11-libs/gtk+:3[introspection]
	>=net-libs/webkit-gtk-2.44:4.1[introspection]
)"

distutils_enable_tests unittest

python_test() {
	"${EPYTHON}" -m unittest discover -s tests -v || die "Client tests failed"
}

python_install_all() {
	distutils-r1_python_install_all
	if use gui; then
		domenu share/com.sleepymario.KylinClient.desktop
		doicon -s scalable share/${PN}.svg
	fi
}

pkg_postinst() {
	if use gui; then
		xdg_icon_cache_update
		xdg_desktop_database_update
	fi
	elog "Run kylin-client to configure your central Kylin service."
	elog "The application window uses the system WebKitGTK engine."
	elog "Use --no-open to run just the local client proxy."
	elog "Connection settings: kylin-client --configure. No model or archive is installed."
}

pkg_postrm() {
	if use gui; then
		xdg_icon_cache_update
		xdg_desktop_database_update
	fi
}
