# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A command-line Pomodoro tracker which uses the Open Pomodoro Format"
HOMEPAGE="https://github.com/open-pomodoro/openpomodoro-cli"
SRC_URI="https://github.com/open-pomodoro/openpomodoro-cli-bin/releases/download/v${PV}/openpomodoro-cli_${PV}_linux_amd64.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

S=${WORKDIR}

src_install () {
    addwrite /usr/bin # ugly workaround, fix someday
    cp ${S}/pomodoro /usr/bin/ || die
    chmod +x /usr/bin/pomodoro
    }


