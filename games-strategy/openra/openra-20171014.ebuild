# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils mono-env gnome2-utils vcs-snapshot fdo-mime

DESCRIPTION="A free RTS engine supporting games like Command & Conquer, Red Alert and Dune2k"
HOMEPAGE="http://www.openra.net"
SRC_URI="https://github.com/OpenRA/OpenRA/archive/release-20171014.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+debug doc -nuget +xdg +zenity"
RESTRICT="mirror"

DEPEND=""
RDEPEND="${DEPEND}"

pkg_setup() {
	mono-env_pkg_setup
}

src_unpack() {
	vcs-snapshot_src_unpack
}

src_prepare() {
	local NUGET=$(usex nuget "true" "false");
	sed "s/if \[ ! \$TRAVIS \]/if ${NUGET} \&\& \[ ! \$TRAVIS \]/" \
		-i thirdparty/fetch-thirdparty-deps.sh || die
	emake cli-dependencies
}

src_compile() {
	emake $(usex debug "" "DEBUG=false")
	emake VERSION=${MY_PV} docs man-page
}

src_install()
{
	emake $(usex debug "" "DEBUG=false") \
		datadir="/usr/share/games" \
		bindir="/usr/games/bin" \
		libdir="/usr/games/$(get_libdir)/${PN}" \
		gameinstalldir="/usr/share/games/${PN}" \
		DESTDIR="${D}" \
		install install-linux-scripts install-man-page
	emake \
		datadir="/usr/share" \
		DESTDIR="${D}" install-linux-mime install-linux-icons

	# desktop entries
	make_desktop_entry "${PN} Game.Mod=cnc" "OpenRA ver. ${MY_PV}" ${PN} \
		"StrategyGame" "GenericName=OpenRA - Command & Conquer"
	make_desktop_entry "${PN} Game.Mod=ra" "OpenRA ver. ${MY_PV}" ${PN} \
		"StrategyGame" "GenericName=OpenRA - Red Alert"
	make_desktop_entry "${PN} Game.Mod=d2k" "OpenRA ver. ${MY_PV}" ${PN} \
		"StrategyGame" "GenericName=OpenRA - Dune 2000"

	# desktop directory
	insinto /usr/share/desktop-directories
	doins "${FILESDIR}"/${PN}.directory

	# desktop menu
	insinto /etc/xdg/menus/applications-merged
	doins "${FILESDIR}"/games-${PN}.menu

	# docs
	dodoc "${FILESDIR}"/README.gentoo
	if [[ -n "$(type -P markdown)" ]] ; then
		local file; for file in {README,CONTRIBUTING,DOCUMENTATION,Lua-API}; do \
		markdown ${file}.md > ${file}.html && dohtml ${file}.html || die; done
	elif [[ -n "$(type -P markdown_py)" ]] ; then
		local file; for file in {README,CONTRIBUTING,DOCUMENTATION,Lua-API}; do \
		markdown_py ${file}.md > ${file}.html && dohtml ${file}.html || die; done
	elif [[ -n "$(type -P Markdown.pl)" ]] ; then
		local file; for file in {README,CONTRIBUTING,DOCUMENTATION,Lua-API}; do \
		Markdown.pl ${file}.md > ${file}.html && dohtml ${file}.html || die; done
	else
		dodoc {README,CONTRIBUTING,DOCUMENTATION,Lua-API}.md
	fi
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}


