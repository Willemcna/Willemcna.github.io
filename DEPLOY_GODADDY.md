# Deploy Flutter Web App to GoDaddy

Your built app is ready. Use one of these methods to make the site live on GoDaddy.

---

## Option 1: Upload the zip (easiest)

1. **Locate the zip file**  
   In your project folder:  
   `build/aplle-web-deploy.zip`

2. **Log in to GoDaddy**  
   Go to [godaddy.com](https://www.godaddy.com) → sign in → **My Products**.

3. **Open your hosting**  
   Find your **Web Hosting** (or **cPanel Hosting**) → click **Manage**.

4. **Open File Manager**  
   In cPanel (or the hosting dashboard), open **File Manager** (or **Files**).

5. **Go to the web root**  
   Open the folder where your site is served from, usually:
   - `public_html` (main domain), or  
   - `public_html/yourdomain.com` (if you have multiple sites)

6. **Clear old site files (optional)**  
   If you had an older version, delete the old files in that folder (keep the folder itself).  
   Do **not** delete `.htaccess` if you use it for redirects.

7. **Upload and extract the zip**  
   - Click **Upload**.
   - Select `aplle-web-deploy.zip` (from `build/` in your project).
   - After upload, **right‑click the zip** → **Extract** (or **Unzip**).
   - Extract **into the current folder** (e.g. `public_html`) so that `index.html` is directly inside the web root.
   - Delete the zip after extraction if you want.

8. **Check the result**  
   Visit your domain (e.g. `https://yourdomain.com`). You should see the app.

---

## Option 2: Upload folder contents (no zip)

1. **Build the app** (if you haven’t):  
   `cd /Users/swopp/dev/aplle && ./publish.sh`

2. **Open the built files**  
   On your computer, open the folder:  
   `Users/swopp/dev/aplle/build/web/`  
   You should see: `index.html`, `main.dart.js`, `assets/`, `canvaskit/`, `icons/`, etc.

3. **Log in to GoDaddy** → **Web Hosting** → **Manage** → **File Manager**.

4. **Go to web root**  
   Open `public_html` (or the folder for your domain).

5. **Upload everything inside `build/web/`**  
   Upload **all** files and folders from `build/web/` into that web root so that:
   - `index.html` is in the root (e.g. `public_html/index.html`)
   - `main.dart.js`, `assets/`, `canvaskit/`, `icons/`, etc. are in the same root.

   Do **not** upload the `build/web` folder itself; only its **contents**.

---

## If the app doesn’t load or shows a blank page

- **Clear browser cache** or try an incognito/private window.
- **Check the address**  
  You must use `https://yourdomain.com` (or the exact URL of the folder you uploaded to). No trailing path like `/index.html` unless your server is set up for it.
- **Single-page app (Flutter)**  
  GoDaddy must serve `index.html` for all routes (so refresh and direct links work). If your plan supports it, add an `.htaccess` in the same folder as `index.html` with:

  ```apache
  <IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /
    RewriteRule ^index\.html$ - [L]
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule . /index.html [L]
  </IfModule>
  ```

  If you want this file created for you, say so and we can add it to the project.

---

## Option 3: Auto-deploy to GitHub Pages + custom domain (recommended)

GitHub hosts the site; your GoDaddy domain points to it. Every push to `main` builds and deploys automatically.

### 1. Enable GitHub Pages (Actions)

1. On GitHub: open your repo → **Settings** → **Pages**.
2. Under **Build and deployment**, set **Source** to **GitHub Actions**.

### 2. Add GitHub Secrets

Repo → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**. Add:

| Secret name         | Value (same as in your `.env`) |
|---------------------|---------------------------------|
| `SUPABASE_URL`     | Your central Supabase project URL |
| `SUPABASE_ANON_KEY` | Your central Supabase anon key   |

### 3. Push to deploy

After the workflow (`.github/workflows/deploy-pages.yml`) and secrets are in place:

```bash
./publish.sh   # optional: build locally and create zip
git add .
git commit -m "Your message"
git push origin main
```

The **Build and Deploy to GitHub Pages** workflow runs on every push to `main`. When it succeeds, the site is live at:

- `https://<your-username>.github.io/<repo-name>/`

### 4. Link your GoDaddy custom domain

1. **GitHub:** Repo → **Settings** → **Pages** → under **Custom domain**, enter your domain (e.g. `yourdomain.com` or `www.yourdomain.com`) → **Save**. GitHub will show the DNS records to add.
2. **GoDaddy:** **My Products** → your domain → **DNS** (or **Manage DNS**). Add the records GitHub shows, for example:
   - **A records** for `@` (apex): point to GitHub’s IPs (e.g. `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153` — use the values GitHub displays).
   - **CNAME** for `www`: point to `<your-username>.github.io` (or the value GitHub shows).
3. Wait for DNS to propagate (minutes to 48 hours). Back in **Settings** → **Pages**, enable **Enforce HTTPS** when it becomes available.

Your site will then be available at your custom domain with no manual uploads. To update: push to `main` and the workflow deploys the latest build.

---

## After deployment

- **Manual upload (Options 1–2):** The app uses the **central Supabase** URL and key that were in `.env` when you ran `./publish.sh`. To update: run `./publish.sh` again, then re-upload the new contents of `build/web/` (or a new zip) to GoDaddy.
- **GitHub Pages (Option 3):** The app uses the Supabase URL and key from **GitHub Secrets**. To update: push to `main`; the workflow builds and deploys automatically.
