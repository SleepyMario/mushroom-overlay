# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit desktop systemd unpacker xdg

DESCRIPTION="Channel-bonding VPN client and graphical interface"
HOMEPAGE="https://speedify.com/"
MY_PV="${PV}-12947"
SRC_URI="
	https://apt.connectify.me/pool/main/s/speedify/speedify_${MY_PV}_amd64.deb
	gui? ( https://apt.connectify.me/pool/main/s/speedifyui/speedifyui_${MY_PV}_amd64.deb )
"
S="${WORKDIR}"
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+gui"
RESTRICT="bindist mirror strip"
RDEPEND="
	>=sys-libs/glibc-2.27
	sys-libs/libcap
	sys-apps/keyutils
	sys-apps/iproute2
	sys-apps/net-tools
	sys-process/procps
	net-firewall/iptables
	net-firewall/nftables
	net-libs/libnetfilter_conntrack
	gui? (
		net-libs/webkit-gtk:6
		gui-libs/gtk:4
		x11-libs/libnotify
		x11-misc/xdg-utils
	)
"
BDEPEND="$(unpacker_src_uri_depends)"
QA_PREBUILT="usr/share/speedify/* usr/share/speedifyui/*"

src_install() {
	dodir /usr/share
	cp -a usr/share/speedify "${ED}/usr/share/" || die
	dosym ../share/speedify/speedify_cli /usr/bin/speedify_cli
	systemd_dounit lib/systemd/system/speedify.service
	systemd_dounit lib/systemd/system/speedify-sharing.service
	insinto /etc/speedify
	newins usr/share/speedify/default.conf speedify.conf
	insinto /etc/apparmor.d
	doins etc/apparmor.d/usr.share.speedify.speedify
	if use gui; then
		cp -a usr/share/speedifyui "${ED}/usr/share/" || die
		# Select GTK4 directly, retaining WebKit's sandbox.
		printf '#!/bin/sh\nexec /usr/share/speedifyui/speedify_ui_webkit60 "$@"\n' \
			> "${ED}/usr/share/speedifyui/speedify_ui" || die
		rm "${ED}/usr/share/speedifyui/speedify_ui_webkit40" || die
		# Updates belong to Portage, not the Debian updater.
		printf '#!/bin/sh\nnotify-send Speedify "Update through Portage: net-vpn/speedify-bin"\n' \
			> "${ED}/usr/share/speedifyui/speedify_updater" || die
		domenu usr/share/applications/com.speedify.speedifyui.desktop
		doicon -s 64 usr/share/icons/hicolor/64x64/apps/*.png
		doicon -s scalable usr/share/icons/hicolor/scalable/apps/*.svg
		dodir /usr/share/speedifyui/logs
		fperms 1777 /usr/share/speedifyui/logs
	fi
}

pkg_postinst() {
	xdg_pkg_postinst
	elog "Installed without starting or enabling Speedify services."
	elog "Activate speedify.service when ready to configure your VPN."
	elog "speedify-sharing.service is optional; leave disabled for laptop use."
}
