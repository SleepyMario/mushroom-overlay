"""Client-local palettes; no conversation, model or server state is changed."""
import json

DEFAULT_THEME = 'kylinchat'
# label, dark, page, text, surface, muted text, accent, accent text, border
THEMES = {
    'kylinchat': ('KylinChat', True, '#142124', '#e9f0ec', '#203331', '#afc4bb', '#b9dfb3', '#142124', '#78958a'),
    'chatgpt-light': ('ChatGPT Light', False, '#ffffff', '#202123', '#f4f4f4', '#626262', '#202123', '#ffffff', '#b8b8b8'),
    'chatgpt-dark': ('ChatGPT Dark', True, '#212121', '#ececec', '#303030', '#b4b4b4', '#ececec', '#212121', '#747474'),
    'midnight': ('Midnight Blue', True, '#111827', '#edf3ff', '#1e293b', '#b5c6df', '#93c5fd', '#112238', '#647b9a'),
    'paper': ('Warm Paper', False, '#faf4e8', '#352d23', '#eee4d2', '#695b48', '#76562b', '#ffffff', '#a38e70'),
    'lavender': ('Lavender', False, '#f6f2ff', '#302740', '#e9e0f5', '#665774', '#705095', '#ffffff', '#a18bb8'),
    'forest': ('Forest', True, '#13251b', '#edf5e9', '#233b2b', '#b5cbb3', '#b4d88b', '#172413', '#729071'),
    'solarized-light': ('Solarized Light', False, '#fdf6e3', '#586e75', '#eee8d5', '#586e75', '#586e75', '#fdf6e3', '#839496'),
    'solarized-dark': ('Solarized Dark', True, '#002b36', '#93a1a1', '#073642', '#93a1a1', '#2aa198', '#002b36', '#657b83'),
    'contrast': ('High Contrast', True, '#000000', '#ffffff', '#181818', '#eeeeee', '#ffff00', '#000000', '#ffffff'),
}


