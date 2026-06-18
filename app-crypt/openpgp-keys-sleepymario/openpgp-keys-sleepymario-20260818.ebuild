# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# app-crypt/openpgp-keys-sleepymario/openpgp-keys-sleepymario-20260618.ebuild
EAPI=8

DESCRIPTION="OpenPGP key for Sleepy Mario (mushroom overlay signing)"
HOMEPAGE="https://github.com/SleepyMario/mushroom-overlay"
SRC_URI="https://raw.githubusercontent.com/SleepyMario/mushroom-overlay/main/keys/sleepymario.asc -> sleepymario.asc"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="amd64 x86"

RESTRICT="mirror strip binchecks test"

src_unpack() { :; }
src_prepare() { :; }
src_configure() { :; }
src_compile() { :; }
src_test() { :; }


src_install() {
	insinto /usr/share/openpgp-keys
	doins "${FILESDIR}/sleepymario.asc"
}

