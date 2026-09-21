---
title: Tokki
emoji: 🐢
colorFrom: yellow
colorTo: pink
sdk: static
app_file: index.html
pinned: false
license: bsd-3-clause
short_description: Agentic solution
---

# Tokki · From notebooks to working apps

The [Tokki Space](https://huggingface.co/spaces/jpmorard/tokki) offers **five apps in two flavours each: GPT-6 Astra and local Qwen 3.8**.
Text Atlas opens by default. Each app's Astra and Qwen cards appear together.
No AI provider subscription is needed to try these ten completed builds.

Each launch card highlights its recorded elapsed build time, rounded to the nearest second. These times include repairs, validation and any waiting time. They describe one recorded run per build with differing scopes, not a controlled model-speed benchmark. The values come from the [published build receipts](https://huggingface.co/spaces/jpmorard/agilab/tree/61500142c9e143f8e222cf25f7b0e50f2a12db68/src/agilab/resources).

| App | Original GPT-6 Astra build | Local Qwen 3.8 build |
| --- | --- | --- |
| Text atlas | [Astra · 7 min 44 s](https://jpmorard-agilab.hf.space/AGENT_DEMO?demo=text_astra&embed=true) | [Qwen · 20 min 08 s](https://jpmorard-agilab.hf.space/AGENT_DEMO?demo=text&embed=true) |
| Demand forecast | [Astra · 6 min 01 s](https://jpmorard-agilab.hf.space/AGENT_DEMO?demo=forecast_astra&embed=true) | [Qwen · 1 h 29 min 22 s](https://jpmorard-agilab.hf.space/AGENT_DEMO?demo=forecast&embed=true) |
| MILP Energy Lab | [Astra · 24 min 00 s](https://jpmorard-agilab.hf.space/AGENT_DEMO?demo=milp_astra&embed=true) | [Qwen · 4 h 25 min 00 s](https://jpmorard-agilab.hf.space/AGENT_DEMO?demo=milp&embed=true) |
| Free-threading lab | [Astra · 12 min 31 s](https://jpmorard-agilab.hf.space/AGENT_DEMO?demo=threading_astra&embed=true) | [Qwen · 4 h 27 min 47 s](https://jpmorard-agilab.hf.space/AGENT_DEMO?demo=threading&embed=true) |
| Iris decision lab | [Astra · 4 min 45 s](https://jpmorard-agilab.hf.space/AGENT_DEMO?demo=iris&embed=true) | [Qwen · 34 min 09 s](https://jpmorard-agilab.hf.space/AGENT_DEMO?demo=iris_local&embed=true) |

The MILP Energy Lab adapts PyPSA contributors'
[Modular Expansion with Unit Commitment notebook](https://github.com/PyPSA/PyPSA/blob/c838aa498557cc8e27a9d3ed10d45e35c4b0b442/docs/examples/modular-committable.ipynb),
introduced on 17 February 2026 and updated on 5 August 2026 for matplotlib compatibility.
The notebook, including its code, is **CC BY 4.0**; the PyPSA library is MIT licensed.
The agent-built adaptation adds interactive energy experiments, the open-source HiGHS
solver, configurable scenarios, solution checks, and AGILAB batch measurements.
Visitors can inspect capacity and dispatch, compare saved scenarios, and reproduce results.
Scaling compares independent scenarios through the unchanged AGILAB pool engine on
the Space's available CPUs, with one solver thread per scenario. Measurements include
startup costs and may show slower parallel runs. They do not prove distributed scaling
or acceleration of an individual MILP. Original source, attribution, licenses, and
the generated workflow are included in the lab download.

The free-threading lab starts from an original AGILAB notebook created on
19 September 2026. A real build-agent run produces its app and imported workflow.
It uses an unchanged, hash-bound AGILAB pool engine to render identical fractals
with GIL-on threads, GIL-off threads, and spawned processes. All three use the
same free-threaded Python build. The app measures repeated runs on its actual CPU
allowance, verifies image hashes, and exposes recorded worker activity. This is
local CPU scaling evidence; it does not certify the whole AGILAB dependency stack
for free-threaded Python or demonstrate multi-machine scaling.

The text atlas source is INRIA's
[dimred_text notebook](https://github.com/INRIA/scikit-learn-mooc/blob/3d1e8cdf7df6675d8a47d352d66b29dfea36587c/notebooks/dimred_text.ipynb),
pinned at `3d1e8cdf7df6675d8a47d352d66b29dfea36587c` and released under
CC-BY-4.0. The lesson was introduced on 5 August 2026 and this notebook version
was updated on 2 September 2026. The bundled historical `wiki_news.csv` corpus
has its own **CC-BY-2.5** license: Wikinews contributors, curated by The Mega
Rhyme Rhyming Dictionary and subsampled by INRIA. The app reports vocabulary,
projection variance and a silhouette diagnostic; clusters are exploratory.

Select a demo card to switch the embedded app. Direct links remain usable
without JavaScript. Use the same `demo` parameter on the static page URL to share a particular build; for example, `?demo=milp_astra` or `?demo=milp`.

The forecasting source is Amazon Science's
[Chronos-2 quickstart notebook](https://github.com/amazon-science/chronos-forecasting/blob/10afa9ebe016e514f9d7dc1aa873f66af57e116b/notebooks/chronos-2-quickstart.ipynb),
pinned at `10afa9ebe016e514f9d7dc1aa873f66af57e116b`.
The app adapts it to use the Apache-2.0-licensed
[autogluon/chronos-2-small model](https://huggingface.co/autogluon/chronos-2-small).
The embedded app exposes the source, model and verification evidence; its
receipt states the checks performed and their scope.

This free static Space embeds the working app from the existing
[AGILAB Space](https://huggingface.co/spaces/jpmorard/agilab).
New autonomous builds run locally with your own Tokki installation and provider.

Only this public page, README and license are deployed here.
There is no private Tokki source, runtime, license key, agent log, provider
credential or user notebook in this Space.

- [Build from your own notebook](https://github.com/ThalesGroup/agilab#build-from-your-own-notebook)
- [Public page source](https://github.com/jpmorard/tokki-public/tree/main/demo/static)
- [Tokki public overview](https://github.com/jpmorard/tokki-public)

The repository also includes an optional native Gradio version under demo/.
That CPU version can run locally or on hosting with CPU support; it is not
the runtime used by this static Space.

## Models used

The **build model** generated the application. The **app model or algorithm** runs when a visitor uses the completed demo.

| Demo | Build model | App model or algorithm |
| --- | --- | --- |
| Iris decision lab · original | GPT-6 Astra (`gpt-6-astra`, OpenAI) | Decision tree, random forest and logistic regression |
| Iris decision lab · local | Qwen 3.8 27B (`ddalcu/Qwen3.8-27B-MLX-Serve-4bit`, local MLX) | Decision tree, random forest and logistic regression |
| Text atlas · original | GPT-6 Astra (`gpt-6-astra`, OpenAI) | TF-IDF, dimensionality reduction and clustering |
| Text atlas · local | Qwen 3.8 27B (`ddalcu/Qwen3.8-27B-MLX-Serve-4bit`, local MLX) | TF-IDF, dimensionality reduction and clustering |
| Demand forecast · original | GPT-6 Astra (`gpt-6-astra`, OpenAI) | autogluon/chronos-2-small |
| Demand forecast · local | Qwen 3.8 27B (`ddalcu/Qwen3.8-27B-MLX-Serve-4bit`, local MLX) | autogluon/chronos-2-small |
| Free-threading lab · original | GPT-6 Astra (`gpt-6-astra`, OpenAI) | Mandelbrot benchmark; no inference model |
| Free-threading lab · local | Qwen 3.8 27B (`ddalcu/Qwen3.8-27B-MLX-Serve-4bit`, local MLX) | Mandelbrot benchmark; no inference model |
| MILP Energy Lab · original | GPT-6 Astra (`gpt-6-astra`, OpenAI) | PyPSA and HiGHS optimization; no inference model |
| MILP Energy Lab · local | Qwen 3.8 27B (`ddalcu/Qwen3.8-27B-MLX-Serve-4bit`, local MLX) | PyPSA and HiGHS optimization; no inference model |

The local Iris application Python was generated and repaired by local MLX `ddalcu/Qwen3.8-27B-MLX-Serve-4bit` (4-bit), without cloud code-generation fallback. A coordinating assistant prepared requests, ran independent checks and reviewed the outputs. The local model produced the complete application files and a bounded repair. Generation used the native local MLX API; Tokki wrapped the commands, but these calls were not routed through Tokki offloading. This describes local application code generation, not fully offline coordination. The [build receipt](https://huggingface.co/spaces/jpmorard/agilab/blob/d6d4cf41ad40c917c7f792d544b59157fd198fc6/src/agilab/resources/notebook_agent_local_demo/result.json) records the model revision and validation.

All five original GPT-6 Astra build-model identities were checked against their original native run headers. Their downloadable app files and receipts are preserved byte for byte; Astra attribution is displayed separately from the historical receipts. The public apps do not call their build provider when visitors use them.

Text Atlas was also rebuilt with the same local Qwen3.8 model, without cloud code-generation fallback. Its application Python and notebook cells came from the local model; a coordinating assistant integrated the bundle and ran independent checks. Generation used the native local API and is not claimed as a Tokki agent offload. The verified build took **20.14 minutes**, including notebook, workflow, numerical and interface checks; local inference took 935.18 seconds. The pinned source notebook, 1,250-article corpus and licenses are preserved. Its [build receipt](https://github.com/ThalesGroup/agilab/blob/46dc6690457a8bc606352cbb0e19aeb083781965/src/agilab/resources/text_notebook_demo/result.json) records the exact model revisions and verification scope.

Demand Forecast was also rebuilt with local Qwen 3.8 27B, with no cloud code-generation fallback. The application runs the pinned Chronos-2-small checkpoint locally. Its receipt includes exact build-model revisions, measured build duration, notebook and workflow replay, and independent real-inference checks across three seeds. Both flavours of all five apps are preserved.

## Browser validation

**21 September 2026: all 10 variants passed all 50 browser checks.**
The [dated validation report](https://github.com/jpmorard/tokki-public/blob/main/demo/validation/2026-09-21.json)
records the deployed app revision, actions, timings and browser diagnostics.
No application-code correction was required.

The [live UI robot](https://github.com/jpmorard/tokki-public/blob/main/demo/validate_live_apps.py)
checks all ten published variants in Chromium. It runs analyses, changes inputs,
checks predictions and numerical results, exercises CPU and MILP scaling,
downloads every workflow bundle and verifies its recorded file hashes, and
checks mobile rendering and browser errors. Streamlit's two page-path startup
probes are recorded separately only after the root endpoints and live connection
pass their health checks.

From the repository root, with Playwright and its Chromium browser installed:

    python demo/validate_live_apps.py --output /tmp/tokki-live-ui-validation

The robot saves screenshots and JSON evidence and exits unsuccessfully if any
variant fails. Use `--routes` to rerun specific variants.

## Publishing the static Space

Prepare a fresh, empty staging directory with:

    python3 demo/static/prepare_space.py --output /tmp/tokki-space-staging

Upload only the resulting four files to jpmorard/tokki. The preparation script
copies the public page and license and sets the deployed README's app_file to
a filename derived from the page's SHA-256. A changed page therefore gets a new
embedded URL when the Space is reloaded. The source README remains a template;
do not upload it directly. The stable index.html copy keeps existing direct
links working. The public Space URL remains
https://huggingface.co/spaces/jpmorard/tokki.

Free-threading was rebuilt and repaired with local Qwen 3.8 27B, with no cloud code-generation fallback. Its application Python, bundled tests, and notebook cells are local-model output. Independent checks verified actual GIL state, identical image digests across all three execution modes, worker identities, repeated timings, process cleanup, and fresh notebook/workflow replay. The original notebook and AGILAB pool engine are unchanged. The recorded build duration includes repairs and intervening validation work; it is not inference time alone.

MILP Energy Lab was rebuilt and repaired with the same local Qwen model. Independent checks cover the reference objective of 21879 and 30 modules, infeasibility without a false incumbent, load shedding, solar/startup constraints and costs, and identical scenario batches executed through the real AGILAB process pool with overlapping workers. Its downloadable receipt records notebook/workflow agreement and exact model revisions. Both flavours of all five apps remain available.
