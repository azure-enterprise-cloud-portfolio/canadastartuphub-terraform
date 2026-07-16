---
description: Produce a Terraform plan for a stack (default infra/envs/prod) and summarize the changes
---

Produce a Terraform plan and summarize it. Stack argument (optional):
`$ARGUMENTS` — default to `infra/envs/prod`; also accepts `bootstrap`
(meaning `bootstrap/envs/prod`).

Steps:
1. `terraform init -input=false` in the stack directory (real backend — this
   needs AWS credentials; if init fails on auth, tell the user how to
   authenticate rather than retrying).
2. `terraform plan -input=false -out=tfplan`.
3. Summarize the plan for the user: resources added/changed/destroyed, and
   call out anything destructive (replacements, deletions) prominently.
4. Do NOT apply. Applying to prod happens via GitHub Actions on merge to
   main (infra) or manually with explicit user approval (bootstrap).
