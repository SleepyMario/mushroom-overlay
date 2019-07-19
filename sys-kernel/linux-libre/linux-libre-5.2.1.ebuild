# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="GNU Linux-libre is a project to maintain and publish 100% Free distributions of Linux, suitable for use in Free System Distributions, removing software that is included without source code, with obfuscated or obscured source code, under non-Free Software licenses, that do not permit you to change the software so that it does what you wish, and that induces or requires you to install additional pieces of non-Free Software."
HOMEPAGE="https://fsfla.org/ikiwiki/linux-libre/index.en.html"
SRC_URI="http://linux-libre.fsfla.org/pub/${PN}/releases/${PV}-gnu/${P}-gnu.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

S=${WORKDIR}

# someday get rid of the 'addwrite' thing and slot them properly. Also the eselect option doesn't disappear after unmerging/depcleaning, which is odd even though the sources to stay in /usr/src. Not the end of the world though.

src_install() {
addwrite /usr/src/
cp -r ${S}/linux-${PV} /usr/src/${P} || die
}
