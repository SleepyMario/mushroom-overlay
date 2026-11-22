import hashlib
import subprocess
import tempfile
from pathlib import Path
from unittest import TestCase, mock
from kylin_client import client

class PassTests(TestCase):
    def config(self, **extra):
        return dict(service_url='http://127.0.0.1:8095', access_token_pass_entry='kylin/api-token', **extra)

    def test_secret_runtime_only_and_no_shell(self):
        raw=self.config()
        with mock.patch.object(client.subprocess,'run',return_value=subprocess.CompletedProcess([],0,b'test-secret\nnotes\n',b'')) as run:
            cfg=client.resolve_credentials(raw)
        self.assertEqual(cfg['access_token'],'test-secret')
        self.assertNotIn('access_token',raw)
        self.assertNotIn('access_token_pass_entry',cfg)
        self.assertEqual(run.call_args.args[0],['pass','show','kylin/api-token'])
        self.assertNotIn('shell',run.call_args.kwargs)
        self.assertNotIn('test-secret',cfg['profile_id'])

    def test_unlock_errors_do_not_leak(self):
        for exc in [FileNotFoundError('secret'),subprocess.CalledProcessError(1,[],output=b'secret'),subprocess.TimeoutExpired([],120,output=b'secret')]:
            with mock.patch.object(client.subprocess,'run',side_effect=exc):
                with self.assertRaisesRegex(ValueError,'Cannot unlock') as error:
                    client.resolve_credentials(self.config())
                self.assertNotIn('secret',str(error.exception))

    def test_invalid_entry_and_cleartext_remote_rejected(self):
        for entry in ['../key','/key','a//b','-key','a;echo x','a/./b']:
            with self.assertRaises(ValueError):client.validate_config(dict(self.config(),access_token_pass_entry=entry))
        with self.assertRaises(ValueError):client.validate_config(dict(self.config(),service_url='http://remote.example'))
        with self.assertRaises(ValueError):client.validate_config(self.config(access_token='mixed'))

    def test_existing_profile_and_port_preserved(self):
        with tempfile.TemporaryDirectory() as d:
            root=Path(d)
            old=dict(service_url='http://127.0.0.1:8095',access_token='',timeout=600)
            server,path=client.profile_server(old,root)
            port=server.server_port
            server.server_close()
            with mock.patch.object(client.subprocess,'run',return_value=subprocess.CompletedProcess([],0,b'test-secret',b'')):
                cfg=client.resolve_credentials(self.config(profile_id=path.name))
            server,newpath=client.profile_server(cfg,root)
            try:
                self.assertEqual(path,newpath)
                self.assertEqual(port,server.server_port)
            finally:server.server_close()
