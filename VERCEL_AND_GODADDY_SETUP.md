# Option 2: Auto-Deploy to Vercel + Your GoDaddy Domain

Push to `main` → GitHub Action builds your Flutter app and deploys to Vercel → your custom domain (at GoDaddy) points to Vercel.

---

## Part 1: Vercel setup

### 1. Create a Vercel account and project

1. Go to [vercel.com](https://vercel.com) and sign in (e.g. with GitHub).
2. Click **Add New** → **Project**.
3. **Import** your GitHub repo (`Willemcna/Willemcna.github.io` or your actual repo).
4. **Do not** change the default build settings yet — we deploy from GitHub Actions with a prebuilt output, so Vercel’s build step won’t run.
5. Click **Deploy** (it may fail the first time; that’s OK).
6. After the project exists, go to **Project Settings** → **General**.
7. Note your **Project ID** (and, if shown, **Team/Org ID**). You’ll need these for GitHub secrets.

### 2. Get Vercel token and IDs

1. Go to [vercel.com/account/tokens](https://vercel.com/account/tokens).
2. Create a new token (e.g. name: `github-aplle`). Copy the token; you won’t see it again.
3. **Org ID**: Vercel dashboard → your **Team/Profile** (top left) → **Settings** → **General** → copy **Team ID** (or “Org ID”).
4. **Project ID**: In the project → **Settings** → **General** → copy **Project ID**.

---

## Part 2: GitHub secrets

Add these in your GitHub repo so the Action can build and deploy.

1. Open your repo on GitHub → **Settings** → **Secrets and variables** → **Actions**.
2. Click **New repository secret** and add:

| Secret name         | Where to get it |
|---------------------|------------------|
| `SUPABASE_URL`      | Your central Supabase project URL (same as in `.env`). |
| `SUPABASE_ANON_KEY`| Your central Supabase anon key (same as in `.env`). |
| `VERCEL_TOKEN`      | The token you created in Part 1. |
| `VERCEL_ORG_ID`     | Team/Org ID from Vercel (Part 1). |
| `VERCEL_PROJECT_ID` | Project ID from your Vercel project (Part 1). |

---

## Part 3: Push and deploy

1. Commit and push the new workflow and this guide:
   ```bash
   git add .github/workflows/deploy-vercel.yml VERCEL_AND_GODADDY_SETUP.md
   git commit -m "Add GitHub Action to deploy to Vercel"
   git push origin main
   ```
2. On GitHub, open **Actions** and watch the “Build and Deploy to Vercel” workflow. It should build Flutter and deploy to Vercel.
3. After it succeeds, your app will be live at a Vercel URL like `https://your-project.vercel.app`.

---

## Part 4: Point your GoDaddy domain to Vercel

1. In **Vercel**: open your project → **Settings** → **Domains** → add your domain (e.g. `yourdomain.com` and optionally `www.yourdomain.com`). Vercel will show the DNS records you need.
2. In **GoDaddy**: go to [dnsmanagement.godaddy.com](https://dnsmanagement.godaddy.com) (or **My Products** → **DNS** for your domain).
3. Add or update records as Vercel instructs, for example:
   - **A record**: name `@`, value `76.76.21.21` (Vercel’s IP; confirm in Vercel’s Domains page).
   - **CNAME**: name `www`, value `cname.vercel-dns.com` (or what Vercel shows).
4. Save and wait a few minutes (up to 48 hours for DNS). Vercel will issue SSL for your domain.

After DNS propagates, `https://yourdomain.com` will show your Flutter app, and every push to `main` will auto-deploy.

---

## Summary

- **GitHub**: Push to `main` → Action runs `flutter build web` with your Supabase secrets, then deploys `build/web` to Vercel.
- **Vercel**: Hosts the app and gives you a URL; you add your custom domain.
- **GoDaddy**: You only change DNS (A + CNAME) to point the domain at Vercel; the domain can stay registered at GoDaddy.

No more manual uploads: push → build → deploy → live.
