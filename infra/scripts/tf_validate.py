"""Run `terraform validate` for every root environment.

Called by the terraform-validate pre-commit hook (cross-platform; the
bash-based pre-commit-terraform hooks break on native Windows). Modules are
validated transitively through the envs that call them.
"""

import subprocess
import sys

ENVS = [
    "bootstrap/envs/prod",
    "infra/envs/prod",
]


def run(args):
    result = subprocess.run(args, capture_output=True, text=True)
    if result.returncode != 0:
        sys.stdout.write(result.stdout)
        sys.stderr.write(result.stderr)
        sys.exit(result.returncode)


for env in ENVS:
    run(["terraform", f"-chdir={env}", "init", "-backend=false", "-input=false"])
    run(["terraform", f"-chdir={env}", "validate", "-no-color"])
    print(f"{env}: valid")
