# Push this project to GitHub — Windows PowerShell

> **Keep this repository Private.** The attached PDF and screenshot `docs/screenshots/01-bucket-created.png` show an AWS account ID and email. The S3 website can be public without making this source/evidence repository public.

## 1. Download and unzip

Download `host-a-website-on-amazon-s3.zip`, then right-click it in Downloads → **Extract All**. You should have a folder named `host-a-website-on-amazon-s3`.

## 2. Install GitHub CLI (once only)

In PowerShell:

```powershell
winget install --id GitHub.cli
```

Close PowerShell completely and open a new PowerShell window, then verify:

```powershell
gh --version
git --version
```

## 3. Go to the extracted folder

```powershell
cd "$env:USERPROFILE\Downloads\host-a-website-on-amazon-s3"
dir
```

Check that `README.md`, `website`, `terraform`, `docs`, and `.github` are present.

## 4. Initialize Git and make the first commit

The downloadable ZIP intentionally excludes `.git`, so create the local Git repository first:

```powershell
git init
git branch -M main
git add -A
git status --short
git commit -m "Host a Website on Amazon S3 project"
```

If Git says your name or email is not configured, set them for this repo and retry the commit. Prefer your GitHub-provided `noreply` email to keep your personal email out of commit history:

```powershell
git config user.name "Your Name"
git config user.email "your-github-noreply-email"
git commit -m "Host a Website on Amazon S3 project"
```

## 5. Sign in and create a Private repo + push

```powershell
gh auth login
```

Choose `GitHub.com` → `HTTPS` → `Login with a web browser`. Complete the browser authorization, then run:

```powershell
gh repo create host-a-website-on-amazon-s3 --private --source=. --remote=origin --push
```

Then verify:

```powershell
gh repo view --web
```

Open **Actions** and check that *Validate website project* passes.

## If you do not have `gh`

After completing Step 4:

1. On github.com, create a new **Private** repo named `host-a-website-on-amazon-s3`. Do not initialize it with a README, license, or `.gitignore`.
2. In PowerShell inside the extracted project folder, add your repository URL and push:

```powershell
git remote add origin https://github.com/your-username/host-a-website-on-amazon-s3.git
git push -u origin main
```

Authenticate through Git Credential Manager or GitHub's prompt. Never paste a Personal Access Token into chat or commit it.

## Before you make the repo public

The PDF and screenshot `01-bucket-created.png` contain your AWS account ID and email address. Remove or redact them and review the rest of the repo before switching visibility to Public. The hosted S3 website can still be publicly readable while the GitHub repo stays Private.
