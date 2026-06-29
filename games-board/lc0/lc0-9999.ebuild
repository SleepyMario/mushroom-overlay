# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# dev/cpp/gest AND lc0 BOTH NEED TO BE BUILT WITH GCC13 FOR NOW.

EAPI=8

inherit meson git-r3

DESCRIPTION="Neural-network chess engine"
HOMEPAGE="https://github.com/LeelaChessZero/lc0/"

# Update with scripts/update-lc0-network.sh.
NETWORK_URI="https://storage.lczero.org/files/networks-contrib/BT4-1024x15x32h-swa-6147500-policytune-332.pb.gz"
NETWORK_FILE="${NETWORK_URI##*/}"
EGIT_REPO_URI="https://github.com/LeelaChessZero/lc0.git"
EGIT_COMMIT="v0.32.1"
EGIT_SUBMODULES=( libs/lczero-common )
SRC_URI="
	https://github.com/abseil/abseil-cpp/releases/download/20240722.0/abseil-cpp-20240722.0.tar.gz
	networks? (
		${NETWORK_URI} -> network-${NETWORK_FILE}
	)
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

IUSE_VIDEO_CARDS="video_cards_nvidia"
IUSE="${IUSE_VIDEO_CARDS} blas cuda cudnn dnnl ispc onnx openblas opencl +test +networks"

BDEPEND="
	dev-build/meson
	dev-build/ninja
	dev-lang/python
	dev-libs/protobuf
	sys-devel/gcc:13
	"

RDEPEND="dev-cpp/eigen:=
	dev-cpp/gtest
	blas? ( sci-libs/openblas )
	cuda? ( dev-util/nvidia-cuda-toolkit )
	dnnl? ( sci-ml/oneDNN )
	onnx? ( sci-libs/onnxruntime )
	cudnn? ( dev-libs/cudnn )
	ispc? ( dev-lang/ispc )
	opencl? ( virtual/opencl )
	networks? ( !games-board/lc0-networks )
	"

REQUIRED_USE="cudnn? ( cuda )"

DEPEND="${RDEPEND}"

RESTRICT="!test? ( test ) mirror"

src_prepare() {
	default

	mkdir -p subprojects/packagecache || die
	ln -sf "${DISTDIR}/abseil-cpp-20240722.0.tar.gz" \
		subprojects/packagecache/abseil-cpp-20240722.0.tar.gz || die
}

src_configure() {
	local vc="${VIDEO_CARDS:-}"
	local detected_nvidia=false
	case "${vc}" in
		*nvidia*|*nvidia-*) detected_nvidia=true ;;
	esac

	local allow_cuda=false
	if use cuda; then
		allow_cuda="${detected_nvidia}"
	fi

	local allow_cudnn=false
	if use cudnn; then
		if [[ "${allow_cuda}" != "true" ]]; then
			die "USE=cudnn requires USE=cuda and VIDEO_CARDS having nvidia"
		fi
		allow_cudnn=true
	fi

	local emesonargs=(
		-Dplain_cuda=$(usex cuda true false)
		-Dcudnn="${allow_cudnn}"
		-Dopencl=$(usex opencl true false)
		-Dblas=$(usex blas true false)
		-Dopenblas=$(usex blas true false)
		-Dispc=$(usex ispc true false)
		$(meson_use dnnl dnnl)
	)

	if use onnx; then
		emesonargs+=(
			'-Donnx_libdir=/usr/lib64'
			'-Donnx_include=/usr/include/onnxruntime'
		)
	fi

	meson_src_configure "${emesonargs[@]}"
}

src_install() {
	mkdir -p "${D}/usr/bin"
	cp "${S}-build/lc0" "${D}/usr/bin" || die

	if use networks; then
		insinto /usr/share/lc0/networks
		doins "${DISTDIR}/network-${NETWORK_FILE}"
		dosym "network-${NETWORK_FILE}" /usr/share/lc0/networks/network.pb.gz
	fi

	default
}

pkg_postinst() {
	if use networks; then
		einfo "Lc0 neural network installed to /usr/share/lc0/networks/network.pb.gz"
		einfo "Point your GUI (Scid, Scid vs. PC, Arena) to this file when configuring lc0."
	fi
}
