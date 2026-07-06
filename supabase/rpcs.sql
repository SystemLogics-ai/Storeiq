-- =============================================================================
-- StoreIQ — Missing PostgreSQL RPCs
-- =============================================================================
-- Run this in the Supabase SQL Editor (Project → SQL Editor → New query).
-- Run AFTER schema.sql has been applied and at least one user has signed up.
--
-- Functions included:
--   1. get_dashboard_card_stats
--   2. get_dashboard_chart_data
--   3. create_new_purchase_order
--   4. complete_purchase_order
--   5. get_overall_order_stats
--   6. create_new_sale               ← decrements stock on sale
--   7. delete_sale                   ← restores stock on delete (bug fix)
--   8. get_overall_sales_stats
--   9. get_financial_report_data
-- =============================================================================


-- =============================================================================
-- 1. get_dashboard_card_stats
--    Returns lifetime sales totals for the dashboard summary cards.
--    Called by: src/lib/actions/dashboard.ts → getDashboardStats()
--    Return shape: DashboardCardStats { total_revenue, total_profit,
--                                       total_cost, total_qty_sold }
-- =============================================================================
CREATE OR REPLACE FUNCTION public.get_dashboard_card_stats(p_user_id uuid)
RETURNS TABLE(
  total_revenue    numeric,
  total_profit     numeric,
  total_cost       numeric,
  total_qty_sold   bigint
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT
    COALESCE(SUM(si.price_at_sale * si.quantity), 0)::numeric,
    COALESCE(SUM((si.price_at_sale - si.cost_at_sale) * si.quantity), 0)::numeric,
    COALESCE(SUM(si.cost_at_sale * si.quantity), 0)::numeric,
    COALESCE(SUM(si.quantity), 0)::bigint
  FROM public.sales s
  JOIN public.sales_items si ON si.sales_id = s.id
  WHERE s.user_id = p_user_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_dashboard_card_stats(uuid) TO authenticated;


-- =============================================================================
-- 2. get_dashboard_chart_data
--    Returns time-series data for the dashboard Sales/Purchase bar chart.
--    Called by: src/lib/actions/dashboard.ts → getDashboardStats()
--    p_period: 'weekly' | 'monthly' | 'yearly'
--    Return shape: ChartData[] { name, sales, purchase, ordered, delivered }
-- =============================================================================
CREATE OR REPLACE FUNCTION public.get_dashboard_chart_data(
  p_user_id uuid,
  p_period  text DEFAULT 'monthly'
)
RETURNS TABLE(
  name       text,
  sales      numeric,
  purchase   numeric,
  ordered    bigint,
  delivered  bigint
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN

  -- ── WEEKLY: last 7 days, labelled Mon … Sun ────────────────────────────────
  IF p_period = 'weekly' THEN
    RETURN QUERY
    WITH days AS (
      SELECT generate_series(
        date_trunc('day', NOW() AT TIME ZONE 'UTC') - INTERVAL '6 days',
        date_trunc('day', NOW() AT TIME ZONE 'UTC'),
        '1 day'::interval
      ) AS day
    ),
    sales_agg AS (
      SELECT
        date_trunc('day', s.sale_date AT TIME ZONE 'UTC') AS day,
        SUM(s.total_amount)                               AS revenue
      FROM public.sales s
      WHERE s.user_id = p_user_id
        AND s.sale_date >= NOW() - INTERVAL '6 days'
      GROUP BY 1
    ),
    order_agg AS (
      SELECT
        date_trunc('day', o.created_at AT TIME ZONE 'UTC')            AS day,
        SUM(o.total_cost)                                             AS cost,
        COUNT(o.id)                                                   AS cnt,
        COUNT(o.id) FILTER (WHERE o.status = 'Completed')            AS dlv
      FROM public.orders o
      WHERE o.user_id = p_user_id
        AND o.created_at >= NOW() - INTERVAL '6 days'
      GROUP BY 1
    )
    SELECT
      to_char(d.day, 'Dy')             AS name,
      COALESCE(sa.revenue, 0)::numeric AS sales,
      COALESCE(oa.cost,    0)::numeric AS purchase,
      COALESCE(oa.cnt,     0)::bigint  AS ordered,
      COALESCE(oa.dlv,     0)::bigint  AS delivered
    FROM days d
    LEFT JOIN sales_agg sa ON sa.day = d.day
    LEFT JOIN order_agg oa ON oa.day = d.day
    ORDER BY d.day;

  -- ── YEARLY: current-year months, labelled Jan … Dec ───────────────────────
  ELSIF p_period = 'yearly' THEN
    RETURN QUERY
    WITH months AS (
      SELECT generate_series(
        date_trunc('year',  NOW() AT TIME ZONE 'UTC'),
        date_trunc('month', NOW() AT TIME ZONE 'UTC'),
        '1 month'::interval
      ) AS month
    ),
    sales_agg AS (
      SELECT
        date_trunc('month', s.sale_date AT TIME ZONE 'UTC') AS month,
        SUM(s.total_amount)                                 AS revenue
      FROM public.sales s
      WHERE s.user_id = p_user_id
        AND EXTRACT(year FROM s.sale_date) = EXTRACT(year FROM NOW())
      GROUP BY 1
    ),
    order_agg AS (
      SELECT
        date_trunc('month', o.created_at AT TIME ZONE 'UTC')          AS month,
        SUM(o.total_cost)                                             AS cost,
        COUNT(o.id)                                                   AS cnt,
        COUNT(o.id) FILTER (WHERE o.status = 'Completed')            AS dlv
      FROM public.orders o
      WHERE o.user_id = p_user_id
        AND EXTRACT(year FROM o.created_at) = EXTRACT(year FROM NOW())
      GROUP BY 1
    )
    SELECT
      to_char(m.month, 'Mon')          AS name,
      COALESCE(sa.revenue, 0)::numeric AS sales,
      COALESCE(oa.cost,    0)::numeric AS purchase,
      COALESCE(oa.cnt,     0)::bigint  AS ordered,
      COALESCE(oa.dlv,     0)::bigint  AS delivered
    FROM months m
    LEFT JOIN sales_agg sa ON sa.month = m.month
    LEFT JOIN order_agg oa ON oa.month = m.month
    ORDER BY m.month;

  -- ── MONTHLY (default): last 4 weeks, labelled Week 1 … Week 4 ────────────
  ELSE
    RETURN QUERY
    WITH week_series AS (
      SELECT generate_series(3, 0, -1) AS wk   -- 3 = oldest, 0 = most recent
    ),
    sales_agg AS (
      SELECT
        FLOOR(EXTRACT(epoch FROM (NOW() - s.sale_date)) / (7 * 86400))::int AS wk,
        SUM(s.total_amount) AS revenue
      FROM public.sales s
      WHERE s.user_id = p_user_id
        AND s.sale_date >= NOW() - INTERVAL '28 days'
      GROUP BY 1
    ),
    order_agg AS (
      SELECT
        FLOOR(EXTRACT(epoch FROM (NOW() - o.created_at)) / (7 * 86400))::int AS wk,
        SUM(o.total_cost)                                          AS cost,
        COUNT(o.id)                                               AS cnt,
        COUNT(o.id) FILTER (WHERE o.status = 'Completed')        AS dlv
      FROM public.orders o
      WHERE o.user_id = p_user_id
        AND o.created_at >= NOW() - INTERVAL '28 days'
      GROUP BY 1
    )
    SELECT
      ('Week ' || (4 - ws.wk)::text)   AS name,
      COALESCE(sa.revenue, 0)::numeric  AS sales,
      COALESCE(oa.cost,    0)::numeric  AS purchase,
      COALESCE(oa.cnt,     0)::bigint   AS ordered,
      COALESCE(oa.dlv,     0)::bigint   AS delivered
    FROM week_series ws
    LEFT JOIN sales_agg sa ON sa.wk = ws.wk
    LEFT JOIN order_agg oa ON oa.wk = ws.wk
    ORDER BY ws.wk DESC;   -- oldest first → Week 1, Week 2, Week 3, Week 4

  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_dashboard_chart_data(uuid, text) TO authenticated;


-- =============================================================================
-- 3. create_new_purchase_order
--    Creates a PO + line items.  Does NOT touch stock — stock is only
--    incremented when the order is marked Completed (see #4).
--    Called by: src/lib/actions/orders.ts → insertOrder()
--    Returns: the new order's id (bigint)
--
--    p_items shape: [{ product_id, quantity, cost_per_item }]
-- =============================================================================
CREATE OR REPLACE FUNCTION public.create_new_purchase_order(
  p_supplier_id            bigint,
  p_status                 text,
  p_expected_delivery_date timestamptz,
  p_total_cost             numeric,
  p_user_id                uuid,
  p_items                  jsonb
)
RETURNS bigint
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_order_id    bigint;
  v_date_key    text;
  v_next_num    bigint;
  v_po_code     text;
  v_item        jsonb;
BEGIN
  v_date_key := to_char(NOW(), 'YYYYMM');

  INSERT INTO public.order_sequences (date_key, last_number)
  VALUES (v_date_key, 1)
  ON CONFLICT (date_key) DO UPDATE
    SET last_number = order_sequences.last_number + 1
  RETURNING last_number INTO v_next_num;

  v_po_code := 'PO-' || v_date_key || '-' || LPAD(v_next_num::text, 3, '0');

  INSERT INTO public.orders
    (po_code, status, total_cost, expected_delivery_date, supplier_id, user_id)
  VALUES
    (v_po_code, p_status, p_total_cost, p_expected_delivery_date, p_supplier_id, p_user_id)
  RETURNING id INTO v_order_id;

  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items) LOOP
    INSERT INTO public.order_items (order_id, product_id, quantity, cost_per_item)
    VALUES (
      v_order_id,
      (v_item->>'product_id')::bigint,
      (v_item->>'quantity')::integer,
      (v_item->>'cost_per_item')::numeric
    );
  END LOOP;

  RETURN v_order_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_new_purchase_order(bigint, text, timestamptz, numeric, uuid, jsonb) TO authenticated;


-- =============================================================================
-- 4. complete_purchase_order
--    Marks an order Completed and increments stock for every line item.
--    Called by: src/lib/actions/orders.ts → updateOrder() when status = 'Completed'
-- =============================================================================
CREATE OR REPLACE FUNCTION public.complete_purchase_order(p_order_id bigint)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.orders
  SET status = 'Completed'
  WHERE id = p_order_id;

  UPDATE public.products p
  SET amount_stock = p.amount_stock + oi.quantity
  FROM public.order_items oi
  WHERE oi.order_id = p_order_id
    AND oi.product_id = p.id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.complete_purchase_order(bigint) TO authenticated;


-- =============================================================================
-- 5. get_overall_order_stats
--    Summary counters for the Orders page stat bar.
--    Called by: src/lib/actions/orders.ts → getOverallOrderStats()
--    Return shape: OrderStatsData { pending_count, shipped_count,
--                                   pending_value, completed_30d_count }
-- =============================================================================
CREATE OR REPLACE FUNCTION public.get_overall_order_stats(p_user_id uuid)
RETURNS TABLE(
  pending_count       bigint,
  shipped_count       bigint,
  pending_value       numeric,
  completed_30d_count bigint
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT
    COUNT(o.id) FILTER (WHERE o.status = 'Pending')::bigint,
    COUNT(o.id) FILTER (WHERE o.status = 'Shipped')::bigint,
    COALESCE(SUM(o.total_cost) FILTER (WHERE o.status = 'Pending'), 0)::numeric,
    COUNT(o.id) FILTER (
      WHERE o.status = 'Completed'
        AND o.created_at >= NOW() - INTERVAL '30 days'
    )::bigint
  FROM public.orders o
  WHERE o.user_id = p_user_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_overall_order_stats(uuid) TO authenticated;


-- =============================================================================
-- 6. create_new_sale
--    Creates a sale + line items.  Captures current sell/buy prices,
--    decrements stock for every item, and validates stock availability first.
--    Called by: src/lib/actions/sales.ts → insertSale()
--    Returns: new sale id (bigint)
--
--    p_items shape: [{ product_id, quantity }]
-- =============================================================================
CREATE OR REPLACE FUNCTION public.create_new_sale(
  p_user_id        uuid,
  p_customer_id    bigint,
  p_payment_method text,
  p_payment_status text,
  p_sale_date      timestamptz,
  p_notes          text,
  p_items          jsonb
)
RETURNS bigint
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_sale_id       bigint;
  v_date_key      text;
  v_next_num      bigint;
  v_invoice_code  text;
  v_item          jsonb;
  v_product_id    bigint;
  v_quantity      integer;
  v_sell_price    numeric;
  v_buy_price     numeric;
  v_current_stock integer;
  v_total_amount  numeric := 0;
BEGIN
  -- ── Stock validation pass ─────────────────────────────────────────────────
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items) LOOP
    v_product_id := (v_item->>'product_id')::bigint;
    v_quantity   := (v_item->>'quantity')::integer;

    SELECT amount_stock INTO v_current_stock
    FROM public.products WHERE id = v_product_id;

    IF v_current_stock IS NULL THEN
      RAISE EXCEPTION 'Product ID % not found.', v_product_id;
    END IF;

    IF v_current_stock < v_quantity THEN
      RAISE EXCEPTION
        'Insufficient stock for product ID %. Available: %, requested: %.',
        v_product_id, v_current_stock, v_quantity;
    END IF;
  END LOOP;

  -- ── Invoice code generation ───────────────────────────────────────────────
  v_date_key := to_char(NOW(), 'YYYYMM');

  INSERT INTO public.invoice_sequences (date_key, last_number)
  VALUES (v_date_key, 1)
  ON CONFLICT (date_key) DO UPDATE
    SET last_number = invoice_sequences.last_number + 1
  RETURNING last_number INTO v_next_num;

  v_invoice_code := 'INV-' || v_date_key || '-' || LPAD(v_next_num::text, 3, '0');

  -- ── Calculate total amount from current prices ────────────────────────────
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items) LOOP
    v_product_id := (v_item->>'product_id')::bigint;
    v_quantity   := (v_item->>'quantity')::integer;
    SELECT sell_price INTO v_sell_price FROM public.products WHERE id = v_product_id;
    v_total_amount := v_total_amount + (v_sell_price * v_quantity);
  END LOOP;

  -- ── Insert sale header ────────────────────────────────────────────────────
  INSERT INTO public.sales
    (invoice_code, total_amount, payment_method, payment_status,
     sale_date, notes, customer_id, user_id)
  VALUES
    (v_invoice_code, v_total_amount, p_payment_method, p_payment_status,
     p_sale_date, p_notes, p_customer_id, p_user_id)
  RETURNING id INTO v_sale_id;

  -- ── Insert line items + decrement stock ───────────────────────────────────
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items) LOOP
    v_product_id := (v_item->>'product_id')::bigint;
    v_quantity   := (v_item->>'quantity')::integer;

    SELECT sell_price, buy_price
    INTO v_sell_price, v_buy_price
    FROM public.products WHERE id = v_product_id;

    INSERT INTO public.sales_items
      (sales_id, product_id, quantity, price_at_sale, cost_at_sale)
    VALUES
      (v_sale_id, v_product_id, v_quantity, v_sell_price, v_buy_price);

    UPDATE public.products
    SET amount_stock = amount_stock - v_quantity
    WHERE id = v_product_id;
  END LOOP;

  RETURN v_sale_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_new_sale(uuid, bigint, text, text, timestamptz, text, jsonb) TO authenticated;


