# 🚀 Mobawi SaaS Platform Deployment Tutorial
### Complete Beginner's Guide — Step by Step, No Coding Knowledge Required

This guide will show you how to take your entire multi-tenant hotel SaaS platform online. We will set up the **Neon Database**, deploy the **Render Backend API**, and host the **Vercel Admin UI**.

---

## The SaaS Architecture

All your code lives in a single GitHub repository (`ceejayszn/saas-mobawi-dev`). We will connect different parts of this repository to different cloud hosting services:

```text
    ceejayszn/saas-mobawi-dev (GitHub Repo)
       │
       ├─── backend_api/ ──────────► Render (Backend API Host) ──► Neon PostgreSQL (Database)
       └─── mobawi_admin/ ─────────► Vercel (Admin Web Console)
```

---

## STEP 1 — Create and Set Up Your Database (Neon.tech)

Think of Neon as your secure, cloud hard drive. It saves all your sales, database tables, and tenant information.

1. Open your browser and go to: **[https://neon.tech](https://neon.tech)**
2. Click **Sign Up** (we recommend signing up with your **GitHub** account).
3. Once logged in, click **Create Project**.
4. Fill in the project details:
   * **Project Name**: Type `mobawi-db`
   * **PostgreSQL Version**: Leave it on `16` (the default)
   * **Region**: Choose the region closest to your customers (e.g., *Singapore*, *US East*, or *Europe*)
5. Click **Create Project**.
6. A popup will show you your **Connection String** (database address). It looks like this:
   ```text
   postgresql://neondb_owner:npg_xyz123abc@ep-empty-paper-azrcpyze-pooler.c-3.ap-southeast-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
   ```
7. Click the **Copy** icon next to the link. Save this string in a text file on your computer—you will need it in the next steps!

---

## STEP 2 — Deploy Your Backend API Server (Render.com)

Render will host your Node.js backend. Render reads your repository, builds a Docker image, and keeps the server running 24/7.

1. Go to: **[https://render.com](https://render.com)**
2. Sign up or log in (choose **GitHub** to log in, so Render can access your code).
3. On your Render dashboard, click the blue **New +** button at the top right, then select **Blueprint**.
4. You will see a list of your repositories. Locate `ceejayszn/saas-mobawi-dev` and click **Connect**.
5. Give your blueprint a service group name, like `mobawi-services`.
6. Scroll down to the **Blueprint Configuration** inputs:
   * **Branch**: Leave it as `main`.
   * **Blueprint Path (CRITICAL)**: Change `render.yaml` to:
     ```text
     backend_api/render.yaml
     ```
     *(This tells Render to look inside the `backend_api` subfolder for the deployment settings).*
7. Look at the variable input fields that appear:
   * **`DATABASE_URL`**: Paste your Neon connection string (from Step 1).
   * **`JWT_SECRET`**: Paste a long random string of numbers and letters (e.g., `f1d39bc53e5bdf9b32a6cb82e75e18a2d129a3e5f4ef7a8e09f8d9b1c20f781a`) to secure your API tokens.
8. Click **Apply** or **Create Service**.
9. Render will take 2–3 minutes to build and launch your server. Once the logs say **"Live"** with a green badge, look at the top left of the dashboard. Copy your **Public URL** (it looks like `https://mobawi-backend-api.onrender.com`).

## STEP 3 — Host the Admin Web Hub (GitHub Pages)

GitHub Actions will automatically compile your Dart code and publish the Admin Console web app to GitHub Pages.

1. **Activate Pages in GitHub Settings**:
   * Go to your repository page on GitHub: `https://github.com/ceejayszn/saas-mobawi-dev`
   * Click the **Settings** tab at the top.
   * Click **Pages** on the left menu bar.
   * Under **Build and deployment** -> **Source**, make sure **"Deploy from a branch"** is selected.
   * Under **Branch**, select **`gh-pages`** and the `/ (root)` folder (Note: the `gh-pages` branch will appear automatically after the first push finishes building).
   * Click **Save**.

2. **Your Admin URL**:
   * Your live Admin Console will be hosted at:
     ```text
     https://ceejayszn.github.io/saas-mobawi-dev/
     ```
   * You can watch the build progress under the **Actions** tab on your GitHub repository.


---

## STEP 4 — Updating Code in the Future

Because everything is configured as a Monorepo, updating the live servers is extremely easy. When you make changes in your code editor locally:

1. Open your terminal at the root of the repository (`apps/felixpinski`).
2. Run these commands:
   ```bash
   git add .
   git commit -m "Describe what changes you made"
   git push origin main
   ```
3. That is it! Render and GitHub Actions (GitHub Pages) will instantly see the new code and redeploy the live backend and web console automatically within a few minutes.
