---
title: Tokki
emoji: 🐢
colorFrom: yellow
colorTo: pink
sdk: gradio
sdk_version: 6.28.0
python_version: '3.12'
app_file: app.py
pinned: false
license: bsd-3-clause
short_description: Agentic solution
---

# Tokki · From one request to a working app

Try a real notebook-to-app result built through Tokki's autonomous agent workflow
with AGILAB. No account or AI provider subscription is needed to try this public
example.

The Gradio interface runs the verified public Iris model code on CPU. The original
generated Streamlit app, notebook, workflow and verification evidence are included.
Use **Run original model, notebook and app checks** to verify them again here.

## Public-only contents

This demo contains the public interface, fixed AGILAB example artifacts and
verifier, dependency requirements and licenses. It contains no private Tokki
source, runtime, license key, credentials, session logs or user notebook inputs.
The UI adapter is distinct from Tokki's private orchestration runtime.

[Build from your own notebook](https://github.com/ThalesGroup/agilab#build-from-your-own-notebook)
with your own local Tokki installation and provider. Successful builders may
voluntarily share a content-free completion receipt; nothing is submitted
automatically.

The Gradio page needs no GPU callbacks, model downloads or secrets. It preserves
this Space's existing Gradio/ZeroGPU configuration.

## Source and licenses

- [Tokki public overview and releases](https://github.com/jpmorard/tokki-public).
- [AGILAB](https://github.com/ThalesGroup/agilab); copied verifier retains the
  BSD-3-Clause notice in `LICENSE-AGILAB`.
- The Iris example adapts Aurélien Géron's
  [pinned handson-ml3 notebook](https://github.com/ageron/handson-ml3/blob/e707c2d659abafb9b1f9fd927907619a128db8d7/06_decision_trees.ipynb).
  Its Apache-2.0 license is preserved in `artifacts/LICENSE`.

To run this public example locally:

```bash
uv run --with-requirements demo/requirements.txt python demo/app.py
```
