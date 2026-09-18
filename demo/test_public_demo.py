"""Regression checks for the public example, independent of private Tokki."""
import shutil
import tempfile
import unittest
import zipfile
from pathlib import Path
from unittest.mock import patch

import app


class PublicDemoTests(unittest.TestCase):
    def test_model_and_measurement_changes_produce_real_predictions(self):
        first = app.analyse(3, "Decision tree", 5.1, 3.5, 1.4, .2)
        second = app.analyse(5, "Random forest", 6.7, 3.1, 5.6, 2.4)
        self.assertIn("**setosa**", first[0])
        self.assertIn("**virginica**", second[0])
        self.assertEqual(set(first[1]["model"]), set(app.MODEL_NAMES))
        self.assertAlmostEqual(float(second[-1]["model probability"].sum()), 1)

    def test_invalid_inputs_are_rejected(self):
        for depth, model, length in [(None, "Decision tree", 5), (11, "Decision tree", 5),
                                     (3, "arbitrary code", 5), (3, "Decision tree", float("nan"))]:
            with self.subTest(depth=depth, model=model, length=length), self.assertRaises(app.gr.Error):
                app.analyse(depth, model, length, 3.5, 1.4, .2)

    def test_cached_models_do_not_bypass_artifact_verification(self):
        app.analyse(3, "Decision tree", 5.1, 3.5, 1.4, .2)
        with tempfile.TemporaryDirectory() as directory:
            artifacts = Path(directory) / "artifacts"
            shutil.copytree(app.ARTIFACTS, artifacts)
            (artifacts / "models.py").write_text("changed after verification")
            with patch.object(app, "ARTIFACTS", artifacts), self.assertRaises(ValueError):
                app.analyse(3, "Decision tree", 5.1, 3.5, 1.4, .2)

    def test_download_contains_only_the_public_artifacts(self):
        with zipfile.ZipFile(app.download_bundle()) as archive:
            self.assertEqual(set(archive.namelist()),
                {"app.py", "models.py", "solution.ipynb", "lab_stages.toml", "LICENSE", "result.json"})
            self.assertNotIn(b"/Users/", archive.read("result.json"))

    def test_original_model_notebook_and_app_verification(self):
        self.assertTrue(app.verify_original().startswith("**Passed:**"))

    def test_native_interface_disables_analytics(self):
        self.assertFalse(app.build_interface().analytics_enabled)


if __name__ == "__main__":
    unittest.main()
