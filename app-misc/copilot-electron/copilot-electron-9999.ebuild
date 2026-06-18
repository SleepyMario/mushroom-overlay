EAPI=8

DESCRIPTION="Microsoft Copilot Electron desktop client (live Git build)"
HOMEPAGE="https://github.com/microsoft/copilot"
EGIT_REPO_URI="git@github.com:microsoft/copilot.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE=""

inherit git-r3

DEPEND="
	net-libs/nodejs
	sys-apps/pnpm
"
RDEPEND="
	${DEPEND}
	dev-util/electron-bin
"

src_compile() {
	pnpm install --frozen-lockfile
	pnpm build
}

src_install() {
	insinto /opt/copilot-electron
	doins -r dist/*

	# Symlink to binary
	dosym /opt/copilot-electron/copilot /usr/bin/copilot-electron
}

