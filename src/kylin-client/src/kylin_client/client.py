"""Small same-origin client proxy and app-window launcher. No model or archive."""
import argparse
import hashlib
import http.client
import json
import os
from pathlib import Path
import signal
import subprocess
import re
import ssl
import sys
import tempfile
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlsplit, urlunsplit

MAX_BODY = 32 * 1024 * 1024
HOP = {'connection', 'keep-alive', 'proxy-authenticate', 'proxy-authorization',
       'te', 'trailer', 'transfer-encoding', 'upgrade'}


def config_home():
    if sys.platform == 'win32':
        return Path(os.environ.get('APPDATA', Path.home() / 'AppData/Roaming')) / 'kylin-client'
    if sys.platform == 'darwin':
        return Path.home() / 'Library/Application Support/kylin-client'
    return Path(os.environ.get('XDG_CONFIG_HOME', Path.home() / '.config')) / 'kylin-client'


def service_url(value):
    if not isinstance(value, str):
        raise ValueError('The service address must be text.')
    value = value.strip()
    parts = urlsplit(value)
    if parts.scheme not in ('http', 'https') or not parts.hostname:
        raise ValueError('Enter a complete http:// or https:// Kylin service address.')
    if parts.username or parts.password or parts.query or parts.fragment or parts.path not in ('', '/'):
        raise ValueError('Use the service root address, without credentials, a path, query or fragment.')
    if any(ord(c) < 33 for c in value) or '\\' in value:
        raise ValueError('Invalid service address.')
    port = parts.port  # Validate the port range, including malformed ports.
    host = parts.hostname.lower()
    if ':' in host:
        host = '[' + host + ']'
    if port and port != (443 if parts.scheme == 'https' else 80):
        host += ':' + str(port)
    return urlunsplit((parts.scheme, host, '', '', ''))


def validate_config(raw):
    if not isinstance(raw, dict):
        raise ValueError('The configuration must be a JSON object.')
    url = service_url(raw.get('service_url', ''))
    token = raw.get('access_token', '')
    if not isinstance(token, str) or any(ord(c) < 32 or ord(c) > 126 for c in token):
        raise ValueError('The access token must contain printable ASCII only.')
    entry = raw.get('access_token_pass_entry', '')
    if not isinstance(entry, str) or (entry and (entry.startswith('-') or not re.fullmatch(r'[A-Za-z0-9_./-]+', entry) or any(x in ('', '.', '..') for x in entry.split('/')))):
        raise ValueError('Invalid pass entry name.')
    if entry and token:
        raise ValueError('Choose either a pass entry or an inline access token.')
    profile = raw.get('profile_id', '')
    if not isinstance(profile, str) or (profile and not re.fullmatch(r'[0-9a-f]{64}', profile)):
        raise ValueError('Invalid existing profile identifier.')
    if (token or entry) and urlsplit(url).scheme == 'http' and urlsplit(url).hostname not in ('localhost', '127.0.0.1', '::1'):
        raise ValueError('Use HTTPS when sending an access token to a remote service.')
    try:
        timeout = int(raw.get('timeout', 600))
    except (ValueError, TypeError):
        raise ValueError('Request timeout must be a number of seconds.') from None
    if not 1 <= timeout <= 3600:
        raise ValueError('Request timeout must be between 1 and 3600 seconds.')
    result = dict(service_url=url, access_token=token, timeout=timeout)
    if entry: result['access_token_pass_entry'] = entry
    if profile: result['profile_id'] = profile
    return result


def resolve_credentials(config):
    """Return runtime-only credentials. Never persist this result."""
    config = validate_config(config)
    entry = config.get('access_token_pass_entry')
    if not entry:
        return config
    try:
        result = subprocess.run(['pass', 'show', entry], capture_output=True,
                                timeout=120, check=True)
        token = result.stdout.decode('utf-8').splitlines()[0]
    except (OSError, subprocess.SubprocessError, UnicodeError, IndexError):
        raise ValueError('Cannot unlock the Kylin token from pass. Unlock your password store and try again.') from None
    if not token or any(ord(c) < 33 or ord(c) > 126 for c in token):
        raise ValueError('The pass entry does not contain a valid access token.')
    # Use the reference, not the resolved secret, as the default profile identity.
    config.setdefault('profile_id', hashlib.sha256((config['service_url'] + '\0pass:' + entry).encode()).hexdigest())
    config.pop('access_token_pass_entry')
    config['access_token'] = token
    return config


