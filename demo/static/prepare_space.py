"""Prepare only the public assets, with a versioned Hugging Face entry page."""

import argparse
import hashlib
import json
from pathlib import Path


def prepare_space(source: Path, output: Path) -> dict:
    html = (source / "index.html").read_bytes()
    digest = hashlib.sha256(html).hexdigest()
    entrypoint = f"index-{digest[:16]}.html"
    readme = (source / "README.md").read_text(encoding="utf-8")
    parts = readme.split("---", 2)
    if len(parts) != 3 or parts[0].strip():
        raise ValueError("README.md must start with YAML front matter")
    marker = "\napp_file: index.html\n"
    if parts[1].count(marker) != 1 or "\nsdk: static\n" not in parts[1]:
        raise ValueError("Expected the static source entrypoint index.html")
    parts[1] = parts[1].replace(marker, f"\napp_file: {entrypoint}\n")
    payloads = {
        "README.md": "---".join(parts).encode("utf-8"),
        "LICENSE": (source / "LICENSE").read_bytes(),
        "index.html": html,
        entrypoint: html,
    }
    if output.exists() and (not output.is_dir() or any(output.iterdir())):
        raise ValueError("Choose an empty output directory")
    output.mkdir(parents=True, exist_ok=True)
    for name, data in payloads.items():
        (output / name).write_bytes(data)
    return {
        "entrypoint": entrypoint,
        "sha256": {
            name: hashlib.sha256(data).hexdigest()
            for name, data in payloads.items()
        },
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    result = prepare_space(Path(__file__).resolve().parent, args.output)
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
