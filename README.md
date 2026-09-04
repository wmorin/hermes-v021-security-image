# Hermes v0.21.0 security image

This repository builds a narrowly patched container from public upstream
[NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent)
sources.

- Base: Hermes v0.21.0 / `v2026.8.31`, commit
  `29112bef099274229cadff79cdff7bf7b99c4b77`.
- Security manifests: commit
  `51e2cb22b07f302827fdf3fd82f1d8c710aedfe3`.
- Patched dependencies: `browserslist` 4.28.8 and `sanitize-html` 2.17.7.
- Platform: `linux/amd64`.

The preparation script verifies the exact base revision and SHA-256 hashes of
both manifests before and after replacement. The workflow audits the deployed
web workspace, builds with the upstream Dockerfile, and smoke-tests the Hermes
version, patched packages, and image labels before publishing.

The published image includes an SBOM and minimal BuildKit provenance. Tags are
discovery metadata only; consumers should pin the immutable manifest digest.

No private configuration, runtime data, credentials, or deployment repository
is used by this build.
