"""Offline browser regressions for errors the live validator must not miss."""

import tempfile
import unittest
from pathlib import Path

from playwright.sync_api import sync_playwright
from validate_live_apps import Robot


class RobotErrorDetectionTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.playwright = sync_playwright().start()
        cls.browser = cls.playwright.chromium.launch(headless=True)

    @classmethod
    def tearDownClass(cls):
        cls.browser.close()
        cls.playwright.stop()

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.page = self.browser.new_page()
        self.addCleanup(self.page.close)
        self.robot = Robot(self.page, "offline", Path(self.temp.name))
        self.page.goto("data:text/html,<main>Healthy result</main>")

    def test_transient_server_exception_survives_rerender(self):
        self.page.evaluate("""async () => {
            const node = document.createElement('div');
            node.dataset.testid = 'stException';
            node.textContent = "ModuleNotFoundError: No module named 'torchvision'";
            document.body.append(node);
            await new Promise(resolve => setTimeout(resolve, 0));
            node.remove();
        }""")
        self.assertEqual(self.page.locator('[data-testid="stException"]').count(), 0)
        with self.assertRaisesRegex(AssertionError, "torchvision"):
            self.robot.assert_ui_healthy()

    def test_fatal_alert_is_checked_before_success_predicate(self):
        self.page.evaluate("""() => {
            const node = document.createElement('div');
            node.dataset.testid = 'stAlert';
            node.textContent = 'Run failed: missing dependency';
            document.body.append(node);
        }""")
        with self.assertRaisesRegex(AssertionError, "missing dependency"):
            self.robot.wait(lambda: True)

    def test_model_preparation_failure_is_fatal(self):
        self.page.evaluate("""() => {
            const node = document.createElement('div');
            node.dataset.testid = 'stAlert';
            node.textContent = 'Chronos-2 Small could not be prepared.';
            document.body.append(node);
        }""")
        with self.assertRaisesRegex(AssertionError, "could not be prepared"):
            self.robot.wait(lambda: True)

    def test_expected_infeasible_result_is_not_a_runtime_error(self):
        self.page.evaluate("""() => {
            const node = document.createElement('div');
            node.dataset.testid = 'stAlert';
            node.textContent = 'Infeasible: no solution meets these constraints';
            document.body.append(node);
        }""")
        self.robot.wait(lambda: True)

    def test_javascript_error_is_retained(self):
        with self.page.expect_event("pageerror"):
            self.page.evaluate(
                "setTimeout(() => { throw new Error('broken component'); }, 0)"
            )
        self.assertTrue(any("broken component" in error for error in self.robot.errors))


if __name__ == "__main__":
    unittest.main()
