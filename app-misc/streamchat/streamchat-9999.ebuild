# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

EGIT_REPO_URI="https://github.com/SleepyMario/streamchat.git"
EGIT_BRANCH="main"

inherit git-r3 go-module

DESCRIPTION="CLI-first merged live chat reader for YouTube and Kick"
HOMEPAGE="https://github.com/SleepyMario/streamchat"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""

BDEPEND="
	>=dev-lang/go-1.24
"

DOCS=(
	README.md
	LICENSE
	CONTRIBUTING.md
)

src_unpack() {
	git-r3_src_unpack
	# Streamchat currently has no external modules.  This preserves the
	# go-module live-ebuild workflow without inventing a dependency archive.
	go-module_live_vendor
}

src_compile() {
	GOPROXY=off ego build -trimpath -buildvcs=false -o streamchat ./cmd/streamchat
}

src_test() {
	GOPROXY=off ego test ./...
}

src_install() {
	dobin streamchat
	einstalldocs
	docinto examples
	dodoc examples/config.example.json
}
