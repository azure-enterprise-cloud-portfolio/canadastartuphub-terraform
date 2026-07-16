"""Run `terraform validate` for every root environment.

Called by the terraform-validate pre-commit hook (cross-platform; the
bash-based pre-commit-terraform hooks break on native Windows). Modules are
validated transitively through the envs that call them.
"""

import os
import subprocess
import sys

ENVS = [
    "bootstrap/envs/prod",
    "infra/envs/prod",
]

# Isolated TF_DATA_DIR (resolved relative to each -chdir env, gitignored) so
# validation never touches the real .terraform/ workspace cache — a
# backend-initialized cache would otherwise make `init -backend=false` reach
# for AWS credentials.
ENV_VARS = {**os.environ, "TF_DATA_DIR": ".terraform-validate"}


def run(args):
    result = subprocess.run(args, capture_output=True, text=True, env=ENV_VARS)
    if result.returncode != 0:
        sys.stdout.write(result.stdout)
        sys.stderr.write(result.stderr)
        sys.exit(result.returncode)


for env in ENVS:
    run(["terraform", f"-chdir={env}", "init", "-backend=false", "-input=false"])
    run(["terraform", f"-chdir={env}", "validate", "-no-color"])
    print(f"{env}: valid")
