# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A meta ebuild for ibus."
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="amd64"
IUSE="+anthy cangjie chewing fbterm handwrite +hangul kkc +libpinyin m17n pinyin rime skk sunpinyin table table-chinese table-extraphrase table-latin +typing-booster unikey"

DEPEND="${CDEPEND}"
RDEPEND="${DEPEND}
		app-i18n/ibus
		anthy? ( app-i18n/ibus-anthy ) 
		cangjie? ( app-i18n/ibus-cangjie )
		chewing? ( app-i18n/ibus-chewing )
		fbterm? ( app-i18n/ibus-fbterm )
		handwrite? ( app-i18n/ibus-handwrite )
		hangul? ( app-i18n/ibus-hangul )
		kkc? ( app-i18n/ibus-kkc )
		libpinyin? ( app-i18n/ibus-libpinyin )
		m17n? ( app-i18n/ibus-m17n )
		pinyin? ( app-i18n/ibus-pinyin )
		rime? ( app-i18n/ibus-rime )
		skk? ( app-i18n/ibus-skk )
		sunpinyin? ( app-i18n/ibus-sunpinyin )
		table? ( app-i18n/ibus-table )
		table-chinese? ( app-i18n/ibus-table-chinese )
		table-extraphrase? ( app-i18n/ibus-table-extraphrase )
		table-latin? ( app-i18n/ibus-table-latin )
		typing-booster? ( app-i18n/ibus-typing-booster )
		unikey? ( app-i18n/ibus-unikey )
		"

