import http.client
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
from pathlib import Path
import tempfile
import threading
import unittest
from kylin_client import client


class Backend(BaseHTTPRequestHandler):
    def log_message(self, *_):
        pass

    def do_GET(self):
        self.server.seen.append((self.path, dict(self.headers)))
        self.send_response(200)
        if self.path == '/stream':
            self.send_header('Content-Type', 'text/event-stream')
            self.end_headers()
            self.wfile.write(b'data: first\n\n')
            self.wfile.flush()
            self.server.release.wait(3)
            self.wfile.write(b'data: [DONE]\n\n')
        elif self.path == '/kylin/bridge.js':
            self.end_headers()
            self.wfile.write(b'/* KylinSync /kylin/api/sync */')
        else:
            self.send_header('Content-Type', 'text/html')
            self.end_headers()
            self.wfile.write(b'<html>Kylin</html>')

    def do_POST(self):
        data = self.rfile.read(int(self.headers['Content-Length']))
        self.server.seen.append((self.path, dict(self.headers)))
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(data)


class ClientTests(unittest.TestCase):
    def setUp(self):
        self.backend = ThreadingHTTPServer(('127.0.0.1', 0), Backend)
        self.backend.seen = []
        self.backend.release = threading.Event()
        threading.Thread(target=self.backend.serve_forever, daemon=True).start()
        self.cfg = client.validate_config({'service_url': f'http://127.0.0.1:{self.backend.server_port}', 'access_token': 'test-secret'})
        self.proxy = client.make_server(self.cfg)
        threading.Thread(target=self.proxy.serve_forever, daemon=True).start()

    def tearDown(self):
        self.backend.release.set()
        for server in (self.proxy, self.backend):
            server.shutdown()
            server.server_close()

    def request(self, path='/', method='GET', body=None, headers=None):
        conn = http.client.HTTPConnection('127.0.0.1', self.proxy.server_port, timeout=2)
        conn.request(method, path, body, headers or {})
        response = conn.getresponse()
        result = response.status, response.read()
        conn.close()
        return result

    def test_frontend_and_token_forwarding(self):
        self.assertEqual(self.request(), (200, b'<html>Kylin</html>'))
        headers = self.backend.seen[-1][1]
        self.assertEqual(headers['Authorization'], 'Bearer test-secret')
        self.assertEqual(headers['Host'], f'127.0.0.1:{self.backend.server_port}')

    def test_json_roundtrip_preserves_unicode(self):
        data = json.dumps({'changes': [{'value': '麒麟'}]}).encode()
        self.assertEqual(self.request('/kylin/api/sync', 'POST', data, {'Content-Type': 'application/json'}), (200, data))

    def test_foreign_host_origin_and_fetch_site_rejected(self):
        for header in ({'Host': 'evil.example'}, {'Origin': 'https://evil.example'}, {'Sec-Fetch-Site': 'cross-site'}):
            self.assertEqual(self.request(headers=header)[0], 403)
        self.assertEqual(self.backend.seen, [])

    def test_non_json_write_rejected(self):
        self.assertEqual(self.request('/kylin/api/sync', 'POST', 'x', {'Content-Type': 'text/plain'})[0], 415)
        self.assertEqual(self.backend.seen, [])

    def test_oversized_and_negative_lengths_rejected(self):
        for length, status in [('-1', 413), (str(client.MAX_BODY + 1), 413), ('invalid', 400)]:
            self.assertEqual(self.request(headers={'Content-Length': length})[0], status)

    def test_origin_and_browser_token_never_forwarded(self):
        origin = f'http://127.0.0.1:{self.proxy.server_port}'
        self.assertEqual(self.request(headers={'Origin': origin, 'Authorization': 'Bearer wrong'})[0], 200)
        headers = self.backend.seen[-1][1]
        self.assertNotIn('Origin', headers)
        self.assertEqual(headers['Authorization'], 'Bearer test-secret')

    def test_stream_arrives_before_backend_finishes(self):
        conn = http.client.HTTPConnection('127.0.0.1', self.proxy.server_port, timeout=1)
        conn.request('GET', '/stream')
        response = conn.getresponse()
        self.assertEqual(response.readline(), b'data: first\n')
        self.assertFalse(self.backend.release.is_set())
        self.backend.release.set()
        self.assertIn(b'[DONE]', response.read())
        conn.close()

    def test_service_check_is_read_only(self):
        client.check_service(self.cfg)
        self.assertEqual(self.backend.seen[-1][0], '/kylin/bridge.js')

    def test_separate_stable_origins_and_private_config(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            client.write_json(root / 'config.json', self.cfg)
            self.assertEqual((root / 'config.json').stat().st_mode & 0o777, 0o600)
            first, profile1 = client.profile_server(self.cfg, root)
            port = first.server_port
            first.server_close()
            again, profile_again = client.profile_server(self.cfg, root)
            self.assertEqual(again.server_port, port)
            self.assertEqual(profile1, profile_again)
            other, profile2 = client.profile_server(dict(self.cfg, access_token='different-account'), root)
            self.assertNotEqual(other.server_port, port)
            self.assertNotEqual(profile1, profile2)
            again.server_close()
            other.server_close()



class ConfigTests(unittest.TestCase):
    def test_native_navigation_keeps_local_blob_exports(self):
        from kylin_client.window import local_navigation
        base='http://127.0.0.1:12345/'
        self.assertTrue(local_navigation(base+'#/memory',base))
        self.assertTrue(local_navigation('blob:'+base+'export-id',base))
        self.assertFalse(local_navigation('blob:http://evil.example/export-id',base))
        self.assertFalse(local_navigation('http://127.0.0.1:123456/evil',base))

    def test_normalize_service_url(self):
        self.assertEqual(client.service_url('https://EXAMPLE.com:443/'), 'https://example.com')
        self.assertEqual(client.service_url('http://[::1]:8095'), 'http://[::1]:8095')

    def test_reject_invalid_urls(self):
        for url in ('file:///tmp/test', 'https://u:p@example.com', 'https://host/path', 'https://host?token=x', 'http://host:99999', '//host', 'http://host/#x', 'https://host\\bad'):
            with self.subTest(url=url), self.assertRaises(ValueError):
                client.service_url(url)

    def test_reject_token_injection_and_plaintext_remote_auth(self):
        for cfg in ({'service_url': 'https://host', 'access_token': 'x\r\nX: y'},
                    {'service_url': 'http://host', 'access_token': 'secret'}):
            with self.assertRaises(ValueError):
                client.validate_config(cfg)


if __name__ == '__main__':
    unittest.main()
