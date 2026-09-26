#!/usr/bin/env bash
set -Eeuo pipefail

readonly UPSTREAM_REVISION='f97608f178d1ffeca59860195ab7da295f7c8e5f'
readonly BASE_DOCKERFILE_SHA256='364c5db9f80bad24173bed91b230354de37058752148155a4544a1a5b05fd80b'
readonly BASE_PACKAGE_JSON_SHA256='8b5b2ea9721e8d4bdedea457f5b5bab038e7f3e11ea4e1381bd43f2e87ce04cd'
readonly BASE_PACKAGE_LOCK_SHA256='193a3a3703499eb7c4b4ce48d3ba1e9dae2be62a48315c1e7ea9545e8be4a067'
readonly BASE_DESKTOP_PACKAGE_SHA256='e342bc2e0463da2fc340310542ab48b7554afdf09f8abd0e9e8224a13eaada9c'
readonly BASE_TESTS_PACKAGE_SHA256='08657cd581bcaacec53c834c703cd6254579db0223c45d2d9a21b629060acec5'
readonly BASE_TUI_PACKAGE_SHA256='4753204cb018d78f203e4d2c9c1a8ca6f710563052c86df3c41f718b840f5418'
readonly BASE_WEB_PACKAGE_SHA256='884fec6f6a1a3c4293be5192ed492a1aaac7acfe7cd9e6f8938ca5453d31a0e9'
readonly BASE_PYPROJECT_SHA256='6f969b9fdff95e7269ec808361e3ae8be5357036e6257e53a3306878cf8c41dd'
readonly BASE_LAZY_DEPS_SHA256='9f5261f97e1b1a96b0211eb5e23360a03143972fc52e6db9c1bfeb65cbf8e01d'
readonly BASE_UV_LOCK_SHA256='5b3798f326209475abca8ef7cbf7c9406f12e687c28c0b540dfe597466f48590'
readonly PATCHED_DOCKERFILE_SHA256='e88a91aefd19d4e704048b1bb728c76595d9a5885a9690e085f68c9a425e8141'
readonly PATCHED_PACKAGE_JSON_SHA256='307fbe666a374fe939959a8b9a3838045cc2882286dac0af8d2da2743111ae8b'
readonly PATCHED_PACKAGE_LOCK_SHA256='2d25e4f7b89c42c14c2f2f8d069e050fdc4148cad7c0f12b31dac4c573c365cf'
readonly PATCHED_DESKTOP_PACKAGE_SHA256='d5db84883af4d31e2b93cba6d9baad74cc5d45c53213daccae3f406df76a5650'
readonly PATCHED_TESTS_PACKAGE_SHA256='6242f728487ac60d730b1e39c447aa8c1ed19ac3feb407d73767c8b5a94fbf3c'
readonly PATCHED_TUI_PACKAGE_SHA256='5b7b79829475eb3d7d01d294a684ff710f6961d38b38cd50d922a7a596bf58fd'
readonly PATCHED_WEB_PACKAGE_SHA256='b4a35cfe99b09d3c04137c2b0c4a3c288b97cd0f7c4ec5aad56e3e48d8ad6965'
readonly PATCHED_PYPROJECT_SHA256='e36ac3fdccb60970d4e324b05c7f98c4cd1fe8ff7a6e4dd9cc6d4e2801aedb71'
readonly PATCHED_LAZY_DEPS_SHA256='c2bb3f2882fc5d43d7c10f758cc11b326b3a64d9d6f6fc5aef1bb821844b7fc5'
readonly PATCHED_UV_LOCK_SHA256='dd7ce98a5fa8090673536a441e87f1f99e266693050435a2587227bdf8d7ce60'
readonly SECURITY_PATCH_SHA256='70727d75c2c2bf99f8e9d16c98f095a5b28bdc589356463e6eddac6a5ad7eacf'
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
readonly SECURITY_PATCH="${SCRIPT_DIR}/security-manifests.patch"

test "$(git rev-parse HEAD)" = "$UPSTREAM_REVISION"
test "$(sha256sum Dockerfile | awk '{print $1}')" = "$BASE_DOCKERFILE_SHA256"
test "$(sha256sum package.json | awk '{print $1}')" = "$BASE_PACKAGE_JSON_SHA256"
test "$(sha256sum package-lock.json | awk '{print $1}')" = "$BASE_PACKAGE_LOCK_SHA256"
test "$(sha256sum apps/desktop/package.json | awk '{print $1}')" = "$BASE_DESKTOP_PACKAGE_SHA256"
test "$(sha256sum tests-js/package.json | awk '{print $1}')" = "$BASE_TESTS_PACKAGE_SHA256"
test "$(sha256sum ui-tui/package.json | awk '{print $1}')" = "$BASE_TUI_PACKAGE_SHA256"
test "$(sha256sum web/package.json | awk '{print $1}')" = "$BASE_WEB_PACKAGE_SHA256"
test "$(sha256sum pyproject.toml | awk '{print $1}')" = "$BASE_PYPROJECT_SHA256"
test "$(sha256sum tools/lazy_deps.py | awk '{print $1}')" = "$BASE_LAZY_DEPS_SHA256"
test "$(sha256sum uv.lock | awk '{print $1}')" = "$BASE_UV_LOCK_SHA256"

