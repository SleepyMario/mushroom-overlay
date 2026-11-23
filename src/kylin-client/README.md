# Qylyn (麒麟) Client

Official website: https://www.qylyn.com. Kylin is the former name of the same project. Use `qylyn-client` and `qylyn-client-tunnel`; the old commands remain compatible. Existing configuration, credentials, cache, theme IDs and desktop application ID are retained so this update does not reset settings or create a second profile. The Python distribution/module and source directory retain compatibility names.

# Client reference

An independently configured GTK desktop client for a central Kylin service.
WebKitGTK renders the shared interface inside the application's own window.
No external browser is launched for the Kylin interface. The server owns the
model, cumulative conversations, notes and interface; this package contains none
of that private data.

## Gentoo

Accept the live version with `=app-dev/kylin-client-9999 **` in
`/etc/portage/package.accept_keywords`, then install `app-dev/kylin-client`.
The default `gui` USE flag enables GTK 3, WebKitGTK 4.1 and PyGObject, the
application window, connection dialog and desktop entry. There is no dependency
on Brave, Chromium, Qt or QtWebEngine. With `-gui`, only headless proxy/check modes
are available. Source lives in `src/kylin-client` in Mushroom itself.

Run `kylin-client` or choose **Kylin** in the application menu. The first launch
asks for the central Kylin gateway address. Use the window's settings button,
the launcher's **Connection settings** action, or `kylin-client --configure`
to change it later. Changes apply when the client is reopened. Closing the
window stops this client, while the central service continues running.

## Zoom and readability

The title bar has large **−**, **percentage**, and **+** buttons. Press **+** to
make the entire interface larger, **−** to make it smaller, or the percentage
button to reset to 100%. Supported zoom ranges from 50% to 400%.

Keyboard shortcuts: **Ctrl++** or **Ctrl+=** to zoom in, **Ctrl+−** to zoom out,
and **Ctrl+0** to reset. Numeric-keypad +/−/0 work too. All Kylin windows in the
same client follow the selected zoom, including newly opened windows.
The setting is saved automatically in `ui.json` next to `config.json`, so it
survives application restarts and connection-setting edits.

## Runtime configuration

Linux: `$XDG_CONFIG_HOME/kylin-client/config.json`, normally
`~/.config/kylin-client/config.json`. Created with owner-only Unix permissions.

```json
{
  "service_url": "https://your-kylin-server.example",
  "access_token": "",
  "timeout": 600
}
```

`--config PATH` selects another configuration. `--check` checks the service
without modifying conversations. `--no-open` runs the client proxy without
a graphical window; Ctrl+C stops it. Model weights/context are server settings.

The optional bearer token stays in the client configuration and is forwarded
only to the configured service, never embedded in the interface. Remote bearer
authentication requires HTTPS with normal certificate verification. This supplies
an existing server's authentication; it does not enable server authentication,
remote access, or model hosting. Dedicated root URLs are supported; subpath
hosting and WebSockets are not. The current Kylin interface uses HTTP/SSE.

Each address/token combination gets a separate, stable loopback origin and
persistent WebKit profile. Changing either retrieves that service's shared
archive into a fresh cache, without uploading the previous connection's cache.
Old profiles and unsent drafts are retained; wait for the memory indicator to
show synced before switching. Downloads use a save dialog; same-service popup
links open in another Kylin window, and user-clicked external links use the
system's default application.

The desktop shell currently targets Linux/GTK. The web interface stays platform
independent and usable by future desktop/mobile clients. This package is not
a native Windows, macOS, Android or iOS wrapper. The central service remains
necessary for new replies and shared history.

## Development

```sh
PYTHONPATH=src python3 -m unittest discover -s tests -v
```

MIT licensed. No model, user configuration, browser profile, conversation or
local host path belongs in this source directory.

## Shared interface navigation

The window provides Chat, Conversations, Files / web, and Write reviews shortcuts,
plus Back, Forward and Reload. These load the current server pages in the same
WebKit profile. Model modes, shared notes, coordinated discussions and access
results therefore use the exact same service as a browser. Existing zoom,
downloads, file chooser, popup and connection behavior are retained. Feature
availability depends on the configured Core version; this does not add native
mobile support or browser-specific extensions.

## Colour schemes

The title-bar **Colour scheme** picker changes the interface immediately without
reloading the page or clearing a draft. KylinChat's green palette is the default.
ChatGPT-style Light/Dark, the installed desktop app's named palette families
(including both Solarized variants), and additional Midnight Blue, Warm Paper,
Lavender, Forest and High Contrast schemes are included. The selected theme and
zoom are stored together in the local `ui.json`; one setting never erases the other.
New windows use the same selection. No service, conversation, model or website
configuration changes when choosing a theme.

The named app palettes reuse their background, text and accent colour values;
Kylin's panels, controls and native header map those colours onto its own layout.
This is a palette match, not a copy of the other application's code, artwork or
window effects. Some original palettes have softer contrast; High Contrast is
available for stronger legibility. Theme changes affect Kylin's main interface
and standalone utility pages, not external websites opened in a browser.

### Reading a token from pass

Install `pass` and set `access_token_pass_entry` to an existing entry, such as
`kylin/api-token`, with `access_token` empty. The client runs `pass show` directly
at startup, uses only the first line, and keeps the resolved token in memory.
Unlock failures stop startup; credentials are never silently omitted. Sending
a token over non-loopback HTTP is refused. The connection dialog supports the
entry name; it never displays the resolved secret.

When migrating an existing connection, retain its current 64-character profile
directory name in `profile_id`. This keeps its local origin, browser records,
and settings unchanged. Do not reuse a profile across different servers.
Without an explicit profile, pass connections use the service URL and entry name
as their stable identity, so rotating the token does not create a new profile.

## Optional LAN-first SSH connection

`kylin-client-tunnel` keeps the same localhost service URL and profile. Configure
`tunnel.json` in the client configuration directory with `ssh_host`,
`host_key_alias`, `lan_host`, and `wireguard_host`. Optional settings are
`ssh_config` (default `~/.ssh/config`), `local_port`, and `remote_port` (8095).
Use your existing trusted SSH identity and known-hosts configuration. Endpoint
addresses and credentials are local settings and are not distributed.

Each connection attempt authenticates LAN first, then WireGuard, with strict
host-key verification for the same server identity. An established connection
is retained until it disconnects; reconnecting starts at LAN again. Requests
are never replayed. `--check` checks route selection without opening a tunnel.
Run the helper under a user service with Restart=always for persistent use.
This helper uses an existing WireGuard route; it does not configure the VPN.
