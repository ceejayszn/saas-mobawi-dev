# 🚀 Railway Database Setup Tutorial
### Complete Beginner's Guide — Step by Step, No Coding Knowledge Required

---

## What is Railway and Why Do We Need It?

Think of Railway like renting a small computer on the internet 24/7.

Right now your database only saves data on one tablet. If that tablet breaks — all data is gone.

With Railway:
- Your data is saved **online** (in the cloud)
- Any tablet with internet can access it
- Railway keeps **automatic backups**
- You can see everything from anywhere in the world

---

## STEP 1 — Create a Railway Account

1. Open your browser (Chrome recommended)
2. Go to: **https://railway.app**
3. Click the **"Login"** button at the top right
4. Click **"Login with GitHub"**

> If you don't have GitHub yet, go to **https://github.com** first, create a free account, then come back.

5. Approve Railway access to GitHub when it asks
6. You are now inside Railway's dashboard ✅

---

## STEP 2 — Create a New Project

1. On your Railway dashboard, click the big **"+ New Project"** button
2. A menu will pop up — choose **"Empty Project"**
3. Railway creates a blank project (it may auto-name it something random — that's fine)

---

## STEP 3 — Add a PostgreSQL Database

This is the actual database where all your hotel data will live.

1. Inside your new project, click the **"+ Add Service"** button (or the `+` icon)
2. Select **"Database"** from the list
3. Select **"Add PostgreSQL"**
4. Railway will spin up your database in about 30 seconds — you'll see a purple box appear

---

## STEP 4 — Get Your Database Connection String

This is like the "secret password address" to your database. You need to copy it.

1. Click on the **purple PostgreSQL box** in your project
2. Click the **"Variables"** tab at the top
3. You will see a variable called `DATABASE_URL`
4. Click the **copy icon** next to it

It will look something like this:
```
postgresql://postgres:AbCdEfGhIj@monorail.proxy.rlwy.net:12345/railway
```

> ⚠️ **DO NOT share this with anyone.** This is your private database key.

5. **Save this somewhere safe** — you'll need it in Step 7

---

## STEP 5 — Deploy Your Backend Server

Now we tell Railway to also host your Node.js backend (the server code).

1. Still inside your project, click **"+ Add Service"** again
2. This time choose **"GitHub Repo"**
3. Railway will ask you to connect GitHub — click **"Connect GitHub"** and authorize it
4. You'll see a list of your repositories — select **`euton-db.admin`**
5. Click **"Add Service"**

---

## STEP 6 — Set the Root Directory (CRITICAL STEP ⚠️)

This is the most important step. Your project has multiple apps inside it. You must tell Railway which folder has the server.

1. Click on your newly created backend service box (it won't be purple — it'll be a different color)
2. Click the **"Settings"** tab
3. Scroll down to find **"Root Directory"**
4. Click the edit field and type exactly: `backend_api`
5. Press **Enter** or click **Save**
6. Railway will restart and now look in the right folder ✅

---

## STEP 7 — Add Your Environment Variables

Your server needs to know the database address. We set it here.

1. Click on your backend service
2. Click the **"Variables"** tab
3. Click **"+ New Variable"** and add these one by one:

| Variable Name | Value |
|---|---|
| `DATABASE_URL` | *(paste the long postgresql:// link you copied in Step 4)* |
| `PORT` | `3000` |
| `NODE_ENV` | `production` |

4. After adding all three, click **"Deploy"** or wait for Railway to automatically redeploy

---

## STEP 8 — Watch the Build Logs

1. Click your backend service
2. Click the **"Deployments"** tab
3. Click on the latest deployment
4. You'll see logs scrolling — this is Railway building your server
5. Wait until you see:

```
✅ Server running on port 3000
✅ Database connected successfully
```

If you see any red errors, take a screenshot and send it to your developer.

---

## STEP 9 — Get Your Public URL

1. Click your backend service
2. Click the **"Settings"** tab
3. Under **"Domains"**, click **"Generate Domain"**
4. Railway gives you a public link like:
```
https://backend-api-production-xxxx.up.railway.app
```
5. **Copy this URL** — you'll use it to connect your tablet apps

---

## STEP 10 — Test That It's Working

1. Open Chrome
2. Paste your Railway URL and add `/health` at the end:
```
https://backend-api-production-xxxx.up.railway.app/health
```
3. You should see something like:
```json
{ "status": "ok", "database": "connected" }
```
That means everything is working! 🎉

---

## STEP 11 — Run Database Migrations

Your database needs tables (like spreadsheets) before it can save data.

1. In Railway, click your backend service
2. Click **"Settings"** → scroll to **"Deploy Command"**
3. Check if it says `npm start` or `node dist/index.js` — that's fine
4. The server automatically runs migrations when it starts (Prisma handles this)
5. If tables weren't created, click your service → **"Deploy"** tab → **"Redeploy"**

---

## What Happens After Setup?

Once Railway is running:

| Action | What Happens |
|---|---|
| Staff makes a sale on the tablet | Data saved to Railway database online |
| You open Boss App | You see live data from Railway |
| Railway crashes (rare) | It automatically restarts itself |
| You update code and `git push` | Railway auto-deploys the new version |
| Power goes out at hotel | Railway still running — no data lost |

---

## Troubleshooting Common Issues

### ❌ "Build failed" in Railway
- Make sure Root Directory is set to `backend_api` (Step 6)
- Check the logs for red error messages and send to developer

### ❌ Database shows "Disconnected"
- Go back and check your `DATABASE_URL` variable — it may have been entered incorrectly
- Re-copy it from the PostgreSQL service Variables tab

### ❌ "Cannot connect to server" on tablet
- Check that your Railway service has a green "Active" badge
- Make sure the tablet has working Wi-Fi
- The Railway URL may have changed — re-copy it from Step 9

### ✅ How to update your backend code in future
Every time your developer makes a change, just run:
```bash
git add .
git commit -m "Updated code"
git push
```
Railway will automatically pick up the change and redeploy — no manual action needed!

---

## Summary Checklist

- [ ] Created Railway account (linked to GitHub)
- [ ] Created New Project
- [ ] Added PostgreSQL database
- [ ] Copied DATABASE_URL
- [ ] Added GitHub repo as a service
- [ ] Set Root Directory to `backend_api`
- [ ] Added DATABASE_URL, PORT, NODE_ENV variables
- [ ] Watched deployment logs — no red errors
- [ ] Generated public domain URL
- [ ] Tested `/health` endpoint in browser ✅

---

*Password for Boss Admin App: `8890`*
*GitHub Repo: https://github.com/ceejayszn/euton-db.admin*
