# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake cuda

CUDA_VERBOSE=false

DESCRIPTION="GPU-accelerated live multilingual subtitles for OBS"
HOMEPAGE="https://github.com/ggml-org/whisper.cpp"

MODEL_REV="5359861c739e955e79d9a303bcbc70fb988958b1"
SRC_URI="
	https://github.com/ggml-org/whisper.cpp/archive/refs/tags/b${PV}.tar.gz
		-> whisper.cpp-b${PV}.tar.gz
	https://huggingface.co/ggerganov/whisper.cpp/resolve/${MODEL_REV}/ggml-small.bin
		-> ggml-small-${MODEL_REV}.bin
"
S="${WORKDIR}/whisper.cpp-b${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+cuda"

RDEPEND="
	media-libs/libsdl2
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}/${P}-no-talk-llama.patch"
)

src_prepare() {
	cmake_src_prepare

	if use cuda; then
		cuda_src_prepare
	fi
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=OFF
		-DGGML_CUDA=$(usex cuda)
		-DGGML_NATIVE=OFF
		-DCMAKE_CUDA_ARCHITECTURES=89
		-DWHISPER_BUILD_EXAMPLES=ON
		-DWHISPER_BUILD_SERVER=OFF
		-DWHISPER_BUILD_TESTS=OFF
		-DWHISPER_SDL2=ON
	)

	if use cuda; then
		cuda_add_sandbox -w
		addpredict /dev/char/
		cuda_sanitize
		mycmakeargs+=( -DCMAKE_CUDA_FLAGS="${NVCCFLAGS}" )
	fi

	cmake_src_configure
}

src_compile() {
	if use cuda; then
		addpredict /dev/char/
		cuda_add_sandbox
	fi

	cmake_build whisper-stream
}

src_install() {
	exeinto /usr/libexec/language-subtitles
	doexe "${BUILD_DIR}/bin/whisper-stream"

	dobin "${FILESDIR}/language-subtitles"

	insinto /usr/share/language-subtitles
	newins "${DISTDIR}/ggml-small-${MODEL_REV}.bin" ggml-small.bin

	dodoc README.md
}
