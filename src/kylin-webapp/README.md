# Kylin Webapp

An independently installed desktop client for an existing Kylin service.
The service supplies the current shared web interface, model access,
conversations and cumulative notes. This package contains none of those data.

On first launch, enter the **Kylin gateway** address, not a raw model API.
The address, optional bearer access token, browser executable and request timeout
are runtime settings. Nothing needs recompiling when the service moves.
Model weights, context size and other model administration stay on the service.

## Installation and configuration

Gentoo: accept the live version with `=app-misc/kylin-webapp-9999 **` in
`/etc/portage/package.accept_keywords`, then run
`emerge --ask app-misc/kylin-webapp` (live version `9999`).
The `gui` USE flag enables the first-run connection dialog and desktop entry.
A Chromium-family browser (Chromium, Brave, Chrome or Edge) supplies the app
window. Use an existing installed browser or install one separately. No second
browser engine is bundled. With `--browser`, the default browser opens instead.

Other desktop systems can install this Python package with `pip install .`;
install PyQt6 as well for graphical setup. The same Python core supports Linux,
Windows and macOS, but only Linux has been tested. This Python launcher is not
an Android/iOS app; mobile devices use the service's responsive web interface.

Run `kylin-webapp`, or launch **Kylin** from the desktop menu. Use the desktop
entry's **Connection settings** action or `kylin-webapp --configure` to change
the connection. Existing windows keep their original settings until closed.

Linux configuration: `$XDG_CONFIG_HOME/kylin-webapp/config.json`, normally
`~/.config/kylin-webapp/config.json`. Windows uses `%APPDATA%/kylin-webapp`,
macOS uses `~/Library/Application Support/kylin-webapp`.
The file is created with owner-only permissions on Unix. Do not commit it.

```json
{
  "service_url": "https://your-kylin-server.example",
  "access_token": "",
  "browser": "",
  "timeout": 600
}
```

Tokens go only to the configured service and never to the browser or command
line. Remote bearer authentication requires HTTPS, using normal certificate
verification. The token option supplies an existing server's authentication;
it does not add authentication or network access to that server. Connections
must use a dedicated root URL; subpath hosting and WebSockets are not supported.
The current Kylin interface uses HTTP and streamed HTTP responses.

`kylin-webapp --check` checks the service without changing conversations.
`--no-open` runs just the loopback client; useful for testing. `--config PATH`
selects another configuration. Quit the app window to stop the local client;
the central service keeps running. For `--browser`/`--no-open`, Ctrl+C stops it.

## Shared state and migration

The client forwards the same interface and API used by the browser, including
streamed replies, shared-note editing, archive export and browser-cache sync.
The central archive remains authoritative; browser profiles contain only the
interface's local caches and drafts. Wait for the memory badge to show synced
before moving a server or changing the connection.

Each service-address/token combination gets a separate browser profile and
stable loopback origin. An address or token change starts with a new cache and
retrieves that service's archive; it cannot silently upload the old profile.
Old caches and unsent drafts are retained under `profiles/` in the configuration
directory. To recover an unsent draft, reopen the old connection while that
service is available. Do not delete profiles while they contain unsent work.

New replies require the central service. This is a standalone installed client,
not an offline model or separate conversation archive. Moving the central
service, enabling private remote access, and configuring server authentication
are separate operations. Interface updates are supplied by the central service;
the live Gentoo package updates the launcher.

## Development

Source lives in `src/kylin-webapp` within Mushroom so the live ebuild can fetch
it directly without publishing a private Kylin project. It is MIT licensed.
No model, user configuration, browser profile, conversation or local host path
belongs in this source directory.

```sh
PYTHONPATH=src python3 -m unittest discover -s tests -v
```
