# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Snack patched for use with alsa and scid_vs_pc."
HOMEPAGE="http://http://scidvspc.sourceforge.net/"
SRC_URI="https://sourceforge.net/projects/scidvspc/files/support%20files/snack2.2.10.scidvspc.tgz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

CDEPEND="
		>=dev-lang/tk-8.6
		>=dev-lang/tcl-8.6
		media-libs/alsa-lib"
DEPEND="${CDEPEND}"
RDEPEND="${DEPEND}"

S="${WORKDIR}/snack2.2.10.scidvspc/unix"
