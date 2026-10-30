# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# dev/cpp/gest AND lc0 BOTH NEED TO BE BUILT WITH GCC13 FOR NOW.

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )

inherit meson python-any-r1

DESCRIPTION="Neural-network chess engine"
HOMEPAGE="https://github.com/LeelaChessZero/lc0/"

# Update with scripts/update-lc0-network.sh.
NETWORK_URI="https://storage.lczero.org/files/networks-contrib/BT4-1024x15x32h-swa-6147500-policytune-332.pb.gz"
NETWORK_FILE="${NETWORK_URI##*/}"
# T70 703810: convolutional network supported by the OpenCL backend.
LEGACY_URI="https://data.lczero.org/files/networks/b30e742bcfd905815e0e7dbd4e1bafb41ade748f85d006b8e28758f1a3107ae3"
LEGACY_FILE="network-t70-703810.pb.gz"
SRC_URI="
	https://github.com/LeelaChessZero/lc0/archive/refs/tags/v${PV/_/-}.tar.gz -> ${P}.tar.gz
	https://github.com/abseil/abseil-cpp/releases/download/20240722.0/abseil-cpp-20240722.0.tar.gz
	networks? (
		${NETWORK_URI} -> network-${NETWORK_FILE}
		opencl? ( ${LEGACY_URI} -> ${LEGACY_FILE} )
	)
"

S="${WORKDIR}/${PN}-${PV/_/-}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

IUSE="+blas cuda cudnn dnnl ispc +openblas opencl +test +networks"

BDEPEND="
	dev-build/meson
	dev-build/ninja
	${PYTHON_DEPS}
	dev-libs/protobuf
	sys-devel/gcc:13
	"

RDEPEND="dev-cpp/eigen:=
	virtual/zlib
	openblas? ( sci-libs/openblas )
	cuda? ( dev-util/nvidia-cuda-toolkit )
	dnnl? ( sci-ml/oneDNN )
	cudnn? ( dev-libs/cudnn )
	ispc? ( dev-lang/ispc )
	opencl? ( virtual/opencl )
	networks? ( !games-board/lc0-networks )
	"

REQUIRED_USE="
	|| ( blas cuda opencl )
	cudnn? ( cuda )
	openblas? ( blas )
	dnnl? ( blas )
	ispc? ( blas )
"

DEPEND="${RDEPEND}
	opencl? ( dev-util/opencl-headers )
	test? ( dev-cpp/gtest )
"

RESTRICT="!test? ( test ) mirror"

src_prepare() {
	default

	mkdir -p subprojects/packagecache || die
	ln -sf "${DISTDIR}/abseil-cpp-20240722.0.tar.gz" \
		subprojects/packagecache/abseil-cpp-20240722.0.tar.gz || die
}

src_configure() {
	export CC="x86_64-pc-linux-gnu-gcc-13"
	export CXX="x86_64-pc-linux-gnu-g++-13"

	local emesonargs=(
		-Dplain_cuda=$(usex cuda true false)
		-Dcudnn=$(usex cudnn true false)
		-Dopencl=$(usex opencl true false)
		-Dblas=$(usex blas true false)
		-Dopenblas=$(usex openblas true false)
		-Dispc=$(usex ispc true false)
		-Dgtest=$(usex test true false)
		-Dopencl_libdirs="${EPREFIX}/usr/$(get_libdir)"
		-Dopencl_include="${EPREFIX}/usr/include"
		-Dmkl=false
		-Dnative_cuda=false
		-Dnvcc=$(usex cuda true false)
		-Dnvcc_ccbin="${CXX}"
		$(meson_use dnnl dnnl)
	)

	meson_src_configure

	# Upstream silently drops GPU backends when dependencies are not detected.
	if use opencl; then
		grep -q 'neural_backends_opencl_network_opencl.cc' "${BUILD_DIR}/build.ninja" ||
			die "Requested OpenCL backend was not configured"
	fi
	if use cuda; then
		grep -q 'neural_backends_cuda_network_cuda.cc' "${BUILD_DIR}/build.ninja" ||
			die "Requested CUDA backend was not configured"
	fi
	if use cudnn; then
		grep -q 'neural_backends_cuda_network_cudnn.cc' "${BUILD_DIR}/build.ninja" ||
			die "Requested cuDNN backend was not configured"
	fi
}

src_install() {
	dobin "${BUILD_DIR}/lc0"

	if use networks; then
		insinto /usr/share/lc0/networks
		doins "${DISTDIR}/network-${NETWORK_FILE}"
		local default_network="network-${NETWORK_FILE}"
		dosym "${default_network}" /usr/share/lc0/networks/network-bt4.pb.gz
		if use opencl; then
			doins "${DISTDIR}/${LEGACY_FILE}"
			dosym "${LEGACY_FILE}" /usr/share/lc0/networks/network-opencl.pb.gz
			use cuda || default_network="${LEGACY_FILE}"
		fi
		dosym "${default_network}" /usr/share/lc0/networks/network.pb.gz
	fi

	einstalldocs
}

pkg_postinst() {
	if use opencl; then
		einfo "OpenCL needs a GPU runtime, not only the ICD loader."
		einfo "AMD: enable Mesa USE='opencl llvm' and VIDEO_CARDS='radeonsi'."
		einfo "For Mesa Rusticl, select the device with RUSTICL_ENABLE=radeonsi."
		einfo "NVIDIA: install the matching NVIDIA driver."
		if use networks; then
			einfo "For --backend=opencl use /usr/share/lc0/networks/network-opencl.pb.gz."
			einfo "BT4 transformer weights are not compatible with OpenCL."
		fi
	fi
	if use networks; then
		einfo "Lc0 neural network installed to /usr/share/lc0/networks/network.pb.gz"
		einfo "Point your GUI (Scid, Scid vs. PC, Arena) to this file when configuring lc0."
	fi
}
