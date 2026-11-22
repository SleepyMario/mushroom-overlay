import unittest
from kylin_client.window import local_navigation
class NavigationTests(unittest.TestCase):
 def test_sandbox_frame_and_same_origin_allowed(self):
  for uri in ('about:srcdoc','http://127.0.0.1:8095/chat','blob:http://127.0.0.1:8095/id'):
   self.assertTrue(local_navigation(uri,'http://127.0.0.1:8095/'))
 def test_foreign_origins_files_and_lookalikes_remain_blocked(self):
  for uri in ('https://evil.example','file:///etc/passwd','javascript:alert(1)','about:srcdoc.evil','http://127.0.0.1:8096/','blob:https://evil.example/id'):
   self.assertFalse(local_navigation(uri,'http://127.0.0.1:8095/'))
