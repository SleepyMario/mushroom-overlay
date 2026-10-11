# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

DESCRIPTION="Ready-to-use real-time media server and media proxy"
HOMEPAGE="https://github.com/bluenviron/mediamtx"
SRC_URI="
	amd64? ( https://github.com/bluenviron/mediamtx/releases/download/v${PV}/mediamtx_v${PV}_linux_amd64.tar.gz )
	arm64? ( https://github.com/bluenviron/mediamtx/releases/download/v${PV}/mediamtx_v${PV}_linux_arm64.tar.gz )
"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="mirror strip"

RDEPEND="acct-user/mediamtx"

QA_PREBUILT="usr/bin/mediamtx"

src_install() {
	dobin mediamtx

	insinto /etc/mediamtx
	newins mediamtx.yml mediamtx.yml

	newinitd "${FILESDIR}"/mediamtx.initd mediamtx
	systemd_dounit "${FILESDIR}"/mediamtx.service

	keepdir /var/lib/mediamtx
	fowners mediamtx:mediamtx /var/lib/mediamtx

	dodoc LICENSE
}

pkg_postinst() {
	elog "MediaMTX was installed without enabling or starting its service."
	elog "Review /etc/mediamtx/mediamtx.yml before activation."
}
