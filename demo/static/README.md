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

Explore four build-agent apps through Tokki and AGILAB: **Free-threading lab**,
the original Iris classifier, **Chronos-2 Small forecasting**, and an
**INRIA Text Atlas** built from TF-IDF, dimensionality reduction and clustering. No AI provider
subscription is needed to try the public demos.

- [Open the free-threading lab](https://jpmorard-agilab.hf.space/AGENT_DEMO?demo=threading&embed=true)
- [Open the INRIA text atlas](https://jpmorard-agilab.hf.space/AGENT_DEMO?demo=text&embed=true)
- [Open the Chronos forecast app](https://jpmorard-agilab.hf.space/AGENT_DEMO?demo=forecast&embed=true)
- [Open the original Iris demo](https://jpmorard-agilab.hf.space/AGENT_DEMO?demo=iris&embed=true)

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
without JavaScript. Add `?demo=threading`, `?demo=text`, `?demo=forecast` or `?demo=iris` to the
static page URL to share a particular demo.

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
