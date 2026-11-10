#!/usr/bin/env bash
# Uploads the encrypted dist/ folder to a Yandex Object Storage bucket.
# Needs the AWS CLI configured with a Yandex Cloud static access key
# (aws configure --profile yandex), and a bucket name WITHOUT dots so HTTPS works.
# Usage: ./publish-yandex.sh my-loopwise-bucket
set -euo pipefail
BUCKET="${1:?Usage: ./publish-yandex.sh <bucket-name-without-dots>}"
case "$BUCKET" in *.*) echo "Use a bucket name without dots, or HTTPS will not work on the default domain." >&2; exit 1;; esac
[ -f dist/index.html ] || { echo "Run ./build.sh first." >&2; exit 1; }
if [ -e dist/en ] || grep -q "window.LW = {" dist/index.html; then
  echo "dist/ contains unencrypted content or the parked English page. Aborting." >&2; exit 1
fi
aws --profile yandex --endpoint-url=https://storage.yandexcloud.net \
  s3 sync dist/ "s3://$BUCKET/" --delete --cache-control "no-cache"
echo "Uploaded. Open https://$BUCKET.storage.yandexcloud.net/index.html"
echo "(or https://$BUCKET.website.yandexcloud.net/ once website hosting is enabled on the bucket)."
