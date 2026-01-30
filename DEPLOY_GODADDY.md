# Deploy to GitHub Pages (live site)

Push to `main` → the workflow builds the Flutter web app and deploys to GitHub Pages. Your site goes live at `https://<your-username>.github.io/<repo-name>/`. You can link a custom domain (e.g. from GoDaddy) via DNS.

---

## 1. Enable GitHub Pages (Actions)

1. On GitHub: open your repo → **Settings** → **Pages**.
2. Under **Build and deployment**, set **Source** to **GitHub Actions**.

## 2. Add GitHub Secrets

Repo → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**. Add two secrets:

| Secret name         | Value (same as in your `.env`) |
|---------------------|---------------------------------|
| `SUPABASE_URL`      | Your central Supabase project URL |
| `SUPABASE_ANON_KEY` | Your central Supabase anon key   |

## 3. Push to deploy

```bash
./publish.sh   # optional: build locally
git add .
git commit -m "Your message"
git push origin main
```

The **Build and Deploy to GitHub Pages** workflow runs on every push to `main`. When it succeeds, the site is live at `https://<your-username>.github.io/<repo-name>/`.

## 4. Link your GoDaddy custom domain (optional)

1. **GitHub:** Repo → **Settings** → **Pages** → under **Custom domain**, enter your domain (e.g. `yourdomain.com` or `www.yourdomain.com`) → **Save**. GitHub will show the DNS records to add.
2. **GoDaddy:** **My Products** → your domain → **DNS** (or **Manage DNS**). Add the records GitHub shows (A records for apex, CNAME for `www` if you use it).
3. Wait for DNS to propagate. In **Settings** → **Pages**, enable **Enforce HTTPS** when it becomes available.

To update the live site: push to `main`; the workflow deploys automatically.

---

**If you see a 404:** See **[PAGES_TROUBLESHOOTING.md](PAGES_TROUBLESHOOTING.md)** for step-by-step checks (workflow success, Pages source, custom domain, DNS).
