# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )

inherit python-r1 xdg

DESCRIPTION="LightDM configuration tool"
HOMEPAGE="https://github.com/linuxmint/lightdm-settings"
SRC_URI="https://github.com/linuxmint/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

BDEPEND="
	sys-devel/gettext
"
DEPEND="${PYTHON_DEPS}"
RDEPEND="
	${DEPEND}
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	dev-python/setproctitle[${PYTHON_USEDEP}]
	sys-auth/polkit
	x11-apps/xrandr
	x11-libs/gtk+:3[introspection]
	x11-misc/lightdm
"

src_compile() {
	emake buildmo
}

src_install() {
	cp -a usr "${ED}" || die
	insinto /usr/lib/lightdm-settings/gtk-config/gtk-3.0
	newins "${FILESDIR}/gtk-settings.ini" settings.ini
	sed -i \
		-e '/subprocess.Popen/i os.environ.setdefault("XDG_CONFIG_HOME", "/usr/lib/lightdm-settings/gtk-config")' \
		-e '/subprocess.Popen/i os.environ.setdefault("GTK_THEME", "Adwaita:dark")' \
		"${ED}/usr/bin/lightdm-settings" || die
	python_foreach_impl python_fix_shebang \
		"${ED}/usr/bin/lightdm-settings" \
		"${ED}/usr/lib/lightdm-settings/lightdm-settings"
}
