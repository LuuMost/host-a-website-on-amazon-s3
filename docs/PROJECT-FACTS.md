# Source project facts

Extracted from Richard Lutendo Mudau's 13-page NextWork project report and screenshots:

- Project: Host a Website on Amazon S3; estimated time approximately 1.5 hours.
- Region shown: Europe (Stockholm), `eu-north-1`.
- Bucket shown: `nextwork-website-project-mluthos` (a screenshot shows this bucket in the user's account; do not assume it is available to create again).
- Website index document: `index.html`.
- Original uploaded objects shown: `index.html` and a folder of images/assets named `nextWork-Everyone should be in a job they love/`.
- The report describes enabling static website hosting, resolving an initial 403 by making objects readable, and an extension that denies deletion of `index.html` with a bucket policy.
- The included source PDF and `01-bucket-created.png` contain an AWS account ID and email; keep them private or redact them before public sharing.

This repo recreates the static page for demonstration and supplies a modern, Terraform-managed deployment. The original website source/assets were not included in the PDF attachment, so the HTML here is a new, lightweight implementation rather than a copy of the original.
