# Bootstrap — GitHub OIDC for CI

Standalone stack that creates the GitHub OIDC identity provider and the
`canadastartuphub-github-actions` IAM role that the Terraform pipeline
(`.github/workflows/terraform.yml`) assumes. It is deliberately separate from
`infra/` so the pipeline's own credentials are not managed by the state the
pipeline applies.

Apply this **once, locally**, with your own AWS credentials — the pipeline
cannot create the role it needs to authenticate.

```
bootstrap/
├── modules/
│   └── github-oidc/    # OIDC provider + IAM role + trust policy
└── envs/
    └── prod/           # Calls the module; state key bootstrap/prod/terraform.tfstate
```

## One-time setup

```powershell
cd bootstrap\envs\prod
terraform init
terraform apply
```

Then:

1. Copy the `github_actions_role_arn` output into a GitHub Actions secret named
   `AWS_ROLE_ARN` (repo → Settings → Secrets and variables → Actions).
2. Push; the workflow authenticates via OIDC (`role-to-assume`).
3. After the first green run, delete the old `AWS_ACCESS_KEY_ID` /
   `AWS_SECRET_ACCESS_KEY` secrets and deactivate that IAM user's access keys.

## Notes

- An AWS account can hold only **one** GitHub OIDC provider. If the apply fails
  with `EntityAlreadyExists`, set `create_github_oidc_provider = false` (in
  `envs/prod/variables.tf` or a tfvars file) and the module reuses the existing
  provider.
- The role trusts any workflow run in
  `azure-enterprise-cloud-portfolio/canadastartuphub-terraform` (PR plans and
  main-branch applies). Fork PRs never receive OIDC tokens, so they cannot
  assume it.
- The role has `AdministratorAccess`; scope it down if the account ever hosts
  anything beyond this project.
