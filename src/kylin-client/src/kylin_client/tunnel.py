"""One SSH transport policy for every client: LAN first, WireGuard fallback.

Endpoints and trusted SSH identity are local settings, never package defaults.
The client URL/profile stays unchanged and credentials remain in the client.
"""
import argparse
import json
from pathlib import Path
import signal
import subprocess
import threading
from .client import config_home


def validate_config(raw):
    if not isinstance(raw, dict):
        raise ValueError('Tunnel configuration must be an object.')
    cfg = dict(raw)
    for key in ('ssh_host', 'host_key_alias', 'lan_host', 'wireguard_host'):
        value = cfg.get(key)
        if not isinstance(value, str) or not value or len(value) > 253 or value.startswith('-') or any(c.isspace() or ord(c) < 32 for c in value):
            raise ValueError('Invalid tunnel setting: ' + key)
    for key in ('local_port', 'remote_port'):
        value = cfg.get(key, 8095)
        if type(value) is not int or not 1 <= value <= 65535:
            raise ValueError('Invalid tunnel port: ' + key)
        cfg[key] = value
    config = cfg.get('ssh_config', '~/.ssh/config')
    if not isinstance(config, str) or '\0' in config:
        raise ValueError('Invalid SSH configuration path.')
    cfg['ssh_config'] = str(Path(config).expanduser())
    return cfg


def command(cfg, route, *, probe=False):
    args = ['/usr/bin/ssh', '-F', cfg['ssh_config'], '-T',
            '-o', 'BatchMode=yes', '-o', 'StrictHostKeyChecking=yes',
            '-o', 'ConnectTimeout=3', '-o', 'ConnectionAttempts=1',
            '-o', 'ControlMaster=no', '-o', 'ControlPath=none',
            '-o', 'HostKeyAlias=' + cfg['host_key_alias'],
            '-o', 'Hostname=' + cfg[route + '_host']]
    if probe:
        return args + [cfg['ssh_host'], 'true']
    return args + ['-N', '-o', 'ExitOnForwardFailure=yes',
                   '-o', 'ServerAliveInterval=15', '-o', 'ServerAliveCountMax=3',
                   '-L', f"127.0.0.1:{cfg['local_port']}:127.0.0.1:{cfg['remote_port']}",
                   cfg['ssh_host']]


def select_route(cfg, runner=subprocess.run, stopped=None):
    for route in ('lan', 'wireguard'):
        if stopped is not None and stopped.is_set():
            return None
        try:
            result = runner(command(cfg, route, probe=True), stdin=subprocess.DEVNULL,
                            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                            timeout=6, check=False)
        except (OSError, subprocess.TimeoutExpired):
            continue
        if result.returncode == 0:
            return route
    return None


def maintain(cfg, stopped, spawn=subprocess.Popen):
    while not stopped.is_set():
        route = select_route(cfg, stopped=stopped)
        if route is None:
            print('Kylin tunnel: neither route is available; retrying.', flush=True)
            stopped.wait(3)
            continue
        print('Kylin tunnel: connecting via ' + route + '.', flush=True)
        child = spawn(command(cfg, route), stdin=subprocess.DEVNULL)
        try:
            # Keep an established connection, including in-flight requests.
            # On disconnect, selection starts at LAN again. No HTTP replay.
            while child.poll() is None and not stopped.wait(.5):
                pass
        finally:
            if child.poll() is None:
                child.terminate()
                try:
                    child.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    child.kill()
                    child.wait()
        if not stopped.is_set():
            stopped.wait(3)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--config', type=Path, default=config_home() / 'tunnel.json')
    parser.add_argument('--check', action='store_true', help='check route selection without opening a tunnel')
    args = parser.parse_args(argv)
    try:
        cfg = validate_config(json.loads(args.config.read_text()))
        if args.check:
            route = select_route(cfg)
            print('Kylin tunnel: ' + (route or 'no route available'))
            return 0 if route else 1
        stopped = threading.Event()
        for sig in (signal.SIGTERM, signal.SIGINT):
            signal.signal(sig, lambda *_: stopped.set())
        maintain(cfg, stopped)
        return 0
    except (OSError, ValueError) as exc:
        print('Kylin tunnel: ' + str(exc))
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
