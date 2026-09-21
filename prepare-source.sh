#!/usr/bin/env bash
set -Eeuo pipefail

readonly UPSTREAM_REVISION='345cd2b057a452236de401d3534b8502a7465e8d'
readonly BASE_PACKAGE_JSON_SHA256='8b5b2ea9721e8d4bdedea457f5b5bab038e7f3e11ea4e1381bd43f2e87ce04cd'
readonly BASE_PACKAGE_LOCK_SHA256='6965ae1e1d1354557abc26bb3fb17d84e783673be21640bd03f5e5e10b4990d7'
readonly BASE_DESKTOP_PACKAGE_SHA256='4abbadd49eaacd61392bbb0e8d4a80c00307782f9d59d1895aeb22067f2c171c'
readonly BASE_TESTS_PACKAGE_SHA256='08657cd581bcaacec53c834c703cd6254579db0223c45d2d9a21b629060acec5'
readonly BASE_TUI_PACKAGE_SHA256='4753204cb018d78f203e4d2c9c1a8ca6f710563052c86df3c41f718b840f5418'
readonly BASE_WEB_PACKAGE_SHA256='884fec6f6a1a3c4293be5192ed492a1aaac7acfe7cd9e6f8938ca5453d31a0e9'
readonly PATCHED_PACKAGE_JSON_SHA256='794a89a4d7b3055be50f4fba8f703bd49b1a70f937f3e6c48ca810ed89098db4'
readonly PATCHED_PACKAGE_LOCK_SHA256='ac764cea0c7366326c4fdb4886db99367290b8cafb5d5ac2202acb9cea9dd8b0'
readonly PATCHED_DESKTOP_PACKAGE_SHA256='8f9b1205b4966f3f4d19de61c0945e99467afa80ef51a0e5f40b71f735512f58'
readonly PATCHED_TESTS_PACKAGE_SHA256='6242f728487ac60d730b1e39c447aa8c1ed19ac3feb407d73767c8b5a94fbf3c'
readonly PATCHED_TUI_PACKAGE_SHA256='5b7b79829475eb3d7d01d294a684ff710f6961d38b38cd50d922a7a596bf58fd'
readonly PATCHED_WEB_PACKAGE_SHA256='b4a35cfe99b09d3c04137c2b0c4a3c288b97cd0f7c4ec5aad56e3e48d8ad6965'
readonly SECURITY_PATCH_SHA256='4325356290ac7d4f1062d86facc9b1634e0770270823e89b87dd1863bd2e01cc'
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
readonly SECURITY_PATCH="${SCRIPT_DIR}/security-manifests.patch"

test "$(git rev-parse HEAD)" = "$UPSTREAM_REVISION"
test "$(sha256sum package.json | awk '{print $1}')" = "$BASE_PACKAGE_JSON_SHA256"
test "$(sha256sum package-lock.json | awk '{print $1}')" = "$BASE_PACKAGE_LOCK_SHA256"
test "$(sha256sum apps/desktop/package.json | awk '{print $1}')" = "$BASE_DESKTOP_PACKAGE_SHA256"
test "$(sha256sum tests-js/package.json | awk '{print $1}')" = "$BASE_TESTS_PACKAGE_SHA256"
test "$(sha256sum ui-tui/package.json | awk '{print $1}')" = "$BASE_TUI_PACKAGE_SHA256"
test "$(sha256sum web/package.json | awk '{print $1}')" = "$BASE_WEB_PACKAGE_SHA256"

test "$(sha256sum "$SECURITY_PATCH" | awk '{print $1}')" = "$SECURITY_PATCH_SHA256"
git apply --check "$SECURITY_PATCH"
git apply "$SECURITY_PATCH"

test "$(sha256sum package.json | awk '{print $1}')" = "$PATCHED_PACKAGE_JSON_SHA256"
test "$(sha256sum package-lock.json | awk '{print $1}')" = "$PATCHED_PACKAGE_LOCK_SHA256"
test "$(sha256sum apps/desktop/package.json | awk '{print $1}')" = "$PATCHED_DESKTOP_PACKAGE_SHA256"
test "$(sha256sum tests-js/package.json | awk '{print $1}')" = "$PATCHED_TESTS_PACKAGE_SHA256"
test "$(sha256sum ui-tui/package.json | awk '{print $1}')" = "$PATCHED_TUI_PACKAGE_SHA256"
test "$(sha256sum web/package.json | awk '{print $1}')" = "$PATCHED_WEB_PACKAGE_SHA256"

python3 - <<'PY'
import json

package = json.load(open("package.json", encoding="utf-8"))
lock = json.load(open("package-lock.json", encoding="utf-8"))
desktop = json.load(open("apps/desktop/package.json", encoding="utf-8"))
tests = json.load(open("tests-js/package.json", encoding="utf-8"))
tui = json.load(open("ui-tui/package.json", encoding="utf-8"))
web = json.load(open("web/package.json", encoding="utf-8"))
assert package["overrides"]["browserslist"] == "4.28.8"
assert package["overrides"]["sanitize-html"] == "2.17.7"
assert package["overrides"]["vitest"] == "4.1.11"
assert package["overrides"]["@vitest/mocker"] == "4.1.11"
assert package["overrides"]["colord"] == "2.9.4"
assert lock["packages"]["node_modules/browserslist"]["version"] == "4.28.8"
assert lock["packages"]["node_modules/sanitize-html"]["version"] == "2.17.7"
assert lock["packages"]["node_modules/vitest"]["version"] == "4.1.11"
assert lock["packages"]["node_modules/@vitest/mocker"]["version"] == "4.1.11"
assert lock["packages"]["node_modules/colord"]["version"] == "2.9.4"
assert desktop["devDependencies"]["vitest"] == "4.1.11"
assert tests["devDependencies"]["vitest"] == "4.1.11"
assert tui["devDependencies"]["vitest"] == "4.1.11"
assert web["devDependencies"]["vitest"] == "4.1.11"
print("security_patch=browserslist-4.28.8,sanitize-html-2.17.7,vitest-4.1.11,@vitest/mocker-4.1.11,colord-2.9.4")
PY

test "$(git diff --name-only -- apps/desktop/package.json package-lock.json package.json tests-js/package.json ui-tui/package.json web/package.json)" = $'apps/desktop/package.json\npackage-lock.json\npackage.json\ntests-js/package.json\nui-tui/package.json\nweb/package.json'
