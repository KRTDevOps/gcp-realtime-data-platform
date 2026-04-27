# Governance Policy

## Scope

This policy applies to infrastructure, data pipelines, analytics models, and deployment workflows in this repository.

## Ownership Model

- Platform ownership is managed through `CODEOWNERS`.
- Changes to production-impacting areas require owner approval.
- Ownership should reflect active maintainers and be reviewed at least quarterly.

## Change Management

- All changes must be made through pull requests.
- Direct commits to protected branches should be disabled.
- High-risk changes (IAM, networking, production workflow files, Terraform provider/version updates) require at least one additional reviewer.
- Release changes should be tagged using semantic version tags (`vX.Y.Z`).

## Data Governance

- Data classification: public, internal, confidential, restricted.
- PII or sensitive fields must be documented before ingestion.
- New datasets and tables must define retention and access patterns.
- dbt models should avoid exposing restricted fields unless explicitly approved.

## Access Governance

- Follow least privilege for service accounts and human access.
- Avoid project-wide broad roles when narrower roles are sufficient.
- Access to production credentials must be restricted and audited.

## Security and Compliance

- Vulnerability reporting follows `SECURITY.md`.
- Secrets must never be committed; use secret scanning and CI checks.
- Dependencies should be patched regularly.

## Incident and Audit Readiness

- Keep incident notes in issues or internal runbooks.
- Preserve deployment and change history through Git and CI logs.
- Review governance and security controls at least every quarter.
