# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Terminal review sessions for Anki through AnkiConnect"
HOMEPAGE="https://github.com/SleepyMario/WhackSmacker"
SRC_URI="https://github.com/SleepyMario/WhackSmacker/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/WhackSmacker-${PV}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	dev-lang/typescript
	net-libs/nodejs
"
RDEPEND="net-libs/nodejs"

src_compile() {
	tsc || die
}

src_test() {
	node --test test/*.test.mjs || die
}

src_install() {
	insinto "/usr/share/${PN}"
	doins -r COPYING dist package.json README.md

	dosym "../share/${PN}/dist/main.js" "/usr/bin/${PN}"
	fperms +x "/usr/share/${PN}/dist/main.js"
}
