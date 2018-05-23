# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Total uglyness!"

SLOT="0"

RDEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	dev-qt/qtdbus:5
	dev-qt/qtx11extras:5
	dev-qt/qtmultimedia:5[widgets]
	dev-qt/qtsvg:5
	dev-qt/qtopengl
	x11-libs/libxcb[xkb]
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-image
	x11-libs/xcb-util-wm
	x11-libs/xcb-util-keysyms
	!<=dde-base/dde-qt5integration-0.2.7
	"
