# Security Policy

## Supported Scope

This policy covers code and infrastructure in this repository, including:

- Terraform IaC
- Dataflow/Airflow/dbt pipeline code
- CI/CD workflows

## Reporting a Vulnerability

Do not open public issues for security vulnerabilities.

Please report by contacting the repository owner privately and include:

- Impact summary
- Reproduction steps
- Affected files/components
- Suggested mitigation (if available)

## Expected Response

- Initial triage acknowledgement target: within 3 business days
- Fix/mitigation timeline depends on severity and exploitability
- Critical issues should be prioritized for immediate mitigation

## Security Expectations

- Never commit secrets, keys, credentials, or tokens.
- Use GitHub Secrets (or secure secret managers) for sensitive values.
- Prefer pinned and reviewed dependency updates.
- Apply least-privilege IAM for all service accounts and workloads.

## Hardening Baseline

- Terraform provider versions are pinned via `terraform/versions.tf`.
- Provider lock strategy is documented in `README.md`.
- CI should include format, validate, and lint/security checks where possible.

## Disclosure

After remediation, maintainers may publish a summary including impact and mitigation details.
