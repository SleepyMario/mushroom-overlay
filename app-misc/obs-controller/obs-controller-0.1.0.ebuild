EAPI=8
inherit go-module systemd
DESCRIPTION="OBS controller and Gentoo desktop companion for the Android controller"
HOMEPAGE="https://github.com/SleepyMario/obs-controller"
SRC_URI="https://github.com/SleepyMario/obs-controller/releases/download/v${PV}/${P}.tar.gz
 https://github.com/SleepyMario/obs-controller/releases/download/v${PV}/${P}-vendor.tar.xz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cava"
RESTRICT="fetch"
BDEPEND=">=dev-lang/go-1.24"
RDEPEND="media-video/obs-studio media-video/ffmpeg cava? ( media-sound/cava )"
DOCS=( README.md android/README.md docs/gentoo-lifecycle.md )
pkg_nofetch() {
 elog "This project's release assets are private. Authenticate with GitHub, then run:"
 elog "gh release download v${PV} -R SleepyMario/obs-controller -p '${P}*.tar.*'"
 elog "Place ${P}.tar.gz and ${P}-vendor.tar.xz in ${DISTDIR}."
}
src_unpack() {
 default
 mv "${WORKDIR}/vendor" "${S}/vendor" || die
}
src_compile() {
 local command
 for command in obs-controller streamchat-obs-agent km-counter; do
  GOPROXY=off GOFLAGS=-mod=vendor ego build -trimpath -buildvcs=false \
   -ldflags "-X main.version=${PV}" -o "${command}" "./cmd/${command}"
 done
}
src_test() {
 GOPROXY=off GOFLAGS=-mod=vendor ego test ./...
}
src_install() {
 dobin obs-controller streamchat-obs-agent km-counter
 systemd_douserunit packaging/systemd/*.service
 einstalldocs
 insinto /usr/share/doc/${PF}/examples
 doins packaging/agent.example.json packaging/controller.example.env
}
pkg_postinst() {
 elog "No service has been enabled and no OBS profile or private configuration changed."
 elog "Configure the desktop-user companion before enabling obs-controller-agent.service."
 elog "Do not enable it alongside an existing streaming-agent.service."
 elog "Linux microphone/subtitle capture is not yet supported. Android requires the host and WireGuard."
}
