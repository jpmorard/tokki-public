"""Exercise published notebook apps through their real Streamlit browser UI."""

import argparse
import hashlib
import json
import re
import time
import traceback
import zipfile
from pathlib import Path

from playwright.sync_api import sync_playwright

ROUTES = [
    "iris",
    "iris_local",
    "text",
    "text_astra",
    "forecast",
    "forecast_astra",
    "threading",
    "threading_astra",
    "milp",
    "milp_astra",
]


class Robot:
    def __init__(self, page, route, output):
        self.page, self.route, self.output = page, route, output
        self.steps = []
        self.errors = []
        self.console_errors = []
        self.startup_probes = []
        self.healthy_endpoints = set()
        page.on("pageerror", lambda error: self.errors.append(str(error)))
        page.on(
            "console",
            lambda message: (
                self.console_errors.append(
                    {"message": message.text, "url": message.location.get("url", "")}
                )
                if message.type == "error"
                else None
            ),
        )
        page.on(
            "response",
            lambda response: (
                self.healthy_endpoints.add(response.url) if response.ok else None
            ),
        )

    def body(self):
        return self.page.locator("body").inner_text()

    def idle(self):
        # A result may render before Streamlit finishes the rerun. Opening a
        # select menu during that transition can close it before selection.
        for _ in range(2):
            self.page.wait_for_timeout(200)
            self.page.wait_for_function(
                "document.querySelector('[data-testid=stApp]')?.getAttribute('data-test-script-state') === 'notRunning'",
                timeout=210000,
            )

    def wait(self, predicate, timeout=60):
        deadline = time.monotonic() + timeout
        while True:
            exceptions = self.page.locator(
                '[data-testid="stException"]'
            ).all_inner_texts()
            assert not exceptions, exceptions
            if predicate():
                return
            alerts = self.page.locator('[data-testid="stAlert"]').all_inner_texts()
            fatal = [
                x
                for x in alerts
                if re.search(r"^(Run failed:|Benchmark failed:|Validation failed:)", x)
            ]
            assert not fatal, fatal
            if time.monotonic() > deadline:
                raise TimeoutError(
                    "Expected UI result did not appear; tail=" + self.body()[-1500:]
                )
            retry = self.page.get_by_role("button", name="Retry demo", exact=True)
            if retry.is_visible():
                retry.click()
            self.page.wait_for_timeout(350)

    def text(self, value, timeout=60):
        self.wait(lambda: value.casefold() in self.body().casefold(), timeout)

    def step(self, label, function):
        start = time.monotonic()
        (self.output / (self.route + "-progress.json")).write_text(
            json.dumps({"step": label, "completed": self.steps})
        )
        function()
        exceptions = self.page.locator('[data-testid="stException"]').all_inner_texts()
        assert not exceptions, exceptions
        self.steps.append(
            {
                "action": label,
                "seconds": round(time.monotonic() - start, 2),
                "status": "passed",
            }
        )
        self.page.screenshot(
            path=str(self.output / (self.route + "-" + str(len(self.steps)) + ".png")),
            full_page=True,
        )

    def click(self, label):
        self.idle()
        self.page.get_by_role("button", name=label, exact=True).click()
        self.idle()

    def tab(self, label):
        self.page.get_by_role("tab", name=label, exact=True).click()

    def select(self, label, option):
        self.idle()
        self.open_combo(self.page.get_by_role("combobox", name=label, exact=True))
        self.page.get_by_role("option", name=option, exact=True).click()
        self.idle()

    def open_combo(self, combo):
        # Streamlit's editable combobox may focus on its first click rather
        # than open. ArrowDown explicitly opens its accessible option list.
        combo.focus()
        combo.press("ArrowDown")
        self.page.get_by_role("option").first.wait_for()

    def download(self, label):
        with self.page.expect_download(timeout=30000) as event:
            self.page.get_by_role("button", name=label, exact=True).click()
        download = event.value
        assert download.failure() is None
        target = self.output / (self.route + "-" + download.suggested_filename)
        download.save_as(target)
        assert target.stat().st_size > 0
        return target

    def open(self):
        self.page.goto(
            "https://jpmorard-agilab.hf.space/AGENT_DEMO?demo="
            + self.route
            + "&embed=true",
            wait_until="domcontentloaded",
            timeout=60000,
        )
        marker = {"iris": "Predicted species", "iris_local": "Classify a Flower"}.get(
            self.route, "Run analysis"
        )
        self.text(marker)
        self.idle()

    def bundle(self):
        summary = self.page.locator("summary").filter(
            has_text=re.compile(
                "The request and the proof|Source.*(workflow|verification)"
            )
        )
        summary.first.click()
        button = self.page.get_by_role(
            "button",
            name=re.compile(
                r"Download.*(app and workflow|lab and workflow|generated app|workflow bundle|notebook app)"
            ),
        )
        self.wait(lambda: button.count() > 0)
        label = button.first.inner_text()
        target = self.download(label)
        with zipfile.ZipFile(target) as archive:
            assert archive.testzip() is None
            names = archive.namelist()
            report_name = next(n for n in names if n.endswith("result.json"))
            report = json.loads(archive.read(report_name))
            assert report["status"] == "passed"
            assert any(n.endswith("solution.ipynb") for n in names)
            for name, entry in report["files"].items():
                expected = entry.get("sha256") if isinstance(entry, dict) else entry
                if expected:
                    expected = expected.removeprefix("sha256:")
                    assert hashlib.sha256(archive.read(name)).hexdigest() == expected, (
                        name
                    )
        summary.first.click()

    def iris(self):
        local = self.route == "iris_local"
        if local:
            self.click("Predict")
            self.text("predicts: Iris setosa")
        else:
            self.text("setosa")
        for label, value in [
            ("Sepal length (cm)", "6.5"),
            ("Sepal width (cm)", "3.0"),
            ("Petal length (cm)", "6.0"),
            ("Petal width (cm)", "2.5"),
        ]:
            field = self.page.get_by_role(
                "spinbutton", name=re.compile(re.escape(label), re.IGNORECASE)
            )
            field.fill(value)
            field.press("Enter")
            self.idle()
        if local:
            self.click("Predict")
        self.text("virginica")
        label = "Classifier" if local else "Model to inspect and classify with"
        self.idle()
        self.open_combo(self.page.get_by_role("combobox", name=label, exact=True))
        options = self.page.get_by_role("option")
        options.first.wait_for()
        option = next(x for x in options.all_inner_texts() if "forest" in x.lower())
        self.page.get_by_role("option", name=option, exact=True).click()
        self.idle()
        if local:
            self.click("Predict")
        self.text("virginica")

    def text_atlas(self):
        self.click("Run analysis")
        self.text("Vocabulary size")
        articles = (
            self.page.locator('[data-testid="stMetric"]')
            .filter(has_text="Articles")
            .inner_text()
        )
        assert "1250" in articles.replace(",", "")
        category = self.page.get_by_role(
            "radio", name=re.compile("category", re.IGNORECASE)
        )
        category.focus()
        category.press("Space")
        self.idle()
        assert category.is_checked()
        self.page.wait_for_timeout(700)
        self.text("Vocabulary size")
        selector = self.page.get_by_role("combobox").last
        self.idle()
        self.open_combo(selector)
        self.page.get_by_role("option").nth(1).click()
        self.idle()
        self.text("Vocabulary size")
        slider = self.page.get_by_role("slider").first
        slider.focus()
        for _ in range(3):
            slider.press("ArrowLeft")
            self.page.wait_for_timeout(100)
        assert float(slider.input_value()) == 2
        self.click("Run analysis")
        self.wait(
            lambda: bool(re.search(r"n_clusters=2|2 clusters|clusters=2", self.body()))
        )

    def forecast(self):
        self.click("Run analysis")
        self.text("Seasonal-7 MAE")
        metrics = self.page.locator('[data-testid="stMetric"]').all_inner_texts()
        assert any("11.67" in m for m in metrics), metrics
        horizon_label = (
            "Forecast horizon (days)"
            if self.route.endswith("astra")
            else "Forecast horizon"
        )
        self.select(horizon_label, "14")
        seed_label = (
            "Synthetic data seed" if self.route.endswith("astra") else "Random seed"
        )
        field = self.page.get_by_role("spinbutton", name=seed_label, exact=True)
        field.fill("7")
        self.click("Run analysis")
        self.wait(
            lambda: (
                self.page.locator('[data-testid="stMetric"]').all_inner_texts()
                != metrics
            )
        )
        self.text("Seasonal-7 MAE")
        assert self.page.locator('[data-testid="stDataFrame"]').count() >= 1

    def threading(self):
        astra = self.route.endswith("astra")
        if astra:
            self.select("Repeats per case", "1")
        self.click("Run analysis")
        if astra:
            self.text("Same-work verified", timeout=210)
            target = self.download("Download JSON evidence")
            data = json.loads(target.read_text())
            assert data["same_work_verified"] is True
        else:
            self.text("Mean escape iterations")
            self.tab("Benchmark")
            self.click("Run benchmark")
            self.text("Same work verified:", timeout=210)
            self.tab("Inspect")
            self.wait(
                lambda: (
                    self.page.get_by_role(
                        "button", name="Download result JSON", exact=True
                    ).count()
                    > 0
                ),
                timeout=30,
            )
            target = self.download("Download result JSON")
            data = json.loads(target.read_text())
            assert data["same_work_verified"] is True
        assert len(data["runs"]) >= 3

    def milp(self):
        astra = self.route.endswith("astra")
        self.click("Run analysis")
        self.text("Modules installed" if not astra else "Horizon cost", timeout=90)
        self.wait(lambda: "21,879" in self.body() or "21879" in self.body())
        self.tab("Inspect")
        self.text("Committed settings" if not astra else "Open the model")
        self.tab("Compare")
        self.click("Save current scenario" if astra else "Keep scenario")
        self.page.wait_for_timeout(1000)
        assert self.page.locator('[data-testid="stDataFrame"]').count() >= 1
        self.tab("Scale")
        if not astra:
            self.select("Workers", "2")
        self.click("Run scaling experiment" if astra else "Run benchmark")
        self.text("Measured batch" if astra else "Sequential branch", timeout=210)
        self.tab("Experiment")
        field = self.page.get_by_role(
            "spinbutton", name="Maximum modules" if astra else "Max modules", exact=True
        )
        field.fill("1")
        self.click("Run analysis")
        self.text("infeasible", timeout=90)

    def run(self):
        self.step("open", self.open)
        function = (
            self.iris
            if self.route.startswith("iris")
            else self.text_atlas
            if self.route.startswith("text")
            else self.forecast
            if self.route.startswith("forecast")
            else self.threading
            if self.route.startswith("threading")
            else self.milp
        )
        self.step("compute, change controls and verify results", function)
        self.step("download and verify workflow bundle", self.bundle)
        self.page.set_viewport_size({"width": 390, "height": 844})
        self.page.wait_for_timeout(500)
        self.step("mobile render", self.mobile)
        self.step("browser console and connection", self.check_console)
        assert not self.errors, self.errors

    def check_console(self):
        # On a multipage deep link Streamlit probes the page path before
        # connecting at the root. Accept only those two 404 probes, and only
        # after proving the root endpoints and live connection are healthy.
        base = "https://jpmorard-agilab.hf.space"
        probes = {
            base + "/AGENT_DEMO/_stcore/" + name for name in ("health", "host-config")
        }
        for name in ("health", "host-config"):
            endpoint = base + "/_stcore/" + name
            # Reuse the successful browser bootstrap responses instead of
            # adding redundant health requests for every demo.
            assert endpoint in self.healthy_endpoints, endpoint
        assert (
            self.page.locator('[data-testid="stApp"]').get_attribute(
                "data-test-connection-state"
            )
            == "CONNECTED"
        )
        for error in self.console_errors:
            if error["url"] in probes and "404" in error["message"]:
                self.startup_probes.append(error)
            else:
                self.errors.append(error)

    def mobile(self):
        self.page.locator('[data-testid="stAppViewContainer"]').wait_for()
        assert self.page.evaluate(
            "document.documentElement.scrollWidth <= innerWidth + 2"
        ), "Page overflows mobile viewport"
        assert len(self.body()) > 500


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--routes", nargs="+", choices=ROUTES, default=ROUTES)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    reports = []
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(
            viewport={"width": 1440, "height": 1100}, accept_downloads=True
        )
        for route in args.routes:
            # Share the asset cache while retaining a fresh Streamlit session
            # in each page. New contexts per app needlessly stress the host.
            page = context.new_page()
            robot = Robot(page, route, args.output)
            start = time.monotonic()
            report = {"route": route}
            try:
                robot.run()
                report["status"] = "passed"
            except Exception as error:  # noqa: BLE001 - retain evidence and check the remaining apps
                report.update(
                    status="failed", error=str(error), traceback=traceback.format_exc()
                )
            report.update(
                steps=robot.steps,
                elapsed_seconds=round(time.monotonic() - start, 2),
                js_errors=robot.errors,
                startup_probes=robot.startup_probes,
                body=robot.body(),
            )
            (args.output / (route + "-robot.json")).write_text(
                json.dumps(report, indent=2)
            )
            page.screenshot(
                path=str(args.output / (route + "-final.png")), full_page=True
            )
            print(
                json.dumps({k: v for k, v in report.items() if k != "body"}), flush=True
            )
            reports.append(report)
            page.close()
        context.close()
        browser.close()
    (args.output / "robot.json").write_text(json.dumps(reports, indent=2))
    return 1 if any(r["status"] != "passed" for r in reports) else 0


if __name__ == "__main__":
    raise SystemExit(main())
