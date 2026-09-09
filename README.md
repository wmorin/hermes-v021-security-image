# Hermes v0.21.0 security image

This repository builds a narrowly patched container from public upstream
[NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent)
sources.

- Base: Hermes v0.21.0 / `v2026.8.31`, commit
  `29112bef099274229cadff79cdff7bf7b99c4b77`.
- Upstream security baseline: commit
  `51e2cb22b07f302827fdf3fd82f1d8c710aedfe3`.
- Patched dependencies: `browserslist` 4.28.8, `sanitize-html` 2.17.7,
  `vitest` / `@vitest/mocker` 4.1.11, and `colord` 2.9.4.
- Platform: `linux/amd64`.

The tracked `security-manifests.patch` is the exact six-file dependency-manifest
diff from the base revision. The preparation script verifies its SHA-256 plus
the exact base revision and every manifest hash before and after applying it.
The workflow audits the root, web, and TUI dependency scopes, builds with the
upstream Dockerfile, and smoke-tests the Hermes version, patched packages, and
image labels before publishing.

The published image includes an SBOM and minimal BuildKit provenance. Tags are
discovery metadata only; consumers should pin the immutable manifest digest.

No private configuration, runtime data, credentials, or deployment repository
is used by this build.
