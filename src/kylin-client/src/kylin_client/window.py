"""GTK application window using the system WebKitGTK engine."""
import json
from bisect import bisect_left, bisect_right
import math
from pathlib import Path
from urllib.parse import urlsplit
from .themes import THEMES, load_theme, save_ui, web_css, gtk_css

ZOOM_LEVELS = (50, 67, 80, 90, 100, 110, 125, 150, 175, 200, 250, 300, 400)


def load_zoom(path):
    try:
        value = json.loads(path.read_text())['zoom_percent']
        if type(value) not in (int, float) or not math.isfinite(value):
            return 100
        return max(ZOOM_LEVELS[0], min(ZOOM_LEVELS[-1], round(value)))
    except (OSError, ValueError, KeyError, TypeError):
        return 100


def next_zoom(current, direction):
    if direction > 0:
        return ZOOM_LEVELS[min(bisect_right(ZOOM_LEVELS, current), len(ZOOM_LEVELS) - 1)]
    return ZOOM_LEVELS[max(bisect_left(ZOOM_LEVELS, current) - 1, 0)]


def local_navigation(uri, base):
    origin = urlsplit(base)
    parts = urlsplit(uri)
    if (parts.scheme, parts.netloc) == (origin.scheme, origin.netloc):
        return True
    # Archive/chat exports use a blob URL belonging to this local app origin.
    return uri.startswith('blob:' + origin.scheme + '://' + origin.netloc + '/')


def toolkit():
    try:
        import gi
        gi.require_version('Gtk', '3.0')
        gi.require_version('WebKit2', '4.1')
        from gi.repository import Gtk, WebKit2, GLib, Gio
    except (ImportError, ValueError) as exc:
        raise ValueError('The graphical client requires PyGObject, GTK 3 and WebKitGTK 4.1.') from exc
    if not Gtk.init_check()[0]:
        raise ValueError('No graphical display is available. Use --no-open for a headless client.')
    return Gtk, WebKit2, GLib, Gio


def show_error(message, parent=None):
    Gtk, _, _, _ = toolkit()
    dialog = Gtk.MessageDialog(transient_for=parent, modal=True,
                               message_type=Gtk.MessageType.ERROR,
                               buttons=Gtk.ButtonsType.CLOSE, text='Kylin connection')
    dialog.format_secondary_text(message)
    dialog.run()
    dialog.destroy()


def configure(path, parent=None):
    from .client import validate_config, write_json
    Gtk, _, _, _ = toolkit()
    old = json.loads(path.read_text()) if path.exists() else {}
    dialog = Gtk.Dialog(title='Kylin connection', transient_for=parent, modal=True)
    dialog.add_buttons('_Cancel', Gtk.ResponseType.CANCEL, '_Save', Gtk.ResponseType.OK)
    dialog.set_default_size(530, -1)
    grid = Gtk.Grid(column_spacing=16, row_spacing=12, margin=18)
    dialog.get_content_area().add(grid)
    url = Gtk.Entry(text=old.get('service_url', ''), hexpand=True)
    url.set_placeholder_text('https://your-kylin-server.example')
    token = Gtk.Entry(text=old.get('access_token', ''), visibility=False)
    timeout = Gtk.SpinButton.new_with_range(1, 3600, 1)
    timeout.set_value(old.get('timeout', 600))
    for row, (label, field) in enumerate((('Service address', url), ('Access token (optional)', token), ('Request timeout (seconds)', timeout))):
        grid.attach(Gtk.Label(label=label, xalign=0), 0, row, 1, 1)
        grid.attach(field, 1, row, 1, 1)
    grid.attach(Gtk.Label(label='Changes take effect when you next start the client.', xalign=0), 0, 3, 2, 1)
    dialog.show_all()
    try:
        while dialog.run() == Gtk.ResponseType.OK:
            try:
                config = validate_config(dict(service_url=url.get_text(), access_token=token.get_text(), timeout=timeout.get_value_as_int()))
                write_json(path, config)
                return True
            except (ValueError, OSError) as exc:
                show_error(str(exc), dialog)
        return False
    finally:
        dialog.destroy()


