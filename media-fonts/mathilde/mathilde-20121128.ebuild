# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Mathilde handwritten cursive/print hybrid typeface with accented letters, math symbols, and contextual alternatives"
HOMEPAGE="https://www.dafont.com/mathilde.font"
SRC_URI="https://dl.dafont.com/dl/?f=mathilde -> ${P}.zip"

LICENSE="free-noncomm"  # adjust if upstream provides a clearer license
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=""
RDEPEND=""
BDEPEND="app-arch/unzip"

S="${WORKDIR}"

src_install() {
	insinto /usr/share/fonts/${PN}
	doins *.otf || die "No OTF font found"
}

