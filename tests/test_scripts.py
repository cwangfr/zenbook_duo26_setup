#!/usr/bin/env python3
# Offline packaging tests only: no target hardware or services accessed.
import hashlib
import re
import subprocess
import unittest
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]

class ScriptTests(unittest.TestCase):
    def test_original_attachments(self):
        expected = {
            'scripts/xe/zenbook_duo_ubuntu_xe_dkms_install_v3.sh': 'de1ed7221d6fd22a380d5fd75d9adc6a4f6adc0a09d1e2d77c4ef24ec558d4bb',
            'scripts/xe/zenbook_duo_ubuntu_xe_dkms_rollback.sh': '15f52f9074b5e832f1ffd014b016b75a906689bf56450c188dca23cebaa08a29',
            'archive/xe-install-v1.sh.txt': '9dcbe66fede1b61d0d89c33b1ef46f111fa641bce995a81b60628cab495b155e',
            'archive/xe-install-v2.sh.txt': '8995352f2685993dd6b25fc88a863c910d380941cd59bc1ec1fcd49a6f750d05',
        }
        for name, digest in expected.items():
            self.assertEqual(hashlib.sha256((ROOT/name).read_bytes()).hexdigest(), digest, name)

    def test_help_is_read_only(self):
        for name in ('preflight.sh','fetch-upstream.sh','check-mok.sh','install-xe.sh',
                     'verify.sh','bluetooth-reload.sh','collect-diagnostics.sh','backup-local.sh'):
            p=subprocess.run(['bash',str(ROOT/'scripts'/name),'--help'],capture_output=True,text=True,timeout=5)
            self.assertEqual(p.returncode,0,(name,p.stderr))
            self.assertIn('Usage:',p.stdout)

    def test_no_automatic_reboot(self):
        pattern=re.compile(r'^\s*(?:sudo\s+)?(?:systemctl\s+)?(?:reboot|poweroff)\b',re.M)
        for p in list((ROOT/'scripts').rglob('*.sh'))+list((ROOT/'optional').rglob('*.sh')):
            self.assertIsNone(pattern.search(p.read_text()),str(p))

    def test_no_private_key_material(self):
        pattern=re.compile(rb'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----')
        for p in ROOT.rglob('*'):
            if p.is_file() and '.git' not in p.parts and '__pycache__' not in p.parts:
                self.assertIsNone(pattern.search(p.read_bytes()),str(p))

    def test_bluetooth_package_is_conditional(self):
        p=ROOT/'optional/bluetooth-recovery'
        body=(p/'zenbook-bt-recover').read_text()
        self.assertIn('Intel Soft Reset failed (-62)',body)
        self.assertIn('0xe476',body)
        self.assertEqual(body.count('modprobe -r btintel_pcie'),1)
        self.assertNotIn('modprobe -r xe',body)
        timer=(p/'zenbook-bt-recover.timer').read_text()
        self.assertIn('OnBootSec=25s',timer)
        self.assertNotIn('OnUnitActiveSec',timer)

    def test_xe_wrapper_is_pinned_and_no_gdm(self):
        body=(ROOT/'scripts/install-xe.sh').read_text()
        self.assertIn('7.0.0-38-generic',body)
        self.assertIn('fetch-upstream.sh',body)
        self.assertIn('check-mok.sh',body)
        self.assertNotIn('/var/lib/gdm3',body)
        self.assertNotIn('panel_orientation=upside_down',body)

if __name__=='__main__':
    unittest.main(verbosity=2)
