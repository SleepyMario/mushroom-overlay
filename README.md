mushroom-overlay

Personal Gentoo overlay maintained by SleepyMario.

This repository contains ebuilds, package metadata, OpenPGP keys, and local patches for software not available in the main Gentoo repository or where a newer/custom package is needed.

Packages
Category	Package	Notes
app-crypt	openpgp-keys-sleepymario	OpenPGP key package for repository verification
app-misc	copilot-desktop-snap	Copilot Desktop Snap package
games-board	lc0	Leela Chess Zero
games-board	lc0-networks	Neural-network weights for LC0
games-util	chatgamefontificator-bin	Chat Game Fontificator binary package
games-util	chatty-bin	Chatty Twitch chat client binary package
media-fonts	mathilde	Mathilde font
www-apps	hugo	Hugo static-site generator
Adding the overlay

Create /etc/portage/repos.conf/mushroom-overlay.conf:

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

Replace YOUR_USERNAME with your local username.

Sync the overlay:

sudo emaint sync -r mushroom
License

Individual ebuilds and included files may use their own licenses. See the relevant package directories and the licenses/ directory.
