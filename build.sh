#!/usr/bin/env bash
# Encrypts the Russian blueprint and writes it to dist/index.html.
# The English draft in parked/ is not built or published.
# Usage:  STATICRYPT_PASSWORD='a-long-unusual-passphrase' ./build.sh
# Only dist/ is ever published. Never publish src/ or parked/.
set -euo pipefail

: "${STATICRYPT_PASSWORD:?Set STATICRYPT_PASSWORD to a long passphrase (16+ characters)}"
if [ "${#STATICRYPT_PASSWORD}" -lt 16 ]; then
  echo "Password is shorter than 16 characters. Use a longer passphrase." >&2
  exit 1
fi

STATICRYPT="npx --yes staticrypt@3.5.4"
REMEMBER_DAYS="${REMEMBER_DAYS:-30}"

rm -rf dist
mkdir -p dist

$STATICRYPT "src/ru/index.html" -d dist \
  --short --remember "$REMEMBER_DAYS" \
  --template-title "Loopwise · доступ по паролю" \
  --template-instructions "Введите пароль, полученный от основателей." \
  --template-button "Открыть" \
  --template-placeholder "Пароль" \
  --template-remember "Запомнить на этом устройстве" \
  --template-color-primary "#1F4FD8" \
  --template-color-secondary "#F3F4F1"

# Keep search engines out (the page also carries a noindex tag once decrypted)
printf 'User-agent: *\nDisallow: /\n' > dist/robots.txt
# Tell GitHub Pages not to run Jekyll
touch dist/.nojekyll

if [ ! -f dist/index.html ] || [ -e dist/en ] || grep -q "window.LW = {" dist/index.html; then
  echo "dist/ is not a single encrypted Russian page. Aborting." >&2
  exit 1
fi

echo "Built encrypted Russian page at dist/index.html"
