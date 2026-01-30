# GitHub Pages 404 troubleshooting

If you see **"There isn't a GitHub Pages site here"** or a 404:

---

## 1. Check that the workflow is succeeding

- Repo → **Actions** → open **"Build and Deploy to GitHub Pages"**.
- The **latest run** must be **green** (success). If it’s red, open the run and fix the failing step (e.g. Flutter version, missing secrets).
- If no deployment ever succeeded, the site will 404 until a run completes successfully.

---

## 2. Confirm Pages source is GitHub Actions

- Repo → **Settings** → **Pages**.
- Under **Build and deployment** → **Source**, it must be **"GitHub Actions"** (not "Deploy from a branch").
- Save if you change it.

---

## 3. Test the default URL first (no custom domain)

- Open **https://willemcna.github.io/** in your browser (your repo is `Willemcna.github.io`, so the site is at the root).
- If this works but your custom domain does not, the problem is with the custom domain or DNS (see step 4).
- If this **also** 404s, the problem is the deployment (workflow or source). Re-check steps 1 and 2.

---

## 4. Custom domain 404

If **https://willemcna.github.io/** works but your custom domain (e.g. from GoDaddy) shows 404:

**A. Temporarily remove the custom domain**

- Repo → **Settings** → **Pages** → **Custom domain**.
- Clear the domain and save. Use **https://willemcna.github.io/** until the custom domain is fixed.

**B. Set up DNS correctly at GoDaddy**

- **My Products** → your domain → **DNS** (or **Manage DNS**).
- Add the records **GitHub shows** under Settings → Pages → Custom domain when you add the domain again. Typically:
  - **A records** for `@` (apex):  
    `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`
  - **CNAME** for `www`: value `willemcna.github.io` (no `https://`, no path).
- Remove any old A/CNAME records that point elsewhere.
- Wait for DNS to propagate (up to 48 hours, often a few minutes).
- In GitHub **Settings → Pages**, add your custom domain again and save. When DNS is correct, enable **Enforce HTTPS**.

**C. CNAME for user/org Pages**

- For a user site (`username.github.io`), the CNAME target must be **username.github.io** (e.g. `willemcna.github.io`), **not** the repo URL with a path.

---

## 5. After changing anything

- Give it 1–2 minutes after a successful workflow run.
- Hard refresh or try an incognito/private window to avoid cache (especially after switching custom domain or DNS).
