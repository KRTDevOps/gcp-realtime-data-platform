config {
  format              = "default"
  module              = true
  disabled_by_default = false
}

plugin "google" {
  enabled = true
  version = "0.31.0"
  source  = "github.com/terraform-linters/tflint-ruleset-google"
}

# Keep a small, high-signal baseline for actionable feedback.
rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

# Avoid noisy style-only findings until conventions are formalized.
rule "terraform_naming_convention" {
  enabled = false
}
