# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_6 )
EGO_PN=github.com/firecat53/${PN}

inherit distutils-r1

if [[ ${PV} = *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/firecat53/urlscan.git"
	KEYWORDS=""
else
	KEYWORDS="~amd64"
	EGIT_COMMIT="${PV}"
	SRC_URI="https://${EGO_PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
fi

DESCRIPTION="Mutt and terminal URL selector (similar to urlview)"
HOMEPAGE="https://github.com/firecat53/urlscan"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="dev-python/urwid"
DEPEND="${RDEPEND}"
