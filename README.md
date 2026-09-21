# Hermes v0.21.3 security image

This repository builds a narrowly patched container from public upstream
[NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent)
sources.

- Base: Hermes v0.21.3 / `v2026.9.14`, commit
  `345cd2b057a452236de401d3534b8502a7465e8d`.
- Upstream security baseline: commit
  `51e2cb22b07f302827fdf3fd82f1d8c710aedfe3`.
- Patched dependencies: `browserslist` 4.28.8, `sanitize-html` 2.17.7,
  `vitest` / `@vitest/mocker` 4.1.11, and `colord` 2.9.4.
- Platform: `linux/amd64`.

The upstream release tag is unsigned. This builder therefore pins the resolved
commit directly and publishes its own immutable image digest, SBOM, and minimal
GitHub Actions provenance; deployment still requires an explicit one-time
unsigned-source exception and independent exact-head review.

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
