# =============================================================================
# TFLint Configuration
# Docs: https://github.com/terraform-linters/tflint
# =============================================================================

config {
  # Scan all module calls recursively
  call_module_type = "local"
}

# AWS provider plugin — catches deprecated args, invalid resource configs
plugin "aws" {
  enabled = true
  version = "0.32.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# ── Rules ────────────────────────────────────────────────────────────────────

# Enforce all variables have a description
rule "terraform_documented_variables" {
  enabled = true
}

# Enforce all outputs have a description
rule "terraform_documented_outputs" {
  enabled = true
}

# Warn on deprecated interpolation syntax (e.g. "${var.foo}" → var.foo)
rule "terraform_deprecated_interpolation" {
  enabled = true
}

# Require explicit type constraints on all variables
rule "terraform_typed_variables" {
  enabled = true
}

# Enforce naming conventions match your resource_prefix pattern
rule "terraform_naming_convention" {
  enabled = true

  variable {
    format = "snake_case"
  }

  output {
    format = "snake_case"
  }

  locals {
    format = "snake_case"
  }
}