def write_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    fd, temp = tempfile.mkstemp(prefix='.' + path.name, dir=path.parent)
    try:
        with os.fdopen(fd, 'w') as out:
            json.dump(value, out, indent=2)
            out.write('\n')
            out.flush()
            os.fsync(out.fileno())
        os.replace(temp, path)
    finally:
        if os.path.exists(temp):
            os.unlink(temp)


def configure(path):
    from .window import configure as show_settings
    return show_settings(path)


class Handler(BaseHTTPRequestHandler):
    protocol_version = 'HTTP/1.1'

    def log_message(self, *_):
        pass  # Never log URLs, headers, prompts, notes or responses.

    def fail(self, status, message):
        data = json.dumps({'error': {'message': message}}).encode()
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(data)))
        self.send_header('Cache-Control', 'no-store')
        self.send_header('Connection', 'close')
        self.end_headers()
        self.close_connection = True
        if self.command != 'HEAD':
            self.wfile.write(data)

    def proxy(self):
        origin = f'http://127.0.0.1:{self.server.server_port}'
        if self.headers.get('Host') != origin[7:] or self.headers.get('Origin', origin) != origin:
            return self.fail(403, 'Local app origin required.')
        if self.headers.get('Sec-Fetch-Site') == 'cross-site':
            return self.fail(403, 'Cross-site requests are not allowed.')
        if not self.path.startswith('/') or self.path.startswith('//') or '\\' in self.path:
            return self.fail(400, 'Invalid request path.')
        if self.headers.get('Transfer-Encoding'):
            return self.fail(400, 'Chunked request bodies are not supported.')
        try:
            lengths = self.headers.get_all('Content-Length') or ['0']
            if len(lengths) != 1:
                raise ValueError()
            length = int(lengths[0])
            if not 0 <= length <= MAX_BODY:
                return self.fail(413, 'Request too large.')
        except ValueError:
            return self.fail(400, 'Invalid content length.')
        if self.command not in ('GET', 'HEAD') and self.headers.get('Content-Type', '').split(';')[0] != 'application/json':
            return self.fail(415, 'JSON requests are required.')
        body = self.rfile.read(length) if length else None
        cfg = self.server.config
        target = urlsplit(cfg['service_url'])
        cls = http.client.HTTPSConnection if target.scheme == 'https' else http.client.HTTPConnection
        kwargs = {'timeout': cfg['timeout']}
        if target.scheme == 'https':
            kwargs['context'] = ssl.create_default_context()
        conn = cls(target.hostname, target.port, **kwargs)
        blocked = HOP | {'host', 'origin', 'referer', 'content-length', 'authorization', 'accept-encoding'}
        blocked |= {h.strip().lower() for h in self.headers.get('Connection', '').split(',')}
        headers = {k: v for k, v in self.headers.items() if k.lower() not in blocked}
        headers['Accept-Encoding'] = 'identity'
        if cfg['access_token']:
            headers['Authorization'] = 'Bearer ' + cfg['access_token']
        started = False
        try:
            conn.request(self.command, self.path, body=body, headers=headers)
            res = conn.getresponse()
            self.send_response(res.status)
            excluded = HOP | {'content-length', 'access-control-allow-origin', 'access-control-allow-credentials'}
            excluded |= {h.strip().lower() for h in res.getheader('Connection', '').split(',')}
            for key, value in res.getheaders():
                if key.lower() in excluded:
                    continue
                if key.lower() == 'location' and value.startswith(cfg['service_url'] + '/'):
                    value = value[len(cfg['service_url']):]
                self.send_header(key, value)
            self.send_header('Connection', 'close')
            self.end_headers()
            self.close_connection = True
            started = True
            if self.command != 'HEAD':
                while chunk := res.read1(65536):
                    self.wfile.write(chunk)
                    self.wfile.flush()  # Preserve streaming tokens, including partial replies.
        except (OSError, http.client.HTTPException):
            if not started:
                self.fail(502, 'Kylin service unavailable. Check that it is running and the connection settings are correct.')
        finally:
            conn.close()

    do_GET = do_HEAD = do_POST = do_PUT = do_PATCH = do_DELETE = proxy


