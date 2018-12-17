# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A meta ebuild for i3wm."
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="amd64"
IUSE="+arandr bluetooth +cava +calcurse +catfish +cmatrix +cmus +compton +feh +glances +gnome-calculator +guake +hardinfo +htop i3 i3blocks +i3-gaps +i3lock +lxappearance +mps-youtube +newsboat +nm-applet +pass +p7zip +polybar pulseaudio +qutebrowser +ranger +rofi +seahorse +termite +utimer +weechat +xfce4-terminal +youtube"

DEPEND="${CDEPEND}"
RDEPEND="${DEPEND}
		arandr? ( x11-misc/arandr )
		bluetooth? ( net-wireless/blueberry 
				     net-wireless/bluez )
		calcurse? ( app-office/calcurse )
		catfish? ( dev-util/catfish )
		cava? ( media-sound/cava )
		cmatrix? ( app-misc/cmatrix )
		cmus? ( media-sound/cmus )
		compton? ( x11-misc/compton )
		feh? ( media-gfx/feh )
		gnome-calculator? ( gnome-extra/gnome-calculator )
		glances? ( sys-process/glances )
		guake? ( x11-terms/guake )
		hardinfo? ( app-admin/hardinfo )
		htop? ( sys-process/htop )
		lxappearance? ( lxde-base/lxappearance )
		mps-youtube? ( media-sound/mps-youtube )
		nm-applet? ( gnome-extra/nm-applet )
		pass? ( app-admin/pass )
		p7zip? ( app-arch/p7zip )
		polybar? ( x11-misc/polybar )
		pulseaudio? ( media-sound/alsa-utils
					  media-sound/pavucontrol 
					  media-sound/playerctl )
		qutebrowser? ( www-client/qutebrowser )
		newsboat? ( net-news/newsboat )
		ranger? ( app-misc/ranger )
		rofi? ( x11-misc/rofi )
		seahorse? ( app-crypt/seahorse )
		i3? ( x11-wm/i3 
			  !x11-wm/i3-gaps )
		i3-gaps? ( x11-wm/i3-gaps 
				   !x11-wm/i3 )
		i3lock? ( media-gfx/scrot
				  x11-misc/i3lock )
		termite? ( x11-terms/termite )
		weechat? ( net-irc/weechat )
		utimer? ( app-misc/utimer )
		xfce4-terminal? ( x11-terms/xfce4-terminal )
		youtube? ( net-misc/youtube-dl 
				  net-misc/youtube-viewer )
		"
