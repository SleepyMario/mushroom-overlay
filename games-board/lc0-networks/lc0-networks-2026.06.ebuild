# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Reminder: bump this ebuild every 6 months by date (e.g. lc0-networks-2026.06).
# Latest networks can be fetched manually from:
# https://lczero.org/play/best-networks/
# Pin the SHA here and place the .pb.gz in DISTDIR.

DESCRIPTION="Live neural network weights for Leela Chess Zero"
HOMEPAGE="https://lczero.org/"
NETWORK_SHA=6147500
SRC_URI="https://training.lczero.org/networks/${NETWORK_SHA}/download -> network-${NETWORK_SHA}.pb.gz"
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

S="${WORKDIR}"

src_install() {
	insinto /usr/share/lc0/networks
	doins "${DISTDIR}/network-${NETWORK_SHA}.pb.gz"
	dosym "network-${NETWORK_SHA}.pb.gz" /usr/share/lc0/networks/network.pb.gz
}

pkg_postinst() {
	einfo "Lc0 neural network installed to /usr/share/lc0/networks/network.pb.gz"
	einfo "Point your GUI (Scid, Scid vs. PC, Arena) to this file when configuring the lc0 engine."
}
