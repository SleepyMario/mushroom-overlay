# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="User for the Streamchat relay service"
KEYWORDS="~amd64"

ACCT_USER_ID=-1
ACCT_USER_GROUPS=( streamchat )
ACCT_USER_HOME=/var/lib/streamchat
ACCT_USER_HOME_OWNER=streamchat:streamchat
ACCT_USER_HOME_PERMS=0750

acct-user_add_deps
