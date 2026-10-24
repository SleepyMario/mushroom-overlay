# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

MY_COMMIT="b06740a8604e9965daacf0ee5f677d06f6395f5c"
DESCRIPTION="Terminal learning application with selectable public language menu skeletons"
HOMEPAGE="https://github.com/SleepyMario/WhackSmacker"
SRC_URI="https://github.com/SleepyMario/WhackSmacker/archive/${MY_COMMIT}.tar.gz -> ${P}.tar.gz
	https://github.com/SleepyMario/mushroom-overlay/releases/download/distfiles-whacksmacker-0.1.0-alpha.4/${P}-node-deps.tar.gz"
S="${WORKDIR}/WhackSmacker-${MY_COMMIT}"
LICENSE="GPL-3+ BSD-2 MIT ISC"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+geo +l10n_en l10n_zh-TW test"
STUDY_LANGUAGES="ar de en es fr grc hi ja ko la lzh nl ru th vi zh_CN zh_TW zu"
for lang in ${STUDY_LANGUAGES}; do
	IUSE+=" wsm_study_${lang}"
done
REQUIRED_USE="l10n_en"
RESTRICT="!test? ( test )"
BDEPEND=">=net-libs/nodejs-22"
RDEPEND=">=net-libs/nodejs-22"

src_prepare() {
	default
	cp "${FILESDIR}"/{configure-gentoo.mjs,build-public.mjs,test-gentoo.cjs} . || die
	local selected="" lang
	for lang in ${STUDY_LANGUAGES}; do
		use "wsm_study_${lang}" && selected+="${lang} "
	done
	WSM_SELECTED_GEO="$(usex geo yes no)" WSM_SELECTED_STUDY="${selected}" WSM_SELECTED_ZH="$(usex l10n_zh-TW yes no)" \
		node configure-gentoo.mjs || die
	ln -s "${WORKDIR}/node_modules" node_modules || die
}

src_compile() {
	node node_modules/typescript/bin/tsc || die
	node build-public.mjs || die
}

src_test() {
	node test-gentoo.cjs || die
	node dist/main.js --help >/dev/null || die
}

src_install() {
	insinto /usr/share/${PN}
	doins -r dist migrations package.json package-lock.json COPYING
	# Copy only production dependencies; never install build/test tools.
	local dep
	while IFS= read -r dep; do
		[[ -d node_modules/${dep} ]] || die "Missing runtime dependency ${dep}"
		insinto "/usr/share/${PN}/node_modules/$(dirname "${dep}")"
		doins -r "node_modules/${dep}"
	done < <(node -e '
		const lock = require("./package-lock.json");
		for (const [path, entry] of Object.entries(lock.packages)) {
			if (path.startsWith("node_modules/") && !entry.dev && !entry.optional)
				console.log(path.slice(13));
		}
	')
	dosym ../share/${PN}/dist/main.js /usr/bin/whacksmacker
	dosym whacksmacker /usr/bin/wsm
	fperms 0755 /usr/share/${PN}/dist/main.js
	dodoc README.md
}
