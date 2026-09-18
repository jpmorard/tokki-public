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

# Tokki · From one request to a working app

Explore **Chronos-2 Small forecasting** through Tokki and AGILAB.
The workflow starts with an official forecasting notebook, uses Tokki to
coordinate the agent build, and presents the generated app and its recorded
checks in AGILAB. No AI provider subscription is needed to try the public demo.

- [Open the Chronos forecast app](https://jpmorard-agilab.hf.space/AGENT_DEMO?demo=forecast&embed=true)
- [Open the original Iris demo](https://jpmorard-agilab.hf.space/AGENT_DEMO?demo=iris&embed=true)

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
