# StoreIQ — Codebase Audit

Audit performed July 2026 on commit `ce8f10d` (pre-fix baseline).
All issues listed here have been resolved in commit `edcdfa8`.

---

## Issues Found & Fixed

### 1. Wrong Supabase Hostname — `next.config.ts`
**Severity:** High — product images fail to load for all users.

The `remotePatterns` hostname was hardcoded to the original developer's Supabase project ID (`xrlacnmgrlzodrwjrmvi.supabase.co`) instead of the StoreIQ project (`tiutypdrzmgyjfmahgeg.supabase.co`). Next.js blocks image rendering from unrecognized hostnames.

**Fix:** Updated hostname in `next.config.ts`.

---

### 2. Eight Missing PostgreSQL RPC Functions
**Severity:** Critical — orders, sales, dashboard stats, and reports are completely non-functional without these.

The TypeScript server actions call `supabase.rpc(...)` for all core business logic, but none of the corresponding PostgreSQL functions existed in the database. The app would silently return null/empty data or throw runtime errors.

**Missing functions (all created in `supabase/functions/0002_rpcs.sql`):**

| Function | Called by | Effect if missing |
|---|---|---|
| `get_dashboard_card_stats` | `dashboard.ts` | Dashboard cards show $0 |
| `get_dashboard_chart_data` | `dashboard.ts` | Chart renders empty |
| `create_new_purchase_order` | `orders.ts` | Cannot create purchase orders |
| `complete_purchase_order` | `orders.ts` | Cannot receive/complete orders |
| `get_overall_order_stats` | `orders.ts` | Order stat bar blank |
| `create_new_sale` | `sales.ts` | Cannot record sales |
| `get_overall_sales_stats` | `sales.ts` | Sales stat bar blank |
| `get_financial_report_data` | `reports.ts` | Reports page empty |

All functions use `SECURITY DEFINER SET search_path = public` and `GRANT EXECUTE TO authenticated`.

---

### 3. Stock-Restore Bug in `deleteSale` — `src/lib/actions/sales.ts`
**Severity:** High — deleting a sale permanently lost that stock from inventory.

`deleteSale()` called `.from("sales").delete()` directly. The cascade delete removed `sales_items` rows, but nothing incremented `products.amount_stock` back. The UI displayed "stock restored" but stock was never actually restored.

**Fix:** Added `delete_sale` RPC (function #9 in `0002_rpcs.sql`) that runs `UPDATE products SET amount_stock = amount_stock + quantity FROM sales_items` before deleting. Updated `src/lib/actions/sales.ts` to call the RPC.

---

### 4. Indonesian Locale & Currency Throughout
**Severity:** Medium — all money, numbers, and dates displayed in Indonesian format.

The original template was built for an Indonesian market. Every formatter was hardcoded to `id-ID` locale and `IDR` (Indonesian Rupiah).

**Files fixed:**
- `src/lib/utils/formatters.ts` — `formatCurrency`, `formatCurrencyShort`, `formatNumber`
- `src/components/features/dashboard/SalesPurchaseChart.tsx` — chart tooltip
- `src/components/features/reports/ProfitChart.tsx` — chart tooltip
- `src/components/features/orders/OrderRow.tsx` — date display
- `src/components/features/sales/SaleRow.tsx` — date display

All changed to `en-US` / `USD`.

---

### 5. Branding Leftovers — Indonesian & Generic Placeholder Text
**Severity:** Low — visible to users in form placeholders and auth screen.

- `src/app/(auth)/layout.tsx` — referenced `logo-BM.svg` (original author's logo, file deleted). Replaced with StoreIQ text logo.
- `src/components/features/inventory/AddProduct.tsx` — placeholders: `"Long Sleeve Shirt"`, `"Men's Apparel"`, `"75000"`, `"149000"`
- `src/components/features/suppliers/AddSupplier.tsx` — placeholders: `"PT. Stok Abadi"`, Indonesian address, Indonesian phone
- `src/components/features/customers/AddCustomer.tsx` — placeholders: `"Andi Budaya"`, Indonesian address, Indonesian phone

All updated to US/grocery examples.

---

### 6. Missing Supabase Storage Bucket
**Severity:** Low at build time, Medium at runtime.

The `images` bucket does not break compilation. It fails silently at runtime when:
- A user uploads a product image or avatar
- The app tries to render a Supabase Storage URL

**Resolution (manual):** Supabase Dashboard → Storage → New bucket → name: `images` → Public.

---

## Files Not Modified (Confirmed Correct)

- `src/lib/supabase/` — client, server, middleware setup correct for `@supabase/ssr`
- `src/lib/actions/` — all 11 action files structurally correct; only `sales.ts` had the bug above
- `src/lib/types.ts` — TypeScript types match database schema
- `src/app/(app)/` — all page routes correct
- `tailwind.config` / `postcss.config.mjs` — standard Tailwind 4 setup
- `next.config.ts` — correct after hostname fix

---

## Schema Dependencies

The RPCs assume these tables exist (created by `supabase/migrations/0001_initial_schema.sql`):

- `products` (`id`, `amount_stock`, `sell_price`, `buy_price`, `product_type`, `user_id`)
- `sales` (`id`, `invoice_code`, `total_amount`, `sale_date`, `user_id`, `customer_id`, ...)
- `sales_items` (`id`, `sales_id`, `product_id`, `quantity`, `price_at_sale`, `cost_at_sale`)
- `orders` (`id`, `po_code`, `status`, `total_cost`, `created_at`, `user_id`, `supplier_id`, ...)
- `order_items` (`id`, `order_id`, `product_id`, `quantity`, `cost_per_item`)
- `order_sequences` (`date_key`, `last_number`) — PO code counter
- `invoice_sequences` (`date_key`, `last_number`) — invoice code counter
- `suppliers`, `customers`

All tables are multi-tenant: every row is scoped by `user_id` (Supabase Auth UUID).
