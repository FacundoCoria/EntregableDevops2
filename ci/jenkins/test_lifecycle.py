"""Safety checks for destructive lifecycle operations; no Docker required."""
import contextlib
import io
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch
import lifecycle as lc

PROJECT = 'l4-c01-test'


class SafetyTests(unittest.TestCase):
    def test_missing_volume_lowercase_response_is_empty(self):
        response = type('Result', (), {'returncode': 1, 'stderr': 'Error response from daemon: get missing: no such volume'})()
        with patch.object(lc.subprocess, 'run', return_value=response):
            self.assertEqual(lc.objects('volume', ['missing']), [])

    def test_missing_network_response_is_empty(self):
        response = type('Result', (), {'returncode': 1, 'stderr': 'Error response from daemon: network missing not found'})()
        with patch.object(lc.subprocess, 'run', return_value=response):
            self.assertEqual(lc.objects('network', ['missing']), [])

    def test_inspection_access_denied_is_not_empty(self):
        response = type('Result', (), {'returncode': 1, 'stderr': 'permission denied connecting to Docker'})()
        with patch.object(lc.subprocess, 'run', return_value=response):
            with self.assertRaisesRegex(RuntimeError, 'No se pudo inspeccionar'):
                lc.objects('network', ['missing'])

    def test_rejects_shared_project_before_docker(self):
        with patch.object(sys, 'argv', ['lifecycle.py', 'purge', '--project', 'default', '--confirm', 'default']), patch.object(lc, 'run') as docker:
            with self.assertRaisesRegex(RuntimeError, 'Solo proyectos'):
                lc.main()
            docker.assert_not_called()

    def test_purge_requires_exact_confirmation(self):
        with patch.object(sys, 'argv', ['lifecycle.py', 'purge', '--project', PROJECT]), patch.object(lc, 'inventory') as inventory:
            with self.assertRaisesRegex(RuntimeError, 'confirm'):
                lc.main()
            inventory.assert_not_called()

    def test_rejects_wrong_volume_owner(self):
        volume = {'Name': PROJECT + '_controller-home', 'Labels': {'com.docker.compose.project': 'course'}}
        with patch.object(lc, 'objects', side_effect=[[], [volume], []]), patch.object(lc, 'run', return_value=''):
            with self.assertRaisesRegex(RuntimeError, 'Propiedad'):
                lc.inventory(PROJECT)

    def test_rejects_shared_volume(self):
        volume = {'Name': PROJECT + '_controller-home', 'Labels': {'com.docker.compose.project': PROJECT}}
        def docker(*args):
            if args[:2] == ('volume', 'ls'):
                return volume['Name']
            if 'volume=' + volume['Name'] in args:
                return 'foreign-container'
            return ''
        with patch.object(lc, 'objects', side_effect=[[], [volume], []]), patch.object(lc, 'run', side_effect=docker):
            with self.assertRaisesRegex(RuntimeError, 'Volumen compartido'):
                lc.inventory(PROJECT)

    def test_rejects_shared_network(self):
        network = {'Name': PROJECT + '_control', 'Id': 'abc123', 'Labels': {'com.docker.compose.project': PROJECT}, 'Containers': {'foreign': {}}}
        with patch.object(lc, 'objects', side_effect=[[], [], [network]]), patch.object(lc, 'run', return_value=''):
            with self.assertRaisesRegex(RuntimeError, 'Red compartida'):
                lc.inventory(PROJECT)

    def test_refuses_busy_jenkins(self):
        data = {'containers': [{'Name': '/' + PROJECT + '-controller-1', 'Id': 'controller', 'State': {'Running': True}}]}
        with patch.object(lc, 'run', side_effect=[json.dumps({'items': [{'id': 1}]}), json.dumps({'computer': []})]):
            with self.assertRaisesRegex(RuntimeError, 'builds activos'):
                lc.idle(PROJECT, data)

    def test_restore_does_not_overwrite_existing_destination(self):
        with patch.object(lc, 'load_backup') as load:
            with self.assertRaisesRegex(RuntimeError, 'destino completamente nuevo'):
                lc.restore(PROJECT, {'volumes': ['existing']}, 'test')
            load.assert_not_called()

    def test_corruption_rejected_before_docker(self):
        with tempfile.TemporaryDirectory() as temp, patch.object(lc, 'LOCAL', Path(temp)), patch.object(lc, 'run') as docker:
            folder = Path(temp) / 'backups' / 'test'
            folder.mkdir(parents=True)
            (folder / 'manifest.json').write_text(json.dumps({'format': 1, 'id': 'test'}))
            names = ['controller-home.tar.gz', 'agent-home.tar.gz', 'manifest.json', 'source.tar.gz']
            (folder / 'sha256.json').write_text(json.dumps({n: '0' * 64 for n in names}))
            for n in names[:-2]:
                (folder / n).write_bytes(b'corrupted')
            with self.assertRaisesRegex(RuntimeError, 'corrupta'):
                lc.load_backup('test')
            docker.assert_not_called()


if __name__ == '__main__':
    unittest.main()
