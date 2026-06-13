# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.1.0] - 2026-06-13

### Added

- Project infrastructure: `.gitignore`, GitHub Actions markdown lint CI
- Community templates: issue templates (bug report, feature request), PR template
- `CONTRIBUTING.md` with guidelines for contributors
- `examples/` directory with ready-to-use command templates
  - `basic-choice.sh` — simple 4-option choice card
  - `deploy-confirm.sh` — deployment environment selection
  - `review-action.sh` — code review action picker
- `docs/architecture.md` — data flow diagram and component overview
- Badges in README (license, CI status, version)

### Changed

- README rewritten with problem/solution framing, quick start guide, and documentation index
- CHANGELOG reformatted to [Keep a Changelog](https://keepachangelog.com/) standard

## [1.0.0] - 2026-06-13

### Added

- Initial release of the Hermes Feishu approval buttons skill
- Documents custom Feishu approval buttons via Hermes terminal approval cards
- Covers `approvals.mode manual` vs `smart` behavior
- Captures `hermes-feishu-streaming-card` pitfalls: custom label propagation and `action.actions[]` rendering
- Includes test recipe and verification checklist

[Unreleased]: https://github.com/KK-invent/hermes-feishu-approval-buttons-skill/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/KK-invent/hermes-feishu-approval-buttons-skill/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/KK-invent/hermes-feishu-approval-buttons-skill/releases/tag/v1.0.0
