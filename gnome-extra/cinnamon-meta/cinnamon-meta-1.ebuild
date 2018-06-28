# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A meta ebuild for chess-related ebuilds."
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="+brasero +eog +file-roller +gedit +gnome-system-monitor +gnome-screenshot +gnome-terminal +qpdfview"

DEPEND="${CDEPEND}"
RDEPEND="${DEPEND}
		brasero? ( app-cdr/brasero )
		eog? ( media-gfx/eog )
		fileroller? ( app-arch/fileroller )
		gedit? ( app-editors/gedit )
		gnome-screenshot? ( media-gfx/gnome-screenshot )
		gnome-system-monitor ( gnome-extra/gnome-system-monitor )
		gnome-terminal? ( x11-terms/gnome-terminal[-nautilus,-gnome-shell] )
		qpdfview? ( app-text/qpdfview[qt5] )
		gnome-extra/cinnamon
		x11-libs/gtk+extra
"

pkg_postinst() {
	elog "Enjoy!"
}
