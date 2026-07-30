# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="Extensible Vulkan benchmarking suite"
HOMEPAGE="https://github.com/vkmark/vkmark"
SRC_URI="https://github.com/vkmark/vkmark/archive/refs/tags/${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+wayland X drm"

RDEPEND="
	media-libs/assimp:=
	media-libs/vulkan-loader[X?,wayland?]
	wayland? ( dev-libs/wayland )
	X? (
		x11-libs/libxcb:=
		x11-libs/xcb-util-wm
	)
	drm? (
		media-libs/mesa[gbm(+)]
		x11-libs/libdrm
	)
"
DEPEND="
	${RDEPEND}
	dev-util/vulkan-headers
	media-libs/glm
	wayland? ( >=dev-libs/wayland-protocols-1.12 )
"
BDEPEND="
	virtual/pkgconfig
	wayland? ( dev-util/wayland-scanner )
"

src_configure() {
	local emesonargs=(
		$(meson_use X xcb)
		$(meson_use wayland wayland)
		$(meson_use drm kms)
	)

	meson_src_configure
}