-- =============================================================================
-- 7. delete_sale  ← BUG FIX
--    The TypeScript deleteSale() action was directly deleting from the sales
--    table and saying "stock restored" — but it never restored stock.
--    This function restores stock for every line item BEFORE deleting the sale.
--    The TypeScript action has been updated to call this RPC instead.
--
--    Note: Only call this for non-Paid sales (the TS layer already guards this).
-- =============================================================================
CREATE OR REPLACE FUNCTION public.delete_sale(p_sale_id bigint)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Restore stock
  UPDATE public.products p
  SET amount_stock = p.amount_stock + si.quantity
  FROM public.sales_items si
  WHERE si.sales_id = p_sale_id
    AND si.product_id = p.id;

  -- Delete sale (cascades to sales_items)
  DELETE FROM public.sales WHERE id = p_sale_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.delete_sale(bigint) TO authenticated;


-- =============================================================================
-- 8. get_overall_sales_stats
--    Summary counters for the Sales page stat bar.
--    Called by: src/lib/actions/sales.ts → getOverallSalesStats()
--    Return shape: SalesStatsData { total_revenue, total_profit,
--                                   total_transactions, today_revenue }
-- =============================================================================
CREATE OR REPLACE FUNCTION public.get_overall_sales_stats(p_user_id uuid)
RETURNS TABLE(
  total_revenue      numeric,
  total_profit       numeric,
  total_transactions bigint,
  today_revenue      numeric
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT
    COALESCE(SUM(s.total_amount), 0)::numeric,
    COALESCE(SUM((si.price_at_sale - si.cost_at_sale) * si.quantity), 0)::numeric,
    COUNT(DISTINCT s.id)::bigint,
    COALESCE(SUM(s.total_amount) FILTER (
      WHERE s.sale_date >= date_trunc('day', NOW() AT TIME ZONE 'UTC')
    ), 0)::numeric
  FROM public.sales s
  LEFT JOIN public.sales_items si ON si.sales_id = s.id
  WHERE s.user_id = p_user_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_overall_sales_stats(uuid) TO authenticated;


-- =============================================================================
-- 9. get_financial_report_data
--    Builds the full ReportData payload for the Reports page.
--    Called by: src/lib/actions/reports.ts → getReportData()
--    Returns jsonb:
--      {
--        summary: { totalRevenue, totalCost, grossProfit,
--                   marginPercent, totalTransactions },
--        chartData: [{ date, revenue, profit }],          ← daily
--        categoryPerformance: [{ category, sales, profit }]
--      }
-- =============================================================================
CREATE OR REPLACE FUNCTION public.get_financial_report_data(
  p_user_id    uuid,
  p_start_date timestamptz,
  p_end_date   timestamptz
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_total_revenue      numeric;
  v_total_cost         numeric;
  v_gross_profit       numeric;
  v_margin_percent     numeric;
  v_total_transactions bigint;
  v_chart_data         jsonb;
  v_category_data      jsonb;
BEGIN
  -- ── Summary ───────────────────────────────────────────────────────────────
  SELECT
    COALESCE(SUM(si.price_at_sale * si.quantity), 0),
    COALESCE(SUM(si.cost_at_sale  * si.quantity), 0),
    COUNT(DISTINCT s.id)
  INTO v_total_revenue, v_total_cost, v_total_transactions
  FROM public.sales s
  JOIN public.sales_items si ON si.sales_id = s.id
  WHERE s.user_id = p_user_id
    AND s.sale_date BETWEEN p_start_date AND p_end_date;

  v_gross_profit   := v_total_revenue - v_total_cost;
  v_margin_percent := CASE
    WHEN v_total_revenue > 0
    THEN ROUND((v_gross_profit / v_total_revenue) * 100, 2)
    ELSE 0
  END;

  -- ── Daily chart data ──────────────────────────────────────────────────────
  SELECT jsonb_agg(
    jsonb_build_object(
      'date',    to_char(gs.day, 'YYYY-MM-DD'),
      'revenue', COALESCE(daily.revenue, 0),
      'profit',  COALESCE(daily.profit,  0)
    ) ORDER BY gs.day
  )
  INTO v_chart_data
  FROM generate_series(
    p_start_date::date,
    p_end_date::date,
    '1 day'::interval
  ) AS gs(day)
  LEFT JOIN (
    SELECT
      date_trunc('day', s.sale_date)::date        AS sale_day,
      SUM(si.price_at_sale * si.quantity)          AS revenue,
      SUM((si.price_at_sale - si.cost_at_sale) * si.quantity) AS profit
    FROM public.sales s
    JOIN public.sales_items si ON si.sales_id = s.id
    WHERE s.user_id = p_user_id
      AND s.sale_date BETWEEN p_start_date AND p_end_date
    GROUP BY 1
  ) daily ON daily.sale_day = gs.day::date;

  -- ── Category performance ──────────────────────────────────────────────────
  SELECT jsonb_agg(cat)
  INTO v_category_data
  FROM (
    SELECT jsonb_build_object(
      'category', p.product_type,
      'sales',    SUM(si.price_at_sale * si.quantity),
      'profit',   SUM((si.price_at_sale - si.cost_at_sale) * si.quantity)
    ) AS cat
    FROM public.sales s
    JOIN public.sales_items si ON si.sales_id = s.id
    JOIN public.products    p  ON p.id = si.product_id
    WHERE s.user_id = p_user_id
      AND s.sale_date BETWEEN p_start_date AND p_end_date
    GROUP BY p.product_type
  ) subq;

  RETURN jsonb_build_object(
    'summary', jsonb_build_object(
      'totalRevenue',      v_total_revenue,
      'totalCost',         v_total_cost,
      'grossProfit',       v_gross_profit,
      'marginPercent',     v_margin_percent,
      'totalTransactions', v_total_transactions
    ),
    'chartData',           COALESCE(v_chart_data,    '[]'::jsonb),
    'categoryPerformance', COALESCE(v_category_data, '[]'::jsonb)
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_financial_report_data(uuid, timestamptz, timestamptz) TO authenticated;
