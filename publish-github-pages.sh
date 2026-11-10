#!/usr/bin/env bash
# Publishes only the public landing page to the gh-pages branch.
# The Russian plan, the parked English draft, and dist/ are never included.
# Usage: ./publish-github-pages.sh git@github.com:kirillchistov/prizma-roadmap.git
set -euo pipefail
REMOTE="${1:?Usage: ./publish-github-pages.sh <git remote URL of the public site repo>}"
LANDING="src/landing/index.html"
[ -f "$LANDING" ] || { echo "Missing $LANDING" >&2; exit 1; }

if grep -q "window.LW = {" "$LANDING" || grep -q "Parked on" "$LANDING"; then
  echo "$LANDING is not the public landing page. Aborting." >&2
  exit 1
fi

STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

cp "$LANDING" "$STAGE/index.html"
printf 'User-agent: *\nAllow: /\n' > "$STAGE/robots.txt"
touch "$STAGE/.nojekyll"

files="$(find "$STAGE" -type f | sed "s|^$STAGE/||" | sort)"
expected="$(printf '%s\n' .nojekyll index.html robots.txt)"
if [ "$files" != "$expected" ]; then
  echo "Stage contains more than the landing page. Aborting." >&2
  echo "$files" >&2
  exit 1
fi

cd "$STAGE"
git init -q
git checkout -q -b gh-pages
git add -A
git commit -q -m "Publish landing $(date -u +%Y-%m-%dT%H:%MZ)"
git push -f "$REMOTE" gh-pages

echo "Pushed the landing page only."
echo "In the public repo: Settings → Pages → Deploy from branch → gh-pages / root."
