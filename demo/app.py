"""Public Iris example interface. This contains no private Tokki runtime."""
from __future__ import annotations

import hashlib
import importlib.util
import json
import subprocess
import sys
import tempfile
import threading
import zipfile
from functools import lru_cache
from pathlib import Path

import gradio as gr
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.metrics import ConfusionMatrixDisplay

HERE = Path(__file__).resolve().parent
ARTIFACTS = HERE / "artifacts"
ARTIFACT_NAMES = {"app.py", "models.py", "solution.ipynb", "lab_stages.toml"}
MODEL_NAMES = ["Decision tree", "Random forest", "Logistic regression"]
_PLOT_LOCK = threading.Lock()
_VERIFY_LOCK = threading.Lock()


def checked_report():
    report = json.loads((ARTIFACTS / "result.json").read_text())
    if report.get("status") != "passed" or set(report.get("files", {})) != ARTIFACT_NAMES:
        raise ValueError("The complete public verification report is required")
    for name, expected in report["files"].items():
        path = ARTIFACTS / name
        if path.is_symlink() or hashlib.sha256(path.read_bytes()).hexdigest() != expected:
            raise ValueError("A public artifact changed after verification")
    return report


@lru_cache(maxsize=10)
def experiment(depth):
    checked_report()
    spec = importlib.util.spec_from_file_location("public_iris_models", ARTIFACTS / "models.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    iris, x_train, x_test, y_train, y_test = module.load_split()
    models = module.train_models(x_train, y_train, max_depth=depth)
    scores, predictions = module.evaluate_models(models, x_train, x_test, y_train, y_test)
    return iris, x_train, x_test, y_test, models, scores, predictions


def analyse(depth, selected, sepal_length, sepal_width, petal_length, petal_width):
    checked_report()
    try:
        depth = float(depth)
        measurements = np.asarray([sepal_length, sepal_width, petal_length, petal_width], dtype=float)
    except (TypeError, ValueError) as exc:
        raise gr.Error("Enter a numeric depth and four numeric measurements.") from exc
    if not np.isfinite(depth) or int(depth) != depth or not 1 <= depth <= 10:
        raise gr.Error("Choose a tree depth from 1 to 10.")
    if selected not in MODEL_NAMES or not np.isfinite(measurements).all() or (measurements < .1).any() or (measurements > 20).any():
        raise gr.Error("Choose a listed model and four finite measurements between 0.1 and 20 cm.")
    iris, x_train, x_test, y_test, models, scores, predictions = experiment(int(depth))
    flower = pd.DataFrame([measurements], columns=iris.feature_names)
    model = models[selected]
    probabilities = model.predict_proba(flower)[0]
    species = iris.target_names[int(model.predict(flower)[0])]
    predicted = predictions[selected]
    wrong = predicted != y_test.to_numpy()
    error_count = int(wrong.sum())
    error_label = "error" if error_count == 1 else "errors"
    summary = f"### Predicted species: **{species}**\n{selected} · {error_count} {error_label} on 45 held-out flowers."
    if ((flower.iloc[0] < x_train.min()) | (flower.iloc[0] > x_train.max())).any():
        summary += "\n\nThese measurements extend beyond the observed training range; this prediction is an extrapolation."
    errors = x_test.loc[wrong].copy()
    errors.insert(0, "sample_id", errors.index)
    errors["actual"] = iris.target_names[y_test.to_numpy()[wrong]]
    errors["predicted"] = iris.target_names[predicted[wrong]]
    with _PLOT_LOCK:
        confusion, ax = plt.subplots(figsize=(5.5, 4))
        ConfusionMatrixDisplay.from_predictions(y_test, predicted, labels=[0, 1, 2],
            display_labels=iris.target_names, cmap="Blues", colorbar=False, ax=ax)
        confusion.tight_layout()
        plt.close(confusion)
        petals, ax = plt.subplots(figsize=(5.5, 4))
        for category, color in enumerate(["#247b7b", "#5966ba", "#d08725"]):
            mask = y_test.to_numpy() == category
            ax.scatter(x_test.iloc[mask, 2], x_test.iloc[mask, 3], color=color,
                       label=iris.target_names[category], alpha=.8)
        if wrong.any():
            ax.scatter(x_test.iloc[wrong, 2], x_test.iloc[wrong, 3], s=180,
                       facecolors="none", edgecolors="#b42318", label="Misclassified")
        ax.set(xlabel="Petal length (cm)", ylabel="Petal width (cm)")
        ax.legend()
        petals.tight_layout()
        plt.close(petals)
    probabilities = pd.DataFrame({"species": iris.target_names[model.classes_], "model probability": probabilities})
    return summary, scores, confusion, petals, errors, probabilities


def verify_original():
    checked_report()
    with _VERIFY_LOCK:
        try:
            result = subprocess.run([sys.executable, str(HERE / "notebook_verifier.py")],
                cwd=ARTIFACTS, capture_output=True, text=True, timeout=180, check=False)
            report = json.loads(result.stdout.strip().splitlines()[-1])
        except (OSError, subprocess.TimeoutExpired, ValueError, IndexError):
            return "Verification could not complete in this environment."
    if result.returncode == 0 and report.get("status") == "passed":
        return "**Passed:** the original model, notebook and Streamlit app checks passed in this Space."
    return "Verification did not pass in this environment."


@lru_cache(maxsize=1)
def download_bundle():
    checked_report()
    bundle = Path(tempfile.mkdtemp(prefix="public-notebook-demo-")) / "verified-notebook-app.zip"
    with zipfile.ZipFile(bundle, "w", zipfile.ZIP_DEFLATED) as archive:
        for name in sorted(ARTIFACT_NAMES | {"LICENSE", "result.json"}):
            archive.write(ARTIFACTS / name, name)
    return str(bundle)


def build_interface():
    report = checked_report()
    with gr.Blocks(title="Tokki · Notebook to working app", analytics_enabled=False) as interface:
        gr.Markdown("# Tokki · From one request to a working app\n"
            "Tokki coordinated an autonomous agent and verification; AGILAB imported the resulting workflow. "
            "Try the completed result below. **No AI provider subscription is needed.**")
        gr.Markdown(f"**Original build: {report['seconds'] / 60:.2f} min · 3 models · {report['workflow_stages']} workflow stages**\n\n"
            "This public Gradio interface uses the verified model code. The original generated notebook, "
            "Streamlit app and workflow are downloadable. New autonomous builds run locally with your own provider.")
        with gr.Accordion("Build from your own notebook", open=False):
            gr.Markdown("Set up your licensed [Tokki installation](https://github.com/jpmorard/tokki-public/blob/main/RELEASES.md) "
                "and your own Codex provider, then install [uv](https://docs.astral.sh/uv/getting-started/installation/).\n\n"
                '```bash\nuv tool install "agilab[notebook-agent] @ git+https://github.com/ThalesGroup/agilab.git"\nagilab-notebook-demo --ui\n```\n'
                "Choose **Local notebook** or **Pinned GitHub notebook**. Start with self-contained Python and locally available data/dependencies. "
                "The local agent can read the selected notebook and executes generated Python on your computer. "
                "Checks establish execution and interface behavior; review scientific conclusions yourself.\n\n"
                "After a successful build, you may choose to share a completion receipt on GitHub. It excludes notebook contents, "
                "prompts, paths and credentials. Nothing is submitted automatically; public reports are associated with your GitHub account.")
        gr.Markdown("## Compare models and classify a flower\nAdjust the controls, then update the result.")
        with gr.Row():
            depth = gr.Slider(1, 10, value=3, step=1, label="Maximum tree depth")
            selected = gr.Dropdown(MODEL_NAMES, value=MODEL_NAMES[0], label="Model to inspect and classify with")
        with gr.Row():
            measurements = [gr.Number(value=value, minimum=.1, maximum=20, label=label)
                for label, value in zip(["Sepal length (cm)", "Sepal width (cm)", "Petal length (cm)", "Petal width (cm)"], [5.1, 3.5, 1.4, .2])]
        update = gr.Button("Update model and prediction", variant="primary")
        summary = gr.Markdown()
        scores = gr.Dataframe(label="Held-out model comparison", interactive=False)
        with gr.Row():
            confusion = gr.Plot(label="Confusion matrix · held-out flowers")
            petals = gr.Plot(label="Petal measurements · held-out flowers")
        errors = gr.Dataframe(label="Inspect classification errors", interactive=False)
        probabilities = gr.Dataframe(label="Model probabilities", interactive=False)
        gr.Markdown("Same stratified 70/30 split for all models; seed 42. All four features are used and scaling is learned only from training rows. "
            "Changing depth after inspecting the test scores makes this an exploratory comparison. Model probabilities are estimates, not validated confidence.")
        with gr.Accordion("The original request and verification evidence", open=False):
            gr.Markdown("> Turn the Iris decision-tree example into an interactive decision lab. Compare a decision tree, random forest and logistic regression "
                "on a held-out split. Let me change tree depth, inspect errors and classify a flower.\n\n"
                f"Source: [Aurélien Géron's pinned notebook]({report['source']['url']}) · Apache-2.0. "
                "Verification re-executes only the fixed public artifacts, with no agent provider or private Tokki runtime.")
            gr.File(value=download_bundle(), label="Download the verified app and workflow", interactive=False)
            verify = gr.Button("Run original model, notebook and app checks")
            status = gr.Markdown()
            verify.click(verify_original, outputs=status, api_name="verify_original", concurrency_limit=1)
        inputs = [depth, selected, *measurements]
        outputs = [summary, scores, confusion, petals, errors, probabilities]
        update.click(analyse, inputs=inputs, outputs=outputs, api_name="predict", concurrency_limit=1)
        interface.load(analyse, inputs=inputs, outputs=outputs, api_name=False)
        gr.Markdown("[Tokki public overview](https://github.com/jpmorard/tokki-public) · [AGILAB](https://github.com/ThalesGroup/agilab)")
    return interface


if __name__ == "__main__":
    build_interface().launch()
