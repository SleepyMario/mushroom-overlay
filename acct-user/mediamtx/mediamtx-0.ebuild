# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="User for MediaMTX"
ACCT_USER_ID=-1
ACCT_USER_GROUPS=( mediamtx )
ACCT_USER_HOME=/var/lib/mediamtx
ACCT_USER_HOME_OWNER=mediamtx:mediamtx
ACCT_USER_SHELL=/sbin/nologin

acct-user_add_deps
