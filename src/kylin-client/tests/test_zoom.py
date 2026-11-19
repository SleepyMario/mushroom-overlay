import json
from pathlib import Path
import tempfile
import unittest
from kylin_client.client import write_json
from kylin_client.window import load_zoom, next_zoom


class ZoomPreferencesTests(unittest.TestCase):
    def test_saved_zoom_survives_connection_edits_and_reopen(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            ui = root / "ui.json"
            self.assertEqual(load_zoom(ui), 100)
            write_json(ui, {"zoom_percent": 175})
            write_json(root / "config.json", {"service_url": "https://example.invalid"})
            self.assertEqual(load_zoom(ui), 175)
            self.assertEqual(ui.stat().st_mode & 0o777, 0o600)
            write_json(ui, {"zoom_percent": 100})
            self.assertEqual(load_zoom(ui), 100)

    def test_bad_preferences_and_zoom_limits(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "ui.json"
            for value in (None, "large", True, float("nan")):
                path.write_text(json.dumps({"zoom_percent": value}))
                self.assertEqual(load_zoom(path), 100)
            path.write_text("broken json")
            self.assertEqual(load_zoom(path), 100)
            path.write_text(json.dumps({"zoom_percent": 9999}))
            self.assertEqual(load_zoom(path), 400)
            self.assertEqual(next_zoom(400, 1), 400)
            self.assertEqual(next_zoom(50, -1), 50)
            self.assertEqual(next_zoom(125, 1), 150)
            self.assertEqual(next_zoom(125, -1), 110)
