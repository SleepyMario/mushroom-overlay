# mushroom-overlay

`mushroom-overlay` is a personal Gentoo overlay containing ebuilds and related
metadata for packages that are unavailable in the main Gentoo repository, need
a newer version, or need local packaging changes.

## Packages

- `app-benchmarks/vkmark` - extensible Vulkan benchmark suite
- `app-crypt/openpgp-keys-sleepymario` - repository OpenPGP key
- `app-misc/streamchat` - merged YouTube and Kick live-chat CLI
- `app-misc/weightrail` - local-first weight tracker
- `app-misc/whacksmacker` - terminal review sessions for Anki through AnkiConnect
- `dev-python/plotext` - terminal plotting library used by Weightrail
- `dev-utils/pygpt-bin` - desktop AI assistant binary package
- `games-board/lc0` - Leela Chess Zero with optional neural-network weights
- `games-util/chatgamefontificator-bin` - Chat Game Fontificator
- `games-util/chatty-bin` - Chatty Twitch chat client
- `media-fonts/mathilde` - Mathilde font
- `net-im/ferdium-bin` - Ferdium desktop messaging client binary package
- `x11-misc/lightdm-settings` - LightDM configuration tool
- `x11-misc/lightdm-slick-greeter` - LightDM greeter

Hugo is provided by the Gentoo main repository and is no longer maintained in
this overlay.

## Installation

Add the overlay with `eselect-repository`:

```sh
sudo eselect repository add mushroom-overlay git https://github.com/SleepyMario/mushroom-overlay.git
```

Sync it with Portage:

```sh
sudo emaint sync -r mushroom-overlay
```

Some packages use testing keywords such as `~amd64` and may require an entry in
`/etc/portage/package.accept_keywords` before they can be installed.

Alternatively, create `/etc/portage/repos.conf/mushroom-overlay.conf` manually:

```ini
[mushroom-overlay]
location = /var/db/repos/mushroom-overlay
masters = gentoo
sync-type = git
sync-uri = https://github.com/SleepyMario/mushroom-overlay.git
sync-branch = main
sync-depth = 1
sync-openpgp-key-path = /usr/share/openpgp-keys/sleepymario.asc
sync-git-verify-commit-signature = true
priority = 999
auto-sync = no
```
