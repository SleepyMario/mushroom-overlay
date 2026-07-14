# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1

DESCRIPTION="Local-first SQLite-backed terminal weight tracker"
HOMEPAGE="https://github.com/SleepyMario/weightrail"
SRC_URI="https://github.com/SleepyMario/weightrail/releases/download/v${PV}/${P}.tar.gz"
S="${WORKDIR}/${P}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="gui"

EPYTEST_PLUGINS=()

RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/plotext[${PYTHON_USEDEP}]
	gui? (
		dev-python/pygobject:3[${PYTHON_USEDEP}]
		x11-libs/gtk+:3[introspection]
	)
"

distutils_enable_tests pytest
