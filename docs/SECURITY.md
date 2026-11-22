# Security notes

## Public website behavior is intentional

The tutorial's S3 website endpoint is public. The Terraform bucket policy grants anonymous `s3:GetObject` on objects in this website bucket. Anything uploaded to it can be read by anyone on the internet. Upload only content you intend to publish.

The bucket-level public-access-block resource keeps public ACLs blocked, but permits the public-read bucket policy used by this tutorial. AWS account- or organization-level controls may still block public policies. Do not weaken broader guardrails to force deployment; use CloudFront with a private S3 origin for production instead.

## No secrets in the repository

Never commit AWS access keys, session tokens, private keys, credentials files, `.env` files, Terraform state, or personal data. The CI workflow validates configuration without AWS credentials. Deploy locally using your own securely configured AWS identity (prefer IAM Identity Center/SSO).

## Delete protection is a learning example

The explicit `Deny` covers only `s3:DeleteObject` for `index.html`. It is not a general backup or recovery strategy and does not prevent all bucket-level changes. Since explicit Deny overrides Allow, even the bucket owner cannot delete `index.html` until the policy is removed. Terraform orders policy removal before object cleanup when destroying this stack.

## Sharing the repository

The source PDF and screenshot `01-bucket-created.png` show an AWS account ID and email address. Account IDs are not passwords, but the email is personal information. Keep this repo private unless you first remove or redact those materials and check all remaining files.