# Background/text/accent colour values from the installed desktop app's palette
# catalogue (2026-11-21). Only colour data is reused, not application code.
APP_PALETTES = {'absolutely': {'light': {'surface': '#f9f9f7', 'ink': '#2d2d2b', 'accent': '#cc7d5e'},
                'dark': {'surface': '#2d2d2b', 'ink': '#f9f9f7', 'accent': '#cc7d5e'}},
 'ayu': {'dark': {'surface': '#10141c', 'ink': '#bfbdb6', 'accent': '#e6b450'}},
 'catppuccin': {'light': {'surface': '#eff1f5', 'ink': '#4c4f69', 'accent': '#8839ef'},
                'dark': {'surface': '#1e1e2e', 'ink': '#cdd6f4', 'accent': '#cba6f7'}},
 'dracula': {'dark': {'surface': '#282a36', 'ink': '#f8f8f2', 'accent': '#ff79c6'}},
 'everforest': {'light': {'surface': '#fdf6e3', 'ink': '#5c6a72', 'accent': '#93b259'},
                'dark': {'surface': '#2d353b', 'ink': '#d3c6aa', 'accent': '#a7c080'}},
 'github': {'light': {'surface': '#ffffff', 'ink': '#1f2328', 'accent': '#0969da'},
            'dark': {'surface': '#0d1117', 'ink': '#e6edf3', 'accent': '#1f6feb'}},
 'gruvbox': {'light': {'surface': '#fbf1c7', 'ink': '#3c3836', 'accent': '#458588'},
             'dark': {'surface': '#282828', 'ink': '#ebdbb2', 'accent': '#458588'}},
 'linear': {'light': {'surface': '#fcfcfd', 'ink': '#1b1b1b', 'accent': '#5e6ad2'},
            'dark': {'surface': '#0f0f11', 'ink': '#e3e4e6', 'accent': '#606acc'}},
 'lobster': {'dark': {'surface': '#111827', 'ink': '#e4e4e7', 'accent': '#ff5c5c'}},
 'material': {'dark': {'surface': '#212121', 'ink': '#eeffff', 'accent': '#80cbc4'}},
 'matrix': {'dark': {'surface': '#040805', 'ink': '#b8ffca', 'accent': '#1eff5a'}},
 'monokai': {'dark': {'surface': '#272822', 'ink': '#f8f8f2', 'accent': '#99947c'}},
 'night-owl': {'dark': {'surface': '#011627', 'ink': '#d6deeb', 'accent': '#44596b'}},
 'nord': {'dark': {'surface': '#2e3440', 'ink': '#d8dee9', 'accent': '#88c0d0'}},
 'notion': {'light': {'surface': '#ffffff', 'ink': '#37352f', 'accent': '#3183d8'},
            'dark': {'surface': '#191919', 'ink': '#d9d9d8', 'accent': '#3183d8'}},
 'og': {'dark': {'surface': '#343541', 'ink': '#d1d5db', 'accent': '#10a37f'}},
 'one': {'light': {'surface': '#fafafa', 'ink': '#383a42', 'accent': '#526fff'},
         'dark': {'surface': '#282c34', 'ink': '#abb2bf', 'accent': '#4d78cc'}},
 'oscurange': {'dark': {'surface': '#0b0b0f', 'ink': '#e6e6e6', 'accent': '#f9b98c'}},
 'proof': {'light': {'surface': '#f5f3ed', 'ink': '#2f312d', 'accent': '#3d755d'}},
 'raycast': {'light': {'surface': '#ffffff', 'ink': '#030303', 'accent': '#ff6363'},
             'dark': {'surface': '#101010', 'ink': '#fefefe', 'accent': '#ff6363'}},
 'rose-pine': {'light': {'surface': '#faf4ed', 'ink': '#575279', 'accent': '#d7827e'},
               'dark': {'surface': '#232136', 'ink': '#e0def4', 'accent': '#ea9a97'}},
 'sentry': {'dark': {'surface': '#2d2935', 'ink': '#e6dff9', 'accent': '#7055f6'}},
 'solarized': {'light': {'surface': '#fdf6e3', 'ink': '#657b83', 'accent': '#b58900'},
               'dark': {'surface': '#002b36', 'ink': '#839496', 'accent': '#d30102'}},
 'temple': {'dark': {'surface': '#02120c', 'ink': '#c7e6da', 'accent': '#e4f222'}},
 'tokyo-night': {'dark': {'surface': '#1a1b26', 'ink': '#a9b1d6', 'accent': '#3d59a1'}},
 'vercel': {'light': {'surface': '#ffffff', 'ink': '#171717', 'accent': '#006aff'},
            'dark': {'surface': '#000000', 'ink': '#ededed', 'accent': '#006efe'}},
 'vscode-plus': {'light': {'surface': '#ffffff', 'ink': '#000000', 'accent': '#007acc'},
                 'dark': {'surface': '#1e1e1e', 'ink': '#d4d4d4', 'accent': '#007acc'}},
 'xcode': {'light': {'surface': '#ffffff', 'ink': '#000000', 'accent': '#0e0eff'},
           'dark': {'surface': '#1f1f24', 'ink': '#ffffff', 'accent': '#5482ff'}}}


def _mix(a, b, amount):
    return '#' + ''.join(f'{round(int(a[i:i+2],16)*(1-amount)+int(b[i:i+2],16)*amount):02x}' for i in (1,3,5))


def _luminance(color):
    values = [int(color[i:i+2],16)/255 for i in (1,3,5)]
    return sum((v/12.92 if v <= .04045 else ((v+.055)/1.055)**2.4)*weight for v,weight in zip(values,(.2126,.7152,.0722)))


_LABELS = {'ayu':'Ayu','catppuccin':'Catppuccin','github':'GitHub','rose-pine':'Rose Pine',
           'og':'ChatGPT OG','vscode-plus':'VS Code+','xcode':'Xcode','tokyo-night':'Tokyo Night',
           'night-owl':'Night Owl'}
