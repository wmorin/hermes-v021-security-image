# Hermes v0.21.5 security image

This repository builds a narrowly patched container from public upstream
[NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent)
sources.

- Base: Hermes v0.21.5 / `v2026.9.24`, commit
  `f97608f178d1ffeca59860195ab7da295f7c8e5f`.
- Patched dependencies: `vitest` / `@vitest/mocker` 4.1.11,
  `anyio` 4.14.2, `h2` 4.4.1, `hpack` 4.2.0, and
  `httpx2` / `httpcore2` 2.12.0.
- Pinned build inputs: Debian 13 index
  `sha256:9cc080028c43b27d2074d63a5f9caf7166d731494965616c1a6d2827a004585c`,
  Node 26 Bookworm Slim index
  `sha256:662933cf47f013bc8e4beb31a6116448427a82057ba7c42c97e4c5ba766504c2`,
  and uv 0.12.19 index
  `sha256:dbc39f05b15187083adc7d2ad7d7bb40f3227f1bfed39f428d73d7493fdc43fe`.
- Platform: `linux/amd64`.

The upstream release tag is unsigned. This builder therefore pins the resolved
commit directly and publishes its own immutable image digest, SBOM, and minimal
GitHub Actions provenance; deployment still requires an explicit one-time
unsigned-source exception and independent exact-head review.

The tracked `security-manifests.patch` is the exact ten-file dependency and
container-build diff from the base revision. The preparation script verifies its SHA-256 plus
the exact base revision and every manifest hash before and after applying it.
The workflow audits the root, web, and TUI dependency scopes, builds with the
upstream Dockerfile, and smoke-tests the Hermes version, patched packages, and
image labels before publishing.

The workflow publishes directly to the version-specific final package
`ghcr.io/wmorin/hermes-v0215-security-image`. Before the workflow can publish,
that package must be created by a command-line bootstrap push and its GitHub
visibility must be verified as private. This avoids a first GitHub Actions push
inheriting the public builder repository's visibility. After publication, the
workflow records the actual visibility, proves the matching anonymous-pull
behavior, and verifies the exact digest, SBOM, structural source provenance,
and provenance subject. It refuses to publish unless the existing destination
package is private.

The image has only a commit-addressed `build-<builder SHA>` discovery tag. It
does not publish a semantic container tag because GHCR does not provide
registry-enforced immutable tags. Consumers must pin the immutable manifest
digest reported by the workflow; tags are non-authoritative discovery metadata.

The exact final image must have no fixable HIGH or CRITICAL Trivy findings.
No private configuration, runtime data, credentials, or deployment repository
is used by this build.
