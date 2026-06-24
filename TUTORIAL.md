# Complete Beginner's Guide: Deploying Your Hotel POS System

Welcome! This guide is written specifically for beginners. We will go step-by-step to get your backend server, database, and apps running on the internet using a platform called Railway.

---

## Part 1: Setting up the Database on Railway

A database is where all your sales, expenses, and employee logs will be securely saved.

1. **Create an Account**: Go to [Railway.app](https://railway.app/) and sign up (you can use your GitHub account).
2. **Start a New Project**:
   - Click the **"New Project"** button on your dashboard.
   - Select **"Provision PostgreSQL"** from the menu.
3. **Wait for Setup**: It will take a few seconds to create your database.
4. **Get Your Secret Password**:
   - Click on your new "PostgreSQL" box.
   - Go to the **"Variables"** or **"Connect"** tab at the top.
   - Look for the `DATABASE_URL`. It will look something like this: `postgresql://postgres:password@host:port/railway`.
   - **Copy this link**. You will need it in Part 2!

---

## Part 2: Putting Your Code on the Internet

Right now, your code only lives on your computer. To get it on Railway, we need to upload it to GitHub first.

### Step A: Push to GitHub
1. Create a free account on [GitHub.com](https://github.com/).
2. Create a **New Repository**. Name it `euton-hotel-pos`. Do *not* check the box to add a README.
3. Open your computer's terminal (or command prompt), make sure you are in your project folder (`C:\Users\Windows\Documents\1WORKSPACE\felixpinski`), and run these exact commands (replace the URL with your actual GitHub URL):

```bash
git remote set-url origin https://github.com/ceejayszn/euton-db.admin.git
git branch -M main
git push -u origin main
```

### Step B: Connect Railway to GitHub
1. Go back to your [Railway.app](https://railway.app/) dashboard.
2. Click **"New"** -> **"GitHub Repo"**.
3. Select the `euton-db.admin` repository you just made.
4. **CRITICAL STEP**: In your new Railway service, go to **Settings** -> **Service**. Look for **Root Directory** and type `/backend_api`. This tells Railway exactly where your server code is!

### Step C: Add the Secret Database Link
1. Click on the new Backend service that Railway just created.
2. Go to the **"Variables"** tab.
3. Click **"New Variable"**.
4. Type `DATABASE_URL` as the VARIABLE NAME.
5. Paste that long `postgresql://...` link you copied in Part 1 as the VALUE.
6. Add one more variable: Type `PORT` as the NAME, and `3000` as the VALUE.

---

## Part 3: Generating the Tables (Migrations)

Before the app can save data, the database needs to know what "Sales" and "Expenses" look like. We do this by running a migration.

1. On Railway, your backend will automatically try to build itself. 
2. Because of the code we wrote, it will automatically look at your `schema.prisma` file and create all the tables for you! You don't need to write any SQL code.
3. If it succeeds, you will see a green **"Active"** badge next to your backend on Railway.

---

## Part 4: Connecting the Operations App (Tablets)

Now your database is on the internet! Let's tell your Operations App how to talk to it.

1. In Railway, click your Backend service, go to **"Settings"**, and click **"Generate Domain"**. 
   - It will give you a public link like `https://backend-api-production.up.railway.app`. **Copy this.**
2. Open your code editor and go to your Operations app code (`operations_app/lib/main.dart` or your sync service).
3. Find where the API link is stored, and replace it with your new Railway link.
4. Build your Android app for the tablets:
```bash
cd operations_app
flutter build apk
```
5. You will find the final APK file in `operations_app/build/app/outputs/flutter-apk/app-release.apk`. Put this on your tablets!

---

## Part 5: The Boss App (For Your Laptop)

The Boss App is for you to monitor the business. You can run it directly on your computer or put it on the internet.

**To run it on your laptop right now:**
1. Open your terminal.
2. Type:
```bash
cd boss_app
flutter run -d chrome
```
3. A web browser will open. Type the master password (`boss123`) to see your business dashboard!

---

## What to do if something breaks? (Troubleshooting)

- **"My tablets aren't syncing!"**: 
  1. Check the Boss App dashboard and look at "System Health". If the Database is "Red", go to Railway.app and check if your PostgreSQL database crashed. 
  2. Make sure the tablet has a working Wi-Fi connection.
- **"I accidentally deleted data!"**:
  - Railway has an automatic backup system. Go to your PostgreSQL service on Railway, click the **"Data"** or **"Backups"** tab, and you can restore your database to how it looked yesterday.
- **"How do I update the code?"**:
  - Every time you change code on your computer, just run:
    ```bash
    git add .
    git commit -m "My updates"
    git push
    ```
  - Railway will see the update and *automatically* restart your server with the new code!