for _name, _variants in APP_PALETTES.items():
    for _variant, _values in _variants.items():
        _bg, _fg, _accent = (_values[k] for k in ('surface','ink','accent'))
        _lum = _luminance(_accent)
        _accent_fg = '#000000' if (_lum+.05)/.05 >= 1.05/(_lum+.05) else '#ffffff'
        _label = _LABELS.get(_name, _name.replace('-', ' ').title()) + ' ' + _variant.title()
        THEMES[_name+'-'+_variant] = (_label, _variant=='dark', _bg, _fg,
            _mix(_bg,_fg,.04), _fg, _accent, _accent_fg, _mix(_bg,_fg,.4))


def load_theme(path):
    try:
        name = json.loads(path.read_text()).get('theme', DEFAULT_THEME)
        return name if isinstance(name, str) and name in THEMES else DEFAULT_THEME
    except (OSError, ValueError, TypeError, AttributeError):
        return DEFAULT_THEME


def save_ui(path, **changes):
    from .client import write_json
    try:
        value = json.loads(path.read_text())
        if not isinstance(value, dict): value = {}
    except (OSError, ValueError):
        value = {}
    value.update(changes)
    write_json(path, value)


def web_css(name):
    _, dark, bg, fg, surface, muted, accent, accent_fg, border = THEMES[name]
    variables = {
        'background': bg, 'foreground': fg, 'card': surface, 'card-foreground': fg,
        'popover': surface, 'popover-foreground': fg, 'primary': accent,
        'primary-foreground': accent_fg, 'secondary': surface, 'secondary-foreground': fg,
        'muted': surface, 'muted-foreground': muted, 'accent': surface,
        'accent-foreground': fg, 'border': border, 'input': border, 'ring': accent,
        'sidebar': surface, 'sidebar-foreground': fg, 'sidebar-primary': accent,
        'sidebar-primary-foreground': accent_fg, 'sidebar-accent': bg,
        'sidebar-accent-foreground': fg, 'sidebar-border': border, 'sidebar-ring': accent,
        'code-background': surface, 'code-foreground': fg,
        'destructive': '#ff9090' if dark else '#b42318',
    }
    declarations = ';'.join('--'+key+':'+value+' !important' for key,value in variables.items())
    return f'''/* Kylin Client theme: {name} */
:root, :root.dark, :root.light {{ {declarations}; color-scheme: {'dark' if dark else 'light'} !important; }}
html, body {{ background-color: {bg} !important; color: {fg} !important; }}
::selection {{ background-color: {accent} !important; color: {accent_fg} !important; }}
/* Standalone Core utility pages use native form elements rather than Tailwind. */
body:has(> h1) section, body:has(> h1) article, body:has(> h1) pre {{ background-color: {surface} !important; color: {fg} !important; border-color: {border} !important; }}
body:has(> h1) input, body:has(> h1) textarea, body:has(> h1) select {{ background-color: {surface} !important; border-color: {border} !important; }}
body:has(> h1) button {{ background-color: {accent} !important; color: {accent_fg} !important; border-color: {border} !important; }}
body:has(> h1) a {{ color: {accent if dark else fg} !important; }}
body:has(> h1) .muted {{ color: {muted} !important; }}
body:has(> h1) #notice, body:has(> h1) #status {{ color: {fg} !important; }}
input, textarea, select {{ color: {fg} !important; caret-color: {fg} !important; }}
input::placeholder, textarea::placeholder {{ color: {muted} !important; opacity: 1 !important; }}
'''


def gtk_css(name):
    _, _, bg, fg, surface, muted, accent, accent_fg, border = THEMES[name]
    return f'''
.kylin-client-header {{ background-image: none; background-color: {bg}; color: {fg}; border-color: {border}; }}
.kylin-client-header button, .kylin-client-header combobox {{ background-image: none; background-color: {surface}; color: {fg}; border-color: {border}; text-shadow: none; box-shadow: none; }}
.kylin-client-header button:hover {{ background-image: none; background-color: {accent}; color: {accent_fg}; }}
.kylin-client-header button:disabled {{ color: {muted}; }}
.kylin-client-header label {{ color: inherit; text-shadow: none; }}
'''
