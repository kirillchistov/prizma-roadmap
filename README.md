# The Roadmap


```
src/ru/index.html         Russian plan, the only page that is published
src/index.html            local redirect to src/ru/, not published
build.sh                  encrypts src/ru/index.html into dist/index.html
publish-yandex.sh         uploads dist/ to Yandex Object Storage
publish-github-pages.sh   optional mirror for readers outside Russia
```

## 1. Choose where to host
to be continued

## 2. What is  and what's not protected
to be continued

## 3. Build
Requires Node.js 18+.


## 4. Publish to GitHub Pages (optional, readers outside Russia)

1. Keep this folder in a **private** repository (free on GitHub). `.gitignore` already excludes `dist/` etc.
2. Run:
   ```bash
   ./publish-github-pages.sh git@github.com:YOUR-NAME/loopwise-site.git
   ```
   The script refuses to push if it finds unencrypted content in `dist/`.

## 5. Publish to Yandex Object Storage

1. In Yandex Cloud, create a bucket with a name **without dots** (for example `loopwise-plan`), with public read access to objects.
2. Create a service account with the `storage.editor` role and a static access key. Configure it locally:
   ```bash
   aws configure --profile yandex   # key ID, secret, region ru-central1
   ```
3. Run:
   ```bash
   ./publish-yandex.sh loopwise-plan
   ```
4. Open `https://loopwise-plan.storage.yandexcloud.net/index.html`. Optionally enable website hosting on the bucket (index document `index.html`) to get `https://loopwise-plan.website.yandexcloud.net/`; the documentation does not state that the website domain serves HTTPS, so check it in a browser before you share that link.

## 6. Cloudflare Pages + Access (optional, readers outside Russia)
Not applicable just now


## 7. The feedback form

The page shows a form. By default it shows the visitor a summary to copy and send you.

To receive answers automatically, set `window.LW_FORM_ENDPOINT` near the top of `src/ru/index.html` to a URL that accepts a JSON `POST` with CORS enabled, then rebuild.

Pay attention to Russian laws regarding personal data privacy

## 8. Updating and rotating

- Edit `src/ru/index.html`, run `./build.sh`, run the publish script again. Leave `parked/` untouched.
- To rotate the password: run `./build.sh` with a new `STATICRYPT_PASSWORD`, republish, and tell viewers. Old "remember me" entries stop working.
