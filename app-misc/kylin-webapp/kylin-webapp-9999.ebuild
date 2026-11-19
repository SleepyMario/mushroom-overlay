# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )
inherit desktop distutils-r1 git-r3

DESCRIPTION="Configurable app-window client for a central Kylin service"
HOMEPAGE="https://github.com/SleepyMario/mushroom-overlay/tree/main/src/kylin-webapp"
EGIT_REPO_URI="https://github.com/SleepyMario/mushroom-overlay.git"
EGIT_BRANCH="main"
S="${WORKDIR}/${P}/src/${PN}"

LICENSE="MIT"
SLOT="0"
IUSE="+gui"

RDEPEND="gui? ( dev-python/pyqt6[gui,widgets,${PYTHON_USEDEP}] )"

distutils_enable_tests unittest

python_test() {
	"${EPYTHON}" -m unittest discover -s tests -v || die "Client tests failed"
}

python_install_all() {
	distutils-r1_python_install_all
	if use gui; then
		domenu share/${PN}.desktop
		doicon -s scalable share/${PN}.svg
	fi
}

pkg_postinst() {
	elog "Run kylin-webapp to configure your central Kylin service."
	elog "App windows use an existing Chromium-family browser (e.g. Brave or Chrome)."
	elog "Alternatively use --browser for your default browser, or --no-open."
	elog "Connection settings: kylin-webapp --configure. No model or archive is installed."
}
