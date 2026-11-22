# Troubleshooting

## `BucketAlreadyExists` / bucket name is not available

S3 bucket names are globally unique across AWS accounts and partitions. Pick a different lowercase name with a random suffix, update `bucket_name` in `terraform/terraform.tfvars`, and run `terraform plan` again. The PDF's `nextwork-website-project-mluthos` identifies the bucket from the original exercise; it may already exist.

## `AccessDenied` when putting the bucket policy

Check that your AWS identity is allowed to create the bucket policy and configure S3 website hosting. Also check account- and organization-level S3 Block Public Access settings. This tutorial needs a public bucket policy. Do not disable account-level security controls to make it work; use a private bucket plus CloudFront for a production setup.

## Website endpoint returns `403 Forbidden`

1. Confirm static website hosting is enabled and `index.html` is the index document.
2. Confirm the `aws_s3_bucket_policy.site` resource was applied and grants `s3:GetObject` to the website objects.
3. Check that Block Public Access at the account/organization level is not overriding the bucket-level configuration.
4. Wait briefly after updating permissions, then retry the website endpoint.

The project uses a bucket policy rather than ACLs. Do not make the bucket's objects public with ACLs as a shortcut.

## Website endpoint returns `404 Not Found`

Confirm that `index.html` exists at the bucket root and that the key matches exactly (S3 keys are case-sensitive). If you changed the index-document setting, update `terraform/main.tf` to match.

## `terraform init` fails

Check your internet connection, Terraform version (`terraform version`), and AWS provider availability. `terraform init` needs internet access to download the provider. It does not need AWS credentials.

## `terraform plan` or `apply` says no credentials are configured

Configure an AWS identity locally. Prefer AWS IAM Identity Center/SSO (`aws configure sso` followed by `aws sso login`) or your organization's approved credentials mechanism. Do not put credentials in `.tf`, `.tfvars`, GitHub Actions, or chat. The validation workflow does not deploy and never needs AWS credentials.

## `terraform destroy` cannot remove the bucket

The bucket must be empty. Terraform removes its policy and managed website files first, but objects uploaded manually in the AWS Console are not tracked by Terraform. Remove any untracked objects and retry. Review the destroy plan before confirming.
