# Host a Website on Amazon S3

A GitHub-ready, reproducible version of Richard Lutendo Mudau's NextWork project. It includes a lightweight static website, Terraform deployment, bucket policies, a validation script, CI, troubleshooting notes, and the original project PDF/screenshots.

> **Security & privacy:** This repo is packaged for **Private** GitHub visibility by default. The source PDF and screenshot `01-bucket-created.png` show an AWS account ID and email address. The S3 website itself is intentionally public when deployed. Do not put secrets, personal data, or private files in the website bucket.

## What the project demonstrates

- Create an S3 bucket in **Europe (Stockholm), `eu-north-1`**.
- Upload a static `index.html` and `error.html`.
- Enable S3 static website hosting.
- Make objects readable from the website endpoint with a bucket policy (not object ACLs).
- Deny deletion of `index.html` as the project extension.
- Verify the website and policies locally, then deploy with Terraform.

The PDF records the bucket name `nextwork-website-project-mluthos`. It may already be taken (and S3 bucket names are globally unique), so **choose a new, globally unique name** in `terraform/terraform.tfvars` when deploying. The policy is generated from the bucket Terraform creates, so it follows your selected name automatically.

## Repository layout

```text
website/                  Static site files deployed to S3
terraform/                S3 bucket, website config, policies, object upload
aws/                      Console-policy examples with bucket-name placeholders
scripts/validate-website.py  Local HTML/policy checks; no AWS account needed
docs/                     Original NextWork PDF, screenshots, security/troubleshooting
.github/workflows/        CI checks (no AWS credentials required)
PUSH-TO-GITHUB.md         Windows PowerShell steps to create and push the repo
```

## Run local checks

Requires Python 3.10+; no AWS account or credentials needed:

```bash
python3 scripts/validate-website.py
python3 -m json.tool aws/bucket-policy-public-read.json > /dev/null
python3 -m json.tool aws/bucket-policy-deny-delete-index.json > /dev/null
```

Open `website/index.html` directly in a browser for a local preview. The email field is a front-end demo only; it does not collect or send data.

The JSON files under `aws/` are console-policy examples: replace `<YOUR_BUCKET_NAME>` before applying either one manually. Terraform generates the policies with the actual bucket ARN, so no manual ARN edit is needed for the Terraform deployment.

## Deploy to AWS with Terraform

### Before you start

- An AWS account and permission to create S3 buckets, bucket policies, website configuration, and objects.
- Terraform 1.9+ and AWS CLI installed.
- AWS credentials configured locally (prefer AWS IAM Identity Center/SSO). **Never commit credentials, paste them into chat, or store them in this repo.**
- A globally unique S3 bucket name that meets AWS naming rules.

### Configure and deploy

From the repository root:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set a globally unique `bucket_name` (for example, add a random suffix you choose). Then run:

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

Review the plan before approving `apply`. This project intentionally enables public website reads for the bucket's objects. Terraform configures **bucket-level** Block Public Access to allow the public-read bucket policy while keeping public ACLs disabled. An AWS account- or organization-level public-access block can still prevent this deployment; don't weaken those account-level guardrails just to make the tutorial work.

The website endpoint is printed as `website_endpoint` after apply. S3 static website endpoints use **HTTP only**; for a production website with HTTPS, use CloudFront in front of a private S3 bucket instead.

### Remove the AWS resources when finished

From `terraform/`:

```bash
terraform destroy
```

The policy is configured to be removed before Terraform-managed site objects during destroy, so the deny-delete demonstration does not block cleanup. If you manually uploaded extra files that Terraform does not manage, remove those first; S3 will not delete a non-empty bucket. Check the plan carefully before confirming destroy.

## Notes on the tutorial's 403 fix

A bucket website endpoint can return **403 AccessDenied** when the site objects are not publicly readable, even if static website hosting is enabled. This repo uses a bucket policy granting only `s3:GetObject` to website objects; it does not enable public ACLs. Never fix this by making unrelated buckets or account data public.

## Original project evidence

The report and selected screenshots are preserved under [`docs/`](docs/). For the source-reported details and the screenshot identifying account information, keep this GitHub repo private. If you choose to make the repo public, first remove or redact the original PDF and account-identifying screenshot, then review every remaining file.

## License

The original code and configuration are provided under the MIT License. The NextWork PDF, marks, and any source-project material remain subject to their respective owners' rights; see [`docs/THIRD-PARTY-NOTICES.md`](docs/THIRD-PARTY-NOTICES.md).
