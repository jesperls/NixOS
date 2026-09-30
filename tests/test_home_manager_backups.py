import pathlib
import subprocess
import sys
import tempfile
import unittest


BACKUP = sys.argv.pop(1)


class BackupRotation(unittest.TestCase):
    def test_files_and_directories(self):
        for directory in (False, True):
            with self.subTest(directory=directory), tempfile.TemporaryDirectory() as root:
                target = pathlib.Path(root) / "config with 'quotes' and $dollars"
                for generation in range(5):
                    if directory:
                        target.mkdir()
                        (target / "content").write_text(str(generation))
                    else:
                        target.write_text(str(generation))
                    subprocess.run([BACKUP, str(target)], check=True)

                self.assertFalse(target.exists())
                for index, generation in enumerate((4, 3, 2), 1):
                    backup = pathlib.Path(f"{target}.hm-backup.{index}")
                    content = backup / "content" if directory else backup
                    self.assertEqual(content.read_text(), str(generation))
                self.assertFalse(pathlib.Path(f"{target}.hm-backup.4").exists())

    def test_broken_symlinks(self):
        with tempfile.TemporaryDirectory() as root:
            target = pathlib.Path(root) / "config"
            for generation in range(5):
                target.symlink_to(f"missing-{generation}")
                subprocess.run([BACKUP, str(target)], check=True)
            for index, generation in enumerate((4, 3, 2), 1):
                backup = pathlib.Path(f"{target}.hm-backup.{index}")
                self.assertTrue(backup.is_symlink())
                self.assertEqual(str(backup.readlink()), f"missing-{generation}")

    def test_expired_symlink_preserves_its_target(self):
        with tempfile.TemporaryDirectory() as root:
            target = pathlib.Path(root) / "config"
            preserved = pathlib.Path(root) / "preserved"
            preserved.mkdir()
            (preserved / "content").write_text("keep")
            pathlib.Path(f"{target}.hm-backup.3").symlink_to(preserved)
            target.write_text("new")
            subprocess.run([BACKUP, str(target)], check=True)
            self.assertEqual((preserved / "content").read_text(), "keep")


if __name__ == "__main__":
    unittest.main()
