# Security Policy

## Reporting a vulnerability

Report vulnerabilities via GitHub's private vulnerability reporting on this
repository, or email the address on the maintainer's GitHub profile.

You will receive an **acknowledgment within 72 hours**. If you do not receive
one, assume your report did not arrive and follow up on a fresh issue (without
sensitive details).

## Scope

This repository ships a git commit-msg hook. It processes commit message text
locally and never makes network calls. Attack surface of interest:

- Injection via crafted commit-message content reaching grep/awk unquoted
- Hook-chain behavior in `install.sh` (wrapper preserves prior `core.hooksPath`)
- Config parsing (`aiattr.policy`, `aiattr.agent`)

## Supported versions

The latest tagged release. The spec (`SPEC.md`) is normative for grammar
conformance questions, not security ones.
