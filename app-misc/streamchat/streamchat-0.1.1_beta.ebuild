# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="Kick and Twitch interactive live-chat client and relay server"
HOMEPAGE="https://github.com/SleepyMario/streamchat"

MY_COMMIT="c6a84c61f7c4d8bf69019ad0a154f3d5ab31d591"
MY_VERSION="${PV/_beta/-beta}"

EGO_SUM=(
	"github.com/clipperhouse/uax29/v2 v2.2.0"
	"github.com/clipperhouse/uax29/v2 v2.2.0/go.mod"
	"github.com/dustin/go-humanize v1.0.1"
	"github.com/dustin/go-humanize v1.0.1/go.mod"
	"github.com/google/pprof v0.0.0-20250317173921-a4b03ec1a45e"
	"github.com/google/pprof v0.0.0-20250317173921-a4b03ec1a45e/go.mod"
	"github.com/google/uuid v1.6.0"
	"github.com/google/uuid v1.6.0/go.mod"
	"github.com/gorilla/websocket v1.5.3"
	"github.com/gorilla/websocket v1.5.3/go.mod"
	"github.com/hashicorp/golang-lru/v2 v2.0.7"
	"github.com/hashicorp/golang-lru/v2 v2.0.7/go.mod"
	"github.com/mattn/go-isatty v0.0.20"
	"github.com/mattn/go-isatty v0.0.20/go.mod"
	"github.com/mattn/go-runewidth v0.0.19"
	"github.com/mattn/go-runewidth v0.0.19/go.mod"
	"github.com/ncruces/go-strftime v1.0.0"
	"github.com/ncruces/go-strftime v1.0.0/go.mod"
	"github.com/remyoudompheng/bigfft v0.0.0-20230129092748-24d4a6f8daec"
	"github.com/remyoudompheng/bigfft v0.0.0-20230129092748-24d4a6f8daec/go.mod"
	"golang.org/x/exp v0.0.0-20251023183803-a4bb9ffd2546"
	"golang.org/x/exp v0.0.0-20251023183803-a4bb9ffd2546/go.mod"
	"golang.org/x/mod v0.29.0"
	"golang.org/x/mod v0.29.0/go.mod"
	"golang.org/x/sync v0.17.0"
	"golang.org/x/sync v0.17.0/go.mod"
	"golang.org/x/sys v0.6.0/go.mod"
	"golang.org/x/sys v0.37.0"
	"golang.org/x/sys v0.37.0/go.mod"
	"golang.org/x/term v0.34.0"
	"golang.org/x/term v0.34.0/go.mod"
	"golang.org/x/tools v0.38.0"
	"golang.org/x/tools v0.38.0/go.mod"
	"modernc.org/cc/v4 v4.27.1"
	"modernc.org/cc/v4 v4.27.1/go.mod"
	"modernc.org/ccgo/v4 v4.30.1"
	"modernc.org/ccgo/v4 v4.30.1/go.mod"
	"modernc.org/fileutil v1.3.40"
	"modernc.org/fileutil v1.3.40/go.mod"
	"modernc.org/gc/v2 v2.6.5"
	"modernc.org/gc/v2 v2.6.5/go.mod"
	"modernc.org/gc/v3 v3.1.1"
	"modernc.org/gc/v3 v3.1.1/go.mod"
	"modernc.org/goabi0 v0.2.0"
	"modernc.org/goabi0 v0.2.0/go.mod"
	"modernc.org/libc v1.67.6"
	"modernc.org/libc v1.67.6/go.mod"
	"modernc.org/mathutil v1.7.1"
	"modernc.org/mathutil v1.7.1/go.mod"
	"modernc.org/memory v1.11.0"
	"modernc.org/memory v1.11.0/go.mod"
	"modernc.org/opt v0.1.4"
	"modernc.org/opt v0.1.4/go.mod"
	"modernc.org/sortutil v1.2.1"
	"modernc.org/sortutil v1.2.1/go.mod"
	"modernc.org/sqlite v1.44.3"
	"modernc.org/sqlite v1.44.3/go.mod"
	"modernc.org/strutil v1.2.1"
	"modernc.org/strutil v1.2.1/go.mod"
	"modernc.org/token v1.1.0"
	"modernc.org/token v1.1.0/go.mod"
)
go-module_set_globals

SRC_URI="
	https://github.com/SleepyMario/streamchat/archive/${MY_COMMIT}.tar.gz -> ${P}.tar.gz
	${EGO_SUM_SRC_URI}
"
S="${WORKDIR}/streamchat-${MY_COMMIT}"

LICENSE="MIT Apache-2.0 BSD BSD-2 ISC"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cli server"
REQUIRED_USE="^^ ( cli server )"

BDEPEND=">=dev-lang/go-1.24.0"

DOCS=(
	README.md
	LICENSE
	CONTRIBUTING.md
)

src_compile() {
	GOPROXY=off ego build -trimpath -buildvcs=false \
		-ldflags "-X main.version=${MY_VERSION}" \
		-o streamchat ./cmd/streamchat
}

src_test() {
	# Several emote backend tests create Unix sockets whose paths exceed the
	# platform limit when rooted under Portage's deeply nested ${T}.
	TMPDIR=/tmp GOPROXY=off ego test ./...
}

src_install() {
	dobin streamchat
	einstalldocs
	docinto examples
	dodoc examples/config.example.json

	if use server; then
		systemd_dounit systemd/streamchat-server.service
	fi
}

pkg_postinst() {
	if use server; then
		elog "streamchat-server.service expects the streamchat user and group."
		elog "It reads /etc/streamchat/config.json and preserves archive data under /var/lib/streamchat."
		elog "Disable the legacy streamchat.service before enabling streamchat-server.service."
	fi
}
