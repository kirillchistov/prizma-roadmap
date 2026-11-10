# Loopwise blueprint: password-protected deployment

This kit publishes one page: the Russian founding plan. The English EU/UK draft is parked and is not built or published.

```
src/ru/index.html         Russian plan, the only page that is published
src/index.html            local redirect to src/ru/, not published
parked/en/index.html      EU/UK draft, not built
build.sh                  encrypts src/ru/index.html into dist/index.html
publish-yandex.sh         uploads dist/ to Yandex Object Storage
publish-github-pages.sh   optional mirror for readers outside Russia
```

## 1. Choose where to host

The plan is for readers in Russia. Host it on Yandex Object Storage. GitHub Pages and Cloudflare stay in this kit as an optional mirror for someone opening the link from outside Russia.

| Your viewers | Recommended setup | Cost | Protection strength |
|---|---|---|---|
| Russia, and anyone who must open the link from there | **Yandex Object Storage + StatiCrypt** | Pay-as-you-go storage and traffic; small for a site this size | Medium: one shared password |
| A reader outside Russia who cannot open Yandex | **GitHub Pages + StatiCrypt** | Free | Medium: one shared password |
| Named access, revocation and logs, readers outside Russia | **Cloudflare Pages + Cloudflare Access** | Free for teams under 50 users | Strong: login per person |

Why Yandex is the default:

- Cloudflare confirmed in June 2025 that its services were being slowed from the Russian side, with only the first 16 KB of each connection getting through. These pages are 290–415 KB, so Cloudflare-hosted versions are unreliable for viewers in Russia.
- Russian users also reported GitHub access problems in May 2026. Do not rely on GitHub Pages for Russian viewers.
- GitHub Pages on a free account works only from **public** repositories. Private publishing needs an organization on GitHub Enterprise Cloud. That is why this kit publishes only the encrypted `dist/` folder to a public repo and keeps `src/` private.

A no-deployment alternative: the claude.ai artifact links can be shared from the page's Share menu with specific people. That is the quickest option if your viewers can sign in to claude.ai.

## 2. What StatiCrypt does and does not protect

StatiCrypt encrypts each page with AES-256 (PBKDF2-SHA256 key stretching, 600,000 iterations) and decrypts it in the browser after the visitor types the password. The server only ever holds encrypted files.

- **Anyone can download the encrypted file and guess offline.** Use a long passphrase of 16+ characters, ideally 4–5 random words. `build.sh` refuses shorter ones.
- **One password for everyone.** You cannot revoke a single person. To cut access, change the password, rebuild and republish.
- **No access log.** You won't know who opened the page.
- **"Remember me"** stores a derived key in the visitor's browser for 30 days (change with `REMEMBER_DAYS`).
- The decryption needs HTTPS (or localhost). GitHub Pages and Yandex Object Storage both provide HTTPS on their default domains, as long as the Yandex bucket name has no dots.

If you need per-person access or an audit trail, use Cloudflare Access (outside Russia) or a server with real login.

## 3. Build

Requires Node.js 18+.

```bash
STATICRYPT_PASSWORD='four random words here plus 7' ./build.sh
```

This creates `dist/index.html` (the encrypted Russian plan) plus `robots.txt` and `.nojekyll`. It refuses to finish if the English draft or the plain page gets into `dist/`. StatiCrypt also writes `.staticrypt.json` (a public salt, not a secret). Keep that file so "remember me" survives rebuilds.

Never type the password into a shared terminal history; prefer `read -s STATICRYPT_PASSWORD; export STATICRYPT_PASSWORD; ./build.sh`.

## 4. Publish to GitHub Pages (optional, readers outside Russia)

1. Keep this folder in a **private** repository (free on GitHub). `.gitignore` already excludes `dist/`.
2. Create an empty **public** repository, for example `loopwise-site`.
3. Run:
   ```bash
   ./publish-github-pages.sh git@github.com:YOUR-NAME/loopwise-site.git
   ```
   The script refuses to push if it finds unencrypted content in `dist/`.
4. In the public repo: **Settings → Pages → Build and deployment → Deploy from a branch → `gh-pages` / root**.
5. Your site appears at `https://YOUR-NAME.github.io/loopwise-site/`. Send the link and the password through different channels.

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

Do not upload `src/` or `parked/`. Russian readers should get the Yandex link: Cloudflare is unreliable from Russia, and the plain source must stay private.

1. Create a Cloudflare Pages project and upload `dist/`.
2. In **Zero Trust → Access → Applications**, add a self-hosted application for the Pages domain.
3. Add a policy that allows specific email addresses. Visitors then log in through an identity provider you configure; you can remove a person at any time and see access logs.
4. Check whether the `*.pages.dev` preview URLs are covered by the policy, and add them if not.

## 7. The feedback form

The page shows a form. By default it shows the visitor a summary to copy and send you.

To receive answers automatically, set `window.LW_FORM_ENDPOINT` near the top of `src/ru/index.html` to a URL that accepts a JSON `POST` with CORS enabled, then rebuild.

Russian law has required, since 1 July 2025, that personal data of Russian citizens be recorded and stored in databases located in Russia. Use an endpoint that stores submissions inside Russia (for example a Yandex Cloud Function writing to Yandex storage), or keep the copy-and-send behaviour. Do not point the form at a foreign service.

## 8. Updating and rotating

- Edit `src/ru/index.html`, run `./build.sh`, run the publish script again. Leave `parked/` untouched.
- To rotate the password: run `./build.sh` with a new `STATICRYPT_PASSWORD`, republish, and tell viewers. Old "remember me" entries stop working.

## 9. Checklist before sharing

- [ ] Only `dist/` is published. `src/` and `parked/` stay in a private repo or on your machine.
- [ ] Passphrase is 16+ characters and sent separately from the link.
- [ ] Readers in Russia get the Yandex link.
- [ ] The form endpoint stores data in Russia, or is left empty.
- [ ] You opened the published page in a private browser window and the password worked.
