#!/usr/bin/env bash
# Pushes the encrypted dist/ folder to the gh-pages branch of a PUBLIC repository.
# Usage: ./publish-github-pages.sh git@github.com:YOUR-NAME/loopwise-site.git
set -euo pipefail
REMOTE="${1:?Usage: ./publish-github-pages.sh <git remote URL of the public site repo>}"
[ -f dist/index.html ] || { echo "Run ./build.sh first." >&2; exit 1; }
if [ -e dist/en ] || grep -q "window.LW = {" dist/index.html; then
  echo "dist/ contains unencrypted content or the parked English page. Aborting." >&2; exit 1
fi
cd dist
rm -rf .git
git init -q
git checkout -q -b gh-pages
git add -A
git commit -q -m "Publish $(date -u +%Y-%m-%dT%H:%MZ)"
git push -f "$REMOTE" gh-pages
rm -rf .git
echo "Pushed. In the repo settings, set Pages to deploy from the gh-pages branch."
