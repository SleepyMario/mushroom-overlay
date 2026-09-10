# Speedify binary client for Gentoo

Repackages the official AMD64 Debian Speedify 17.1.0-12947 packages.
The default gui USE flag selects the GTK4/WebKitGTK 6 interface.

Installation does not enable or start speedify.service or speedify-sharing.service.
The latter is unnecessary for ordinary laptop use. VPN activation changes network
routing and requires a separate runtime check, especially with another VPN active.
The upstream startup script changes reverse-path filtering; inspect it before
activation. Gentoo is not an officially supported upstream distribution.

The launcher retains WebKit sandboxing and selects GTK4 directly. The bundled
Debian updater is replaced with a notice directing updates through Portage.
Upstream desktop autostart files are not installed into an autostart directory.
The upstream UI requires its shared logs directory; this is mode 1777 rather
than upstream's unrestricted recursive other-write setup.

License: proprietary all-rights-reserved. An eligible Speedify account is needed
for Linux operation. No subscription is purchased by this package.
