#!/usr/bin/env python3
"""Offline checks for the static website and example S3 bucket policies.

No AWS account, credentials, third-party package, or network access required.
Run from any directory: python3 scripts/validate-website.py
"""
import json
from html.parser import HTMLParser
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


class TagCollector(HTMLParser):
    def __init__(self):
        super().__init__()
        self.tags = []

    def handle_starttag(self, tag, attrs):
        self.tags.append(tag)


def load_json(relative_path, errors):
    path = ROOT / relative_path
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        errors.append(f"{relative_path} could not be read as JSON: {exc}")
        return {}


def main() -> int:
    errors = []

    for filename in ("index.html", "error.html"):
        path = ROOT / "website" / filename
        if not path.is_file():
            errors.append(f"Missing website/{filename}")
            continue
        parser = TagCollector()
        try:
            parser.feed(path.read_text(encoding="utf-8"))
            parser.close()
        except Exception as exc:  # HTMLParser errors are reported as validation failures.
            errors.append(f"website/{filename} could not be parsed: {exc}")
        if "html" not in parser.tags:
            errors.append(f"website/{filename} is missing its <html> element")

    index_path = ROOT / "website" / "index.html"
    if index_path.is_file():
        index = index_path.read_text(encoding="utf-8").lower()
        for required in ("<title>", "job they love", "aws certifications"):
            if required not in index:
                errors.append(f"website/index.html is missing expected content: {required}")

    public = load_json("aws/bucket-policy-public-read.json", errors)
    public_statements = public.get("Statement", [])
    if not isinstance(public_statements, list) or len(public_statements) != 1:
        errors.append("Public-read example should contain exactly one statement")
    else:
        statement = public_statements[0]
        if statement.get("Effect") != "Allow" or statement.get("Action") != "s3:GetObject":
            errors.append("Public-read example must allow only s3:GetObject")
        if statement.get("Principal") != "*":
            errors.append("Public-read example should use Principal '*'")
        if not str(statement.get("Resource", "")).endswith("/*"):
            errors.append("Public-read example should target objects in the bucket")

    deny = load_json("aws/bucket-policy-deny-delete-index.json", errors)
    deny_statements = deny.get("Statement", [])
    if not isinstance(deny_statements, list) or len(deny_statements) != 1:
        errors.append("Deny-delete example should contain exactly one statement")
    else:
        statement = deny_statements[0]
        if statement.get("Effect") != "Deny" or statement.get("Action") != "s3:DeleteObject":
            errors.append("Deny-delete example must deny s3:DeleteObject")
        if not str(statement.get("Resource", "")).endswith("/index.html"):
            errors.append("Deny-delete example must target index.html")

    if errors:
        print("FAIL")
        for error in errors:
            print(f"  - {error}")
        return 1

    print("OK: website HTML and both S3 policy examples passed validation.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
