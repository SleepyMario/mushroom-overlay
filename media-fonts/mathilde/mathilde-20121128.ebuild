# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION=""Mathilde" is a handwritten, cursive/print hybrid typeface that includes accented letterforms, math symbols, as well as opentype contextual alternatives for common double-letter combinations."
HOMEPAGE="https://www.dafont.com/mathilde.font"
SRC_URI="
		https://dl.dafont.com/dl/?f=mathilde -> mathilde.zip
		http://leeviathan.com/wp-content/uploads/mathilde-ttf.zip
		"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE="otf ttf"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

#S=/var/tmp/portage/media-fonts/mathilde-20121128/work/
S=${WORKDIR}

src_install() {
	addwrite /usr/share/fonts/
	mkdir -p /usr/share/fonts/mathilde
	cp ${S}/${PN}.otf /usr/share/fonts/mathilde/${PN}.otf || die
	cp ${S}/${PN}-ttf.ttf /usr/share/fonts/mathilde/${PN}.ttf || die
	}
