# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Electron prebuilt binary for Linux"
HOMEPAGE="https://www.electronjs.org/"
SRC_URI="https://github.com/electron/electron/releases/download/v${PV}/electron-v${PV}-linux-x64.zip -> ${P}.zip"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	app-arch/unzip
	sys-libs/glibc
"

S="${WORKDIR}"

src_unpack() {
	unpack ${P}.zip
}

src_install() {
	# Install Electron binary
	dobin electron

	# Install supporting files
	insinto /usr/share/electron-bin
	doins -r locales resources *.pak *.bin *.dat
}

