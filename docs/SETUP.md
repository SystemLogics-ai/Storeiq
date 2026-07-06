# StoreIQ — Setup Guide

Complete setup from a fresh clone to a running app.

---

## Prerequisites

- Node.js v18 or later
- npm
- A Supabase project (free tier is fine)
- A Vercel account (for deployment)

---

## 1. Clone & Install

```bash
git clone https://github.com/SystemLogics-ai/Storeiq.git
cd Storeiq
npm install
```

---

## 2. Environment Variables

Create a `.env.local` file in the project root (this file is gitignored — never commit it):

```env
NEXT_PUBLIC_SUPABASE_URL=https://<your-project-ref>.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=<your-anon-key>
```

Find these values in your Supabase dashboard:
**Project Settings → API → Project URL** and **anon public key**.

---

## 3. Database — Run Migrations

Open your Supabase project → **SQL Editor → New query**.

### Step 1 — Schema (tables, types, RLS policies)

Paste the full contents of `supabase/migrations/0001_initial_schema.sql` and click **Run**.

This creates all tables: `products`, `sales`, `sales_items`, `orders`, `order_items`,
`suppliers`, `customers`, `order_sequences`, `invoice_sequences`, and sets up Row Level Security.

### Step 2 — RPC Functions (required for core features)

Paste the full contents of `supabase/functions/0002_rpcs.sql` and click **Run**.

This creates 9 PostgreSQL functions that power the dashboard, orders, sales, and reports pages.
**Without this step, those pages will be blank or throw errors.**

---

## 4. Supabase Storage — Create Images Bucket

1. Supabase Dashboard → **Storage** → **New bucket**
2. Name: `images`
3. Toggle **Public bucket** ON
4. Click **Create bucket**

This bucket stores product images and user avatars. The app compiles without it,
but image uploads will fail silently at runtime until it exists.

---

## 5. Sign Up for an Account

Open the app and sign up for a new account before running seed data.
The seed script references your `user_id` from Supabase Auth.

**Local:**
```bash
npm run dev
# open http://localhost:3000
```

**Or** sign up on your deployed Vercel URL.

---

## 6. Seed Demo Data (Optional)

After signing up, find your user UUID:
**Supabase Dashboard → Authentication → Users → copy your user's UUID**

Open `supabase/seed/seed.sql`, replace the placeholder `user_id` value with your UUID,
then paste the full file into **SQL Editor → New query** and click **Run**.

The seed creates:
- 23 grocery SKUs across 5 departments (Produce, Dairy, Dry Goods, Meat & Seafood, Beverages)
- 3 suppliers (produce, dairy, dry goods distributors)
- 3 store locations as customers
- 4 purchase orders
- 4 sales transactions
- 6 low-stock items and 3 out-of-stock items for dashboard testing

---

## 7. Vercel Deployment

1. Push your code to GitHub (`main` branch)
2. Import the repo in Vercel
3. Add environment variables in **Vercel → Project → Settings → Environment Variables**:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
4. Deploy — Vercel auto-deploys on every push to `main`

---

## File Reference

```
supabase/
  migrations/
    0001_initial_schema.sql   — all tables and RLS policies
  functions/
    0002_rpcs.sql             — 9 PostgreSQL functions (required)
  seed/
    seed.sql                  — demo grocery data (optional)
docs/
  AUDIT.md                    — full codebase audit report
  SETUP.md                    — this file
```

---

## Troubleshooting

**Dashboard cards show $0 / pages are blank**
→ Run `supabase/functions/0002_rpcs.sql` — the RPC functions are missing.

**Product images don't load**
→ Check `next.config.ts` hostname matches your Supabase project ref.
→ Check the `images` storage bucket exists and is public.

**"relation does not exist" errors in Supabase logs**
→ Run `supabase/migrations/0001_initial_schema.sql` first, then `0002_rpcs.sql`.