def run_window(url, profile, config_path, stopped):
    Gtk, WebKit2, GLib, Gio = toolkit()
    GLib.set_prgname('kylin-client')
    GLib.set_application_name('Kylin')
    app = Gtk.Application(application_id='com.sleepymario.KylinClient',
                          flags=Gio.ApplicationFlags.NON_UNIQUE)
    storage = profile / 'webkit'
    storage.mkdir(parents=True, exist_ok=True, mode=0o700)
    manager = WebKit2.WebsiteDataManager(base_data_directory=str(storage / 'data'),
                                         base_cache_directory=str(storage / 'cache'))
    context = WebKit2.WebContext.new_with_website_data_manager(manager)
    windows = []
    zoom_path = config_path.parent / 'ui.json'
    zoom_percent = load_zoom(zoom_path)
    zoom_widgets = {}
    theme_name = load_theme(zoom_path)
    theme_widgets = {}
    theme_styles = {}
    shell_style = Gtk.CssProvider()
    shell_style.load_from_data(gtk_css(theme_name).encode())

    def refresh_zoom(view, smaller, reset, larger):
        view.set_zoom_level(zoom_percent / 100)
        reset.set_label(f'{zoom_percent}%')
        reset.get_accessible().set_name(f'Zoom {zoom_percent} percent. Reset to 100 percent')
        smaller.set_sensitive(zoom_percent > ZOOM_LEVELS[0])
        larger.set_sensitive(zoom_percent < ZOOM_LEVELS[-1])

    def change_zoom(percent):
        nonlocal zoom_percent
        from .client import write_json
        zoom_percent = percent
        for widgets in zoom_widgets.values():
            refresh_zoom(*widgets)
        try:
            save_ui(zoom_path, zoom_percent=zoom_percent)
        except OSError as exc:
            show_error(f'Zoom changed, but could not save it for next time: {exc}', app.get_active_window())

    def apply_theme(view):
        manager = view.get_user_content_manager()
        previous = theme_styles.get(manager)
        if previous is not None:
            manager.remove_style_sheet(previous)
        # This WebView is confined to the configured service by policy();
        # WebKit match-pattern allowlists do not reliably match loopback ports.
        sheet = WebKit2.UserStyleSheet.new(web_css(theme_name),
            WebKit2.UserContentInjectedFrames.TOP_FRAME,
            WebKit2.UserStyleLevel.USER, None, None)
        manager.add_style_sheet(sheet)
        theme_styles[manager] = sheet

    def change_theme(selector):
        nonlocal theme_name
        selected = selector.get_active_id()
        if selected not in THEMES or selected == theme_name:
            return
        theme_name = selected
        shell_style.load_from_data(gtk_css(theme_name).encode())
        for view, picker in theme_widgets.values():
            picker.set_active_id(theme_name)
            apply_theme(view)
        try:
            save_ui(zoom_path, theme=theme_name)
        except OSError as exc:
            show_error(f'Theme changed, but could not save it for next time: {exc}', app.get_active_window())

    app.set_accels_for_action('win.zoom-in', ['<Primary>plus', '<Primary>equal', '<Primary>KP_Add'])
    app.set_accels_for_action('win.zoom-out', ['<Primary>minus', '<Primary>KP_Subtract'])
    app.set_accels_for_action('win.zoom-reset', ['<Primary>0', '<Primary>KP_0'])

    def policy(view, decision, kind):
        if kind in (WebKit2.PolicyDecisionType.NAVIGATION_ACTION, WebKit2.PolicyDecisionType.NEW_WINDOW_ACTION):
            action = decision.get_navigation_action()
            uri = action.get_request().get_uri()
            if uri != 'about:blank' and not local_navigation(uri, url):
                decision.ignore()
                if action.is_user_gesture() and urlsplit(uri).scheme in ('http', 'https', 'mailto'):
                    Gio.AppInfo.launch_default_for_uri(uri, None)
                return True
        return False

    def download_started(_, download):
        parent = app.get_active_window()
        def destination(item, suggested):
            dialog = Gtk.FileChooserDialog(title='Save download', transient_for=parent,
                                            action=Gtk.FileChooserAction.SAVE)
            dialog.add_buttons('_Cancel', Gtk.ResponseType.CANCEL, '_Save', Gtk.ResponseType.ACCEPT)
            dialog.set_do_overwrite_confirmation(True)
            dialog.set_current_name(Path(suggested).name or 'download')
            folder = GLib.get_user_special_dir(GLib.UserDirectory.DIRECTORY_DOWNLOAD) or str(Path.home())
            dialog.set_current_folder(folder)
            try:
                if dialog.run() == Gtk.ResponseType.ACCEPT:
                    item.set_allow_overwrite(True)
                    item.set_destination(Path(dialog.get_filename()).as_uri())
                else:
                    item.cancel()
            finally:
                dialog.destroy()
            return True
        download.connect('decide-destination', destination)
    context.connect('download-started', download_started)

    def make_window(related=None):
        window = Gtk.ApplicationWindow(application=app, title='Kylin')
        window.set_default_size(1200, 850)
        window.set_icon_name('kylin-client')
        header = Gtk.HeaderBar(title='Kylin', show_close_button=True)
        window.set_titlebar(header)
        header.get_style_context().add_class('kylin-client-header')
        Gtk.StyleContext.add_provider_for_screen(window.get_screen(), shell_style, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
        view = WebKit2.WebView.new_with_related_view(related) if related else WebKit2.WebView.new_with_context(context)
        window.add(view)
        apply_theme(view)
        theme_picker = Gtk.ComboBoxText()
        for key, palette in THEMES.items():
            theme_picker.append(key, palette[0])
        theme_picker.set_active_id(theme_name)
        theme_picker.set_tooltip_text('Colour scheme — saved on this device')
        theme_picker.get_accessible().set_name('Colour scheme')
        theme_picker.connect('changed', change_theme)
        header.pack_start(theme_picker)
        theme_widgets[window] = (view, theme_picker)
        zoom_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        smaller = Gtk.Button(label='−')
        reset = Gtk.Button(label=f'{zoom_percent}%')
        larger = Gtk.Button(label='+')
        for button, name, tip, action_name in (
            (smaller, 'Zoom out', 'Zoom out (Ctrl+−)', 'zoom-out'),
            (reset, 'Reset zoom', 'Reset to 100% (Ctrl+0)', 'zoom-reset'),
            (larger, 'Zoom in', 'Zoom in (Ctrl++ or Ctrl+=)', 'zoom-in'),
        ):
            button.set_size_request(48 if button is not reset else 76, 44)
            button.get_accessible().set_name(name)
            button.set_tooltip_text(tip)
            button.set_action_name('win.' + action_name)
            zoom_box.pack_start(button, False, False, 0)
        for name, operation in (
            ('zoom-in', lambda: change_zoom(next_zoom(zoom_percent, 1))),
            ('zoom-out', lambda: change_zoom(next_zoom(zoom_percent, -1))),
            ('zoom-reset', lambda: change_zoom(100)),
        ):
            action = Gio.SimpleAction.new(name, None)
            action.connect('activate', lambda _action, _value, callback=operation: callback())
            window.add_action(action)
        header.pack_start(zoom_box)
        zoom_widgets[window] = (view, smaller, reset, larger)
        refresh_zoom(*zoom_widgets[window])
        reload_button = Gtk.Button.new_from_icon_name('view-refresh-symbolic', Gtk.IconSize.BUTTON)
        reload_button.set_tooltip_text('Reload interface')
        reload_button.connect('clicked', lambda _: view.reload())
        header.pack_start(reload_button)
        # All feature pages come from the same configured Core and shared archive.
        for label, target in (('Chat', '/'), ('Conversations', '/kylin/conversations'),
                              ('Files / web', '/kylin/access'), ('Write reviews', '/kylin/write-reviews')):
            button = Gtk.Button(label=label)
            if label == 'Conversations':
                button.get_child().set_markup('Conversations <sub><small>beta</small></sub>')
                button.get_accessible().set_name('Conversations (beta)')
            button.set_tooltip_text('Open ' + label.lower() + ' in this window')
            button.connect('clicked', lambda _, path=target: view.load_uri(url.rstrip('/') + path))
            header.pack_end(button)
        back = Gtk.Button.new_from_icon_name('go-previous-symbolic', Gtk.IconSize.BUTTON)
        forward = Gtk.Button.new_from_icon_name('go-next-symbolic', Gtk.IconSize.BUTTON)
        back.set_tooltip_text('Back'); forward.set_tooltip_text('Forward')
        back.connect('clicked', lambda _: view.go_back())
        forward.connect('clicked', lambda _: view.go_forward())
        def navigation_state(*_):
            back.set_sensitive(view.can_go_back())
            forward.set_sensitive(view.can_go_forward())
        view.connect('notify::uri', navigation_state)
        view.connect('load-changed', navigation_state)
        navigation_state()
        header.pack_start(back); header.pack_start(forward)
        settings_button = Gtk.Button.new_from_icon_name('emblem-system-symbolic', Gtk.IconSize.BUTTON)
        settings_button.set_tooltip_text('Connection settings')
        settings_button.connect('clicked', lambda _: configure(config_path, window))
        header.pack_end(settings_button)
        view.connect('notify::title', lambda v, _: header.set_title(v.get_title() or 'Kylin'))
        view.connect('decide-policy', policy)
        view.connect('create', lambda v, _: make_window(v))
        # Honour the page's beforeunload prompt (for example an unsaved note).
        window.connect('delete-event', lambda *_: (view.try_close(), True)[1])
        view.connect('close', lambda *_: window.destroy())
        window.connect('destroy', lambda *_: windows.remove(window))
        window.connect('destroy', lambda *_: zoom_widgets.pop(window, None))
        window.connect('destroy', lambda *_: theme_widgets.pop(window, None))
        view.connect('web-process-terminated', lambda *_: show_error('The web process stopped. Use Reload to reopen the interface; saved conversations remain on the service.', window))
        windows.append(window)
        window.show_all()
        return view

    def activate(_):
        make_window().load_uri(url)
    app.connect('activate', activate)
    def check_stop():
        if stopped.is_set():
            app.quit()
            return False
        return True
    source = GLib.timeout_add(200, check_stop)
    try:
        return app.run([])
    finally:
        if not stopped.is_set():
            GLib.source_remove(source)
