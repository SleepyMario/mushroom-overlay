# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# /usr/local/portage/app-misc/copilot-desktop-snap/copilot-desktop-snap-1.ebuild

EAPI=8

DESCRIPTION="Unofficial Copilot Electron client (Snap wrapper)"
HOMEPAGE="https://github.com/levicm/copilot-desktop"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

SRC_URI=""
S="${WORKDIR}"

DEPEND="app-containers/snapd"
RDEPEND="${DEPEND}"

src_install() {
	# Wrapper script
	exeinto /usr/bin
	newexe - copilot-desktop-snap <<'EOF'
#!/bin/sh
exec /snap/bin/copilot-desktop "$@"
EOF

	# Desktop entry
	insinto /usr/share/applications
	newins - copilot-desktop-snap.desktop <<'EOF'
[Desktop Entry]
Name=Copilot Desktop (Snap)
Exec=/usr/bin/copilot-desktop-snap
Icon=copilot-desktop
Type=Application
Categories=Utility;
EOF

	# Icon placeholder (will be overwritten by Snap if present)
	insinto /usr/share/pixmaps
	newins /dev/null copilot-desktop.png
}

pkg_postinst() {
	einfo "Installing Copilot Desktop via Snap..."
	snap install copilot-desktop || ewarn "Snap install failed, please run manually."
	if [ -f /snap/copilot-desktop/current/meta/gui/icon.png ]; then
        cp /snap/copilot-desktop/current/meta/gui/icon.png /usr/share/pixmaps/copilot-desktop.png || ewarn "Icon copy failed"
    fi
}

