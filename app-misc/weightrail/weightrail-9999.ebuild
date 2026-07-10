# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 git-r3

DESCRIPTION="Local-first SQLite-backed terminal weight tracker"
HOMEPAGE="https://github.com/SleepyMario/weight-tracker-cli"
EGIT_REPO_URI="https://github.com/SleepyMario/weight-tracker-cli.git"

LICENSE="MIT"
SLOT="0"
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
