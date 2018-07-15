# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A meta ebuild for mutt related things."
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND="${CDEPEND}"
RDEPEND="${DEPEND}
		app-misc/abook
		app-misc/muttprint
		app-text/catdoc
		mail-client/mutt
		media-gfx/fim
		net-mail/offlineimap
		www-client/w3m
		"
