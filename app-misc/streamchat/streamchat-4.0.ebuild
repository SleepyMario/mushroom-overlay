# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake desktop go-module systemd

DESCRIPTION="Multi-platform live-chat client, native GUI, and relay server"
HOMEPAGE="https://github.com/SleepyMario/streamchat"
SRC_URI="
	https://github.com/SleepyMario/streamchat/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/SleepyMario/streamchat/releases/download/v${PV}/${P}-vendor.tar.xz
"

LICENSE="MIT Apache-2.0 BSD BSD-2 ISC"
SLOT="0"
KEYWORDS="~amd64"

IUSE="+cli +gui server bot"
REQUIRED_USE="
	|| ( cli gui server )
	bot? ( server )
"

CMAKE_USE_DIR="${S}/desktop"

BDEPEND=">=dev-lang/go-1.24"
RDEPEND="
	server? ( acct-user/streamchat )
	gui? (
		dev-qt/qtbase:6[gui,network]
		dev-qt/qtdeclarative:6
	)
"

DOCS=(
	README.md
	LICENSE
	CONTRIBUTING.md
)

src_configure() {
	use gui && cmake_src_configure
}

src_compile() {
	GOPROXY=off GOFLAGS="-mod=vendor" ego build -trimpath -buildvcs=false \
		-ldflags "-X main.version=${PV}" \
		-o streamchat-core ./cmd/streamchat
	if use gui; then
		GOPROXY=off GOFLAGS="-mod=vendor" ego build -trimpath -buildvcs=false \
			-ldflags "-X main.version=${PV}" \
			-o streamchat-gui-runtime ./cmd/streamchat-gui
		cmake_src_compile
	fi
}

src_test() {
	TMPDIR=/tmp GOPROXY=off GOFLAGS="-mod=vendor" ego test ./...
}

src_install() {
	exeinto /usr/libexec/streamchat
	doexe streamchat-core

	if use cli; then
		dosym ../libexec/streamchat/streamchat-core /usr/bin/streamchat
	fi

	if use gui; then
		doexe streamchat-gui-runtime
		doexe "${BUILD_DIR}"/streamchat-gui
		dosym ../libexec/streamchat/streamchat-gui /usr/bin/streamchat-gui
		domenu desktop/packaging/com.sleepymario.streamchat.desktop
		doicon -s scalable desktop/assets/com.sleepymario.streamchat.svg
	fi

	if use server; then
		systemd_dounit systemd/streamchat-server.service
	fi

	einstalldocs
	docinto examples
	dodoc examples/config.example.json
}

pkg_postinst() {
	if use server; then
		elog "A dedicated streamchat account was installed for the headless service."
		elog "streamchat-server.service reads /etc/streamchat/config.json."
		elog "It stores its SQLite archive under /var/lib/streamchat by default."
		use bot && elog "Integrated bot automation is available through the server configuration."
	fi
}
