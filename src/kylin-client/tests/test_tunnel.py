import subprocess
import threading
import unittest
from unittest.mock import patch, Mock
from kylin_client import tunnel

CFG = tunnel.validate_config(dict(ssh_host='fixture-core', host_key_alias='fixture-key',
                                 lan_host='192.0.2.1', wireguard_host='192.0.2.2'))
class TunnelTests(unittest.TestCase):
    def test_lan_wins_without_contacting_fallback(self):
        runner = Mock(return_value=Mock(returncode=0))
        self.assertEqual(tunnel.select_route(CFG, runner), 'lan')
        self.assertEqual(runner.call_count, 1)
        self.assertIn('Hostname=192.0.2.1', runner.call_args.args[0])

    def test_failed_auth_and_timeout_allow_verified_fallback(self):
        for first in (Mock(returncode=255), subprocess.TimeoutExpired('ssh', 6)):
            runner = Mock(side_effect=[first, Mock(returncode=0)])
            self.assertEqual(tunnel.select_route(CFG, runner), 'wireguard')
            self.assertIn('Hostname=192.0.2.2', runner.call_args.args[0])

    def test_no_route_and_shutdown_do_not_start_a_tunnel(self):
        runner = Mock(return_value=Mock(returncode=255))
        self.assertIsNone(tunnel.select_route(CFG, runner))
        stop = threading.Event();stop.set();runner.reset_mock()
        self.assertIsNone(tunnel.select_route(CFG, runner, stop))
        runner.assert_not_called()

    def test_identity_and_loopback_are_preserved_on_both_routes(self):
        for route in ('lan', 'wireguard'):
            args = tunnel.command(CFG, route)
            self.assertIn('HostKeyAlias=fixture-key', args)
            self.assertIn('StrictHostKeyChecking=yes', args)
            self.assertIn('BatchMode=yes', args)
            self.assertIn('ControlPath=none', args)
            self.assertIn('127.0.0.1:8095:127.0.0.1:8095', args)
            self.assertEqual(args[-1], 'fixture-core')
            self.assertNotIn('true', args)

    def test_invalid_settings_fail_before_ssh(self):
        for key, value in [('lan_host','-oProxyCommand=x'), ('ssh_host','a b'),
                           ('host_key_alias',''), ('local_port',True), ('remote_port',65536)]:
            with self.subTest(key=key), self.assertRaises(ValueError):
                tunnel.validate_config(dict(CFG, **{key:value}))

    def test_disconnect_reselects_lan_without_replaying_requests(self):
        stopped = Mock();stopped.is_set.side_effect=[False,False,False,True,True]
        child = Mock();child.poll.return_value=0
        spawn = Mock(return_value=child)
        with patch.object(tunnel,'select_route',side_effect=['wireguard','lan']) as select:
            tunnel.maintain(CFG,stopped,spawn)
        self.assertEqual(select.call_count,2)
        self.assertIn('Hostname=192.0.2.2',spawn.call_args_list[0].args[0])
        self.assertIn('Hostname=192.0.2.1',spawn.call_args_list[1].args[0])
        child.terminate.assert_not_called()
