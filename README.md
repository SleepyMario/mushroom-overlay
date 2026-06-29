# mushroom-overlay

Personal Gentoo overlay.

It contains ebuilds and related files for packages I use that are unavailable in the main Gentoo repository, need a newer version, or need local packaging changes.

## Packages

- `app-crypt/openpgp-keys-sleepymario` ¡X repository OpenPGP key
- `games-board/lc0` - Leela Chess Zero with optional neural-network weights
- `games-util/chatgamefontificator-bin` ¡X Chat Game Fontificator
- `games-util/chatty-bin` ¡X Chatty Twitch chat client
- `media-fonts/mathilde` ¡X Mathilde font
- `www-apps/hugo` ¡X Hugo static-site generator

## Installation

Create `/etc/portage/repos.conf/mushroom-overlay.conf`:

```ini
[mushroom]
location = /home/YOUR_USERNAME/Projects/Gentoo/mushroom-overlay
sync-type = git
sync-uri = git@github.com:SleepyMario/mushroom-overlay.git
sync-branch = main
sync-depth = 1
sync-openpgp-key-path = /usr/share/openpgp-keys/sleepymario.asc
sync-git-verify-commit-signature = true
priority = 999
auto-sync = yes
