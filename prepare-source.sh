#!/usr/bin/env bash
set -Eeuo pipefail

readonly UPSTREAM_REVISION='29112bef099274229cadff79cdff7bf7b99c4b77'
readonly BASE_PACKAGE_JSON_SHA256='8b5b2ea9721e8d4bdedea457f5b5bab038e7f3e11ea4e1381bd43f2e87ce04cd'
readonly BASE_PACKAGE_LOCK_SHA256='83beeba3f6e7826312444c7b64067488afae9ed88ad7326ecef61ac235bab86d'
readonly BASE_DESKTOP_PACKAGE_SHA256='778dcd5d2d20a9dc8f80501753e90be996a2a9f425766cdff5263423d16da7fd'
readonly BASE_TESTS_PACKAGE_SHA256='08657cd581bcaacec53c834c703cd6254579db0223c45d2d9a21b629060acec5'
readonly BASE_TUI_PACKAGE_SHA256='4753204cb018d78f203e4d2c9c1a8ca6f710563052c86df3c41f718b840f5418'
readonly BASE_WEB_PACKAGE_SHA256='884fec6f6a1a3c4293be5192ed492a1aaac7acfe7cd9e6f8938ca5453d31a0e9'
readonly PATCHED_PACKAGE_JSON_SHA256='6cbd74d60e948e1bbf353d409b3e69e9931d68f8cf6bb97ab69b329263d9305f'
readonly PATCHED_PACKAGE_LOCK_SHA256='6bbbe429327fba318b501df3c936f6758d77fc1c66c9747e734e4e3755c6b8c0'
readonly PATCHED_DESKTOP_PACKAGE_SHA256='a3285a897d018342eb0e439b0a5dab0bf870e1041dc3582b8c26438300121b1f'
readonly PATCHED_TESTS_PACKAGE_SHA256='6242f728487ac60d730b1e39c447aa8c1ed19ac3feb407d73767c8b5a94fbf3c'
readonly PATCHED_TUI_PACKAGE_SHA256='5b7b79829475eb3d7d01d294a684ff710f6961d38b38cd50d922a7a596bf58fd'
readonly PATCHED_WEB_PACKAGE_SHA256='b4a35cfe99b09d3c04137c2b0c4a3c288b97cd0f7c4ec5aad56e3e48d8ad6965'
readonly SECURITY_PATCH_SHA256='eb40360f786d746fe378ce230d8ab914b8246bdf497f69f4857a99a695081ca5'
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
