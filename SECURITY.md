# Security Policy — Diligencia

## Supported Versions

| Version | Supported |
|---|---|
| v3.0.x | ✅ Active development |
| v2.x | ⚠️ Security fixes only |
| < v2.0 | ❌ No longer supported |

## Reporting a Vulnerability

Diligencia is a documentation methodology — it has no executable code runtime.
Security issues are limited to documentation integrity and project governance.

**DO NOT** file a public GitHub issue for sensitive matters.

Report via:
- GitHub Issues: https://github.com/JuanoLemos/diligencia/issues
- Email: juano.lemos@example.com

## Scope

- Integrity of AGENTS.md variables and routing
- Unauthorized modifications to ROADMAP.md, CHANGELOG.md, DILIGENCIA.md
- Broken cross-references in documentation that could mislead users
- Exposure of project paths or internal structure through documentation

## Out of Scope

- UI/UX bugs in OpenChamber (reported to btriapitsyn/openchamber)
- Feature requests for additional commands
- Documentation formatting issues without security impact

## Disclosure Policy

- Reports will be acknowledged within 48 hours
- Fixes will be deployed in the next patch/minor release
- Reporters will be credited (unless they request anonymity)
