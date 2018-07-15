# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A meta ebuild for vim related atoms."
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND="${CDEPEND}"
RDEPEND="${DEPEND}
		app-editors/vim
		app-vim/emmet
		app-vim/nerdtree
		app-vim/pathogen
		app-vim/snipmate
		app-vim/surround
		app-vim/tagbar
		app-vim/vim-spell-de
		app-vim/vim-spell-en
		app-vim/vim-spell-es
		app-vim/vim-spell-fr
		app-vim/vim-spell-nl
		app-vim/voom
		app-vim/wikipedia-syntax
		app-vim/youcompleteme
		"
