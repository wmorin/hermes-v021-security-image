#!/usr/bin/env bash
set -Eeuo pipefail

readonly UPSTREAM_REVISION='29112bef099274229cadff79cdff7bf7b99c4b77'
readonly BASE_PACKAGE_JSON_SHA256='8b5b2ea9721e8d4bdedea457f5b5bab038e7f3e11ea4e1381bd43f2e87ce04cd'
readonly BASE_PACKAGE_LOCK_SHA256='83beeba3f6e7826312444c7b64067488afae9ed88ad7326ecef61ac235bab86d'
readonly PATCHED_PACKAGE_JSON_SHA256='9244d4a64716a17c6656168ff5246650cd8bf5ef4b4a401e5deeed889139f94a'
readonly PATCHED_PACKAGE_LOCK_SHA256='4bbadc15f989ada778343934ee6138be64402c98501df247b1a768b76a452d4e'
readonly SECURITY_PATCH_SHA256='7a3c79d0d4c98f5660341bf9a035599a760e7a0764cb5d1db95011d5a4efdb77'
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
readonly SECURITY_PATCH="${SCRIPT_DIR}/security-manifests.patch"

test "$(git rev-parse HEAD)" = "$UPSTREAM_REVISION"
test "$(sha256sum package.json | awk '{print $1}')" = "$BASE_PACKAGE_JSON_SHA256"
test "$(sha256sum package-lock.json | awk '{print $1}')" = "$BASE_PACKAGE_LOCK_SHA256"

test "$(sha256sum "$SECURITY_PATCH" | awk '{print $1}')" = "$SECURITY_PATCH_SHA256"
git apply --check "$SECURITY_PATCH"
git apply "$SECURITY_PATCH"

test "$(sha256sum package.json | awk '{print $1}')" = "$PATCHED_PACKAGE_JSON_SHA256"
test "$(sha256sum package-lock.json | awk '{print $1}')" = "$PATCHED_PACKAGE_LOCK_SHA256"

python3 - <<'PY'
import json

package = json.load(open("package.json", encoding="utf-8"))
lock = json.load(open("package-lock.json", encoding="utf-8"))
assert package["overrides"]["browserslist"] == "4.28.8"
assert package["overrides"]["sanitize-html"] == "2.17.7"
assert lock["packages"]["node_modules/browserslist"]["version"] == "4.28.8"
assert lock["packages"]["node_modules/sanitize-html"]["version"] == "2.17.7"
print("security_patch=browserslist-4.28.8,sanitize-html-2.17.7")
PY

test "$(git diff --name-only -- package-lock.json package.json)" = $'package-lock.json\npackage.json'