test "$(sha256sum "$SECURITY_PATCH" | awk '{print $1}')" = "$SECURITY_PATCH_SHA256"
git apply --check "$SECURITY_PATCH"
git apply "$SECURITY_PATCH"

test "$(sha256sum Dockerfile | awk '{print $1}')" = "$PATCHED_DOCKERFILE_SHA256"
test "$(sha256sum package.json | awk '{print $1}')" = "$PATCHED_PACKAGE_JSON_SHA256"
test "$(sha256sum package-lock.json | awk '{print $1}')" = "$PATCHED_PACKAGE_LOCK_SHA256"
test "$(sha256sum apps/desktop/package.json | awk '{print $1}')" = "$PATCHED_DESKTOP_PACKAGE_SHA256"
test "$(sha256sum tests-js/package.json | awk '{print $1}')" = "$PATCHED_TESTS_PACKAGE_SHA256"
test "$(sha256sum ui-tui/package.json | awk '{print $1}')" = "$PATCHED_TUI_PACKAGE_SHA256"
test "$(sha256sum web/package.json | awk '{print $1}')" = "$PATCHED_WEB_PACKAGE_SHA256"
test "$(sha256sum pyproject.toml | awk '{print $1}')" = "$PATCHED_PYPROJECT_SHA256"
test "$(sha256sum tools/lazy_deps.py | awk '{print $1}')" = "$PATCHED_LAZY_DEPS_SHA256"
test "$(sha256sum uv.lock | awk '{print $1}')" = "$PATCHED_UV_LOCK_SHA256"

python3 - <<'PY'
import json

import pathlib
import tomllib

package = json.load(open("package.json", encoding="utf-8"))
lock = json.load(open("package-lock.json", encoding="utf-8"))
desktop = json.load(open("apps/desktop/package.json", encoding="utf-8"))
tests = json.load(open("tests-js/package.json", encoding="utf-8"))
tui = json.load(open("ui-tui/package.json", encoding="utf-8"))
web = json.load(open("web/package.json", encoding="utf-8"))
pyproject = tomllib.loads(pathlib.Path("pyproject.toml").read_text(encoding="utf-8"))
uv_lock = pathlib.Path("uv.lock").read_text(encoding="utf-8")
lazy_deps = pathlib.Path("tools/lazy_deps.py").read_text(encoding="utf-8")
assert package["overrides"]["vitest"] == "4.1.11"
assert package["overrides"]["@vitest/mocker"] == "4.1.11"
assert lock["packages"]["node_modules/vitest"]["version"] == "4.1.11"
assert lock["packages"]["node_modules/@vitest/mocker"]["version"] == "4.1.11"
assert desktop["devDependencies"]["vitest"] == "4.1.11"
assert tests["devDependencies"]["vitest"] == "4.1.11"
assert tui["devDependencies"]["vitest"] == "4.1.11"
assert web["devDependencies"]["vitest"] == "4.1.11"
extras = pyproject["project"]["optional-dependencies"]
for extra in ("dev", "mcp", "computer-use"):
    assert "httpx2==2.12.0" in extras[extra]
assert '"httpx2==2.12.0"' in lazy_deps
for name, version in {
    "anyio": "4.14.2",
    "h2": "4.4.1",
    "hpack": "4.2.0",
    "httpcore2": "2.12.0",
    "httpx2": "2.12.0",
}.items():
    assert f'name = "{name}"\nversion = "{version}"' in uv_lock
dockerfile = pathlib.Path("Dockerfile").read_text(encoding="utf-8")
assert "debian:13@sha256:9cc080028c43b27d2074d63a5f9caf7166d731494965616c1a6d2827a004585c" in dockerfile
assert "node:26-bookworm-slim@sha256:662933cf47f013bc8e4beb31a6116448427a82057ba7c42c97e4c5ba766504c2" in dockerfile
assert "uv:0.12.19-python3.13-trixie@sha256:dbc39f05b15187083adc7d2ad7d7bb40f3227f1bfed39f428d73d7493fdc43fe" in dockerfile
print("security_patch=vitest-4.1.11,anyio-4.14.2,h2-4.4.1,hpack-4.2.0,httpx2-httpcore2-2.12.0,pinned-runtime-bases")
PY

test "$(git status --porcelain=v1 --untracked-files=all)" = $' M Dockerfile\n M apps/desktop/package.json\n M package-lock.json\n M package.json\n M pyproject.toml\n M tests-js/package.json\n M tools/lazy_deps.py\n M ui-tui/package.json\n M uv.lock\n M web/package.json'
