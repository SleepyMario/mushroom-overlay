import json,tempfile,unittest
from pathlib import Path
from kylin_client.themes import DEFAULT_THEME,THEMES,APP_PALETTES,load_theme,save_ui,web_css,gtk_css
from kylin_client.window import load_zoom
class ThemeTests(unittest.TestCase):
 def test_theme_and_zoom_preserved_together(self):
  with tempfile.TemporaryDirectory() as d:
   p=Path(d)/'ui.json';p.write_text(json.dumps({'zoom_percent':175,'future':'keep'}))
   self.assertEqual(load_theme(p),'kylinchat')
   save_ui(p,theme='paper');save_ui(p,zoom_percent=200)
   self.assertEqual(load_theme(p),'paper');self.assertEqual(load_zoom(p),200)
   self.assertEqual(json.loads(p.read_text())['future'],'keep');self.assertEqual(p.stat().st_mode&0o777,0o600)
 def test_invalid_theme_safe_default(self):
  with tempfile.TemporaryDirectory() as d:
   p=Path(d)/'ui.json'
   for s in ['broken','null','[]','{"theme": []}','{"theme":"unknown"}']:
    p.write_text(s);self.assertEqual(load_theme(p),DEFAULT_THEME)
 def test_readable_text_contrast(self):
  def luminance(h):
   c=[int(h[i:i+2],16)/255 for i in (1,3,5)];c=[x/12.92 if x<=.04045 else ((x+.055)/1.055)**2.4 for x in c];return sum(x*y for x,y in zip(c,(.2126,.7152,.0722)))
  def ratio(a,b):
   x,y=sorted([luminance(a),luminance(b)]);return (y+.05)/(x+.05)
  for name,(_,_,bg,fg,surface,muted,accent,accent_fg,_) in THEMES.items():
   for a,b in [(bg,fg),(surface,fg),(bg,muted),(surface,muted),(accent,accent_fg)]:
    threshold=3.0 if any(name==k+'-'+variant for k,v in APP_PALETTES.items() for variant in v) else 4.5
    self.assertGreaterEqual(ratio(a,b),threshold,(name,a,b))
 def test_all_palettes_cover_shared_variables(self):
  for name in THEMES:
   css=web_css(name)
   for key in ['background','foreground','popover','input','sidebar','code-background']:
    self.assertIn('--'+key+':',css)
   self.assertIn('.kylin-client-header',gtk_css(name))

class ExactPaletteTests(unittest.TestCase):
 def test_source_palette_identity(self):
  for name,variants in APP_PALETTES.items():
   for variant,colors in variants.items():
    palette=THEMES[name+'-'+variant]
    self.assertEqual((palette[2],palette[3],palette[6]),(colors['surface'],colors['ink'],colors['accent']))