def make_server(config, port=0):
    server = ThreadingHTTPServer(('127.0.0.1', port), Handler)
    server.daemon_threads = True
    server.config = validate_config(config)
    return server


def profile_server(config, directory):
    # Distinct stable local origins AND browser profiles prevent cross-server cache imports.
    key = config.get('profile_id') or hashlib.sha256((config['service_url'] + '\0' + config['access_token']).encode()).hexdigest()
    profiles = directory / 'profiles'
    path = profiles / key
    state = path / 'connection.json'
    if state.exists():
        server = make_server(config, json.loads(state.read_text())['port'])
    else:
        used = {json.loads(p.read_text())['port'] for p in profiles.glob('*/connection.json')}
        for _ in range(100):
            server = make_server(config)
            if server.server_port not in used:
                break
            server.server_close()
        else:
            raise ValueError('Unable to allocate a separate local connection port.')
        write_json(state, {'port': server.server_port})
    return server, path


def check_service(config):
    target = urlsplit(config['service_url'])
    cls = http.client.HTTPSConnection if target.scheme == 'https' else http.client.HTTPConnection
    conn = cls(target.hostname, target.port, timeout=min(config['timeout'], 10))
    headers = {'Authorization': 'Bearer ' + config['access_token']} if config['access_token'] else {}
    try:
        # Probe the small synchronization bridge, never download the growing archive.
        conn.request('GET', '/kylin/bridge.js', headers=headers)
        response = conn.getresponse()
        data = response.read(256 * 1024)
        if response.status != 200:
            raise ValueError(f'Kylin connection check returned HTTP {response.status}. Check the service address and authentication.')
        if b'KylinSync' not in data or b'/kylin/api/sync' not in data:
            raise ValueError('This address is not a compatible Kylin shared-memory service.')
    except (OSError, http.client.HTTPException):
        raise ValueError('Cannot reach Kylin. Start the central service or update the connection settings.') from None
    finally:
        conn.close()


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__, epilog='JSON configuration: {"service_url":"https://your-server.example", "access_token":"", "timeout":600}. Model settings remain on the service.')
    parser.add_argument('--config', type=Path, default=config_home() / 'config.json')
    parser.add_argument('--configure', action='store_true', help='edit connection settings without starting the model')
    parser.add_argument('--no-open', action='store_true', help='serve the client without opening a window; Ctrl+C stops it')
    parser.add_argument('--check', action='store_true', help='check the configured service without launching a window or changing conversations')
    args = parser.parse_args(argv)
    try:
        if args.configure or not args.config.exists():
            if not configure(args.config):
                return 0
            if args.configure:
                return 0
        config = resolve_credentials(json.loads(args.config.read_text()))
        check_service(config)
        if args.check:
            print('Kylin shared-memory service is reachable.')
            return 0
        server, profile = profile_server(config, args.config.parent)
        url = f'http://127.0.0.1:{server.server_port}/'
        print('Kylin client: ' + url, flush=True)
        stopped = threading.Event()
        def stop(*_):
            stopped.set()
        signal.signal(signal.SIGINT, stop)
        signal.signal(signal.SIGTERM, stop)
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()
        try:
            if args.no_open:
                while not stopped.wait(0.5):
                    pass
            else:
                from .window import run_window
                return run_window(url, profile, args.config, stopped)
        finally:
            server.shutdown()
            server.server_close()

        return 0
    except (ValueError, OSError, json.JSONDecodeError) as exc:
        print('Kylin client: ' + str(exc), file=sys.stderr)
        if not (args.no_open or args.check):
            try:
                from .window import show_error
                show_error(str(exc))
            except (ImportError, ValueError):
                pass

        return 1


if __name__ == '__main__':
    raise SystemExit(main())
