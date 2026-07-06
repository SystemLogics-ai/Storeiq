-- =============================================================================
-- StoreIQ Demo Seed Data — Latin Grocery Chain (3 locations)
-- =============================================================================
-- Run this in the Supabase SQL Editor AFTER creating your first account.
-- It auto-detects your user ID from the users table.
-- =============================================================================

DO $$
DECLARE
  v_user_id uuid;
  v_supplier_produce  bigint;
  v_supplier_latin    bigint;
  v_supplier_seafood  bigint;
  v_prod_platanos     bigint;
  v_prod_yuca         bigint;
  v_prod_tomates      bigint;
  v_prod_aguacate     bigint;
  v_prod_jalapeños    bigint;
  v_prod_queso        bigint;
  v_prod_crema        bigint;
  v_prod_leche        bigint;
  v_prod_mantequilla  bigint;
  v_prod_arroz        bigint;
  v_prod_frijoles     bigint;
  v_prod_masa         bigint;
  v_prod_sofrito      bigint;
  v_prod_aceite       bigint;
  v_prod_sazon        bigint;
  v_prod_chuletas     bigint;
  v_prod_pollo        bigint;
  v_prod_camarones    bigint;
  v_prod_bistec       bigint;
  v_prod_jugo         bigint;
  v_prod_malta        bigint;
  v_prod_coco         bigint;
  v_prod_cafe         bigint;
  v_cust_havana       bigint;
  v_cust_hialeah      bigint;
  v_cust_doral        bigint;
  v_order_id          bigint;
  v_sale_id           bigint;
BEGIN

  -- Detect user
  SELECT id INTO v_user_id FROM public.users LIMIT 1;
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'No user found. Sign up first, then run this seed.';
  END IF;

  -- ==========================================================================
  -- SUPPLIERS
  -- ==========================================================================
  INSERT INTO public.suppliers (supplier_name, contact_number, address, purchase_link, user_id)
  VALUES ('Fresh Farms Produce Co.', '(305) 234-5678', '1200 NW 22nd Ave, Miami, FL 33125', 'https://freshfarmsproduce.com', v_user_id)
  RETURNING id INTO v_supplier_produce;

  INSERT INTO public.suppliers (supplier_name, contact_number, address, purchase_link, user_id)
  VALUES ('Latin Foods Distributors', '(305) 345-6789', '8400 W Flagler St, Miami, FL 33144', 'https://latinfoodsdist.com', v_user_id)
  RETURNING id INTO v_supplier_latin;

  INSERT INTO public.suppliers (supplier_name, contact_number, address, purchase_link, user_id)
  VALUES ('Coastal Seafood & Meats', '(305) 456-7890', '3100 NW 79th St, Miami, FL 33147', 'https://coastalseafoodmiami.com', v_user_id)
  RETURNING id INTO v_supplier_seafood;

  -- ==========================================================================
  -- STORE LOCATIONS (as Customers — 3-location chain)
  -- ==========================================================================
  INSERT INTO public.customers (name, contact_number, address, user_id)
  VALUES ('StoreIQ — Little Havana', '(305) 111-0001', '1430 SW 8th St, Miami, FL 33135', v_user_id)
  RETURNING id INTO v_cust_havana;

  INSERT INTO public.customers (name, contact_number, address, user_id)
  VALUES ('StoreIQ — Hialeah', '(305) 111-0002', '790 W 49th St, Hialeah, FL 33012', v_user_id)
  RETURNING id INTO v_cust_hialeah;

  INSERT INTO public.customers (name, contact_number, address, user_id)
  VALUES ('StoreIQ — Doral', '(305) 111-0003', '10300 NW 41st St, Doral, FL 33178', v_user_id)
  RETURNING id INTO v_cust_doral;

  -- ==========================================================================
  -- PRODUCTS — PRODUCE
  -- ==========================================================================
  INSERT INTO public.products (product_name, product_type, product_category, amount_stock, buy_price, sell_price, supplier_id, user_id)
  VALUES ('Plátanos Maduros', 'produce', 'Plantains', 45, 0.35, 0.75, v_supplier_produce, v_user_id)
  RETURNING id INTO v_prod_platanos;

  INSERT INTO public.products (product_name, product_type, product_category, amount_stock, buy_price, sell_price, supplier_id, user_id)
  VALUES ('Yuca Fresca (lb)', 'produce', 'Root Vegetables', 8, 0.45, 0.99, v_supplier_produce, v_user_id)
  RETURNING id INTO v_prod_yuca;

  INSERT INTO public.products (product_name, product_type, product_category, amount_stock, buy_price, sell_price, supplier_id, user_id)
  VALUES ('Tomates Vine (lb)', 'produce', 'Vegetables', 62, 0.60, 1.29, v_supplier_produce, v_user_id)
  RETURNING id INTO v_prod_tomates;

  INSERT INTO public.products (product_name, product_type, product_category, amount_stock, buy_price, sell_price, supplier_id, user_id)
  VALUES ('Aguacate Hass', 'produce', 'Avocados', 0, 0.90, 1.99, v_supplier_produce, v_user_id)
  RETURNING id INTO v_prod_aguacate;

  INSERT INTO public.products (product_name, product_type, product_category, amount_stock, buy_price, sell_price, supplier_id, user_id)
  VALUES ('Chiles Jalapeños (lb)', 'produce', 'Peppers', 15, 0.40, 0.89, v_supplier_produce, v_user_id)
  RETURNING id INTO v_prod_jalapeños;

  -- ==========================================================================
  -- PRODUCTS — DAIRY
  -- ==========================================================================
  INSERT INTO public.products (product_name, product_type, product_category, amount_stock, buy_price, sell_price, supplier_id, user_id)
  VALUES ('Queso Fresco (5 lb)', 'dairy', 'Cheese', 22, 8.50, 14.99, v_supplier_latin, v_user_id)
  RETURNING id INTO v_prod_queso;

  INSERT INTO public.products (product_name, product_type, product_category, amount_stock, buy_price, sell_price, supplier_id, user_id)
  VALUES ('Crema Mexicana (pint)', 'dairy', 'Cream', 6, 2.10, 3.99, v_supplier_latin, v_user_id)
  RETURNING id INTO v_prod_crema;

  INSERT INTO public.products (product_name, product_type, product_category, amount_stock, buy_price, sell_price, supplier_id, user_id)
  VALUES ('Leche Entera (gallon)', 'dairy', 'Milk', 35, 2.80, 4.49, v_supplier_latin, v_user_id)
  RETURNING id INTO v_prod_leche;

  INSERT INTO public.products (product_name, product_type, product_category, amount_stock, buy_price, sell_price, supplier_id, user_id)
  VALUES ('Mantequilla (16 oz)', 'dairy', 'Butter', 3, 3.20, 5.49, v_supplier_latin, v_user_id)
  RETURNING id INTO v_prod_mantequilla;

  -- ==========================================================================
  -- PRODUCTS — DRY GOODS & PANTRY
  -- ==========================================================================
  INSERT INTO public.products (product_name, product_type, product_category, amount_stock, buy_price, sell_price, supplier_id, user_id)
  VALUES ('Arroz Largo (25 lb bag)', 'dry-goods', 'Rice', 90, 12.00, 18.99, v_supplier_latin, v_user_id)
  RETURNING id INTO v_prod_arroz;

  INSERT INTO public.products (product_name, product_type, product_category, amount_stock, buy_price, sell_price, supplier_id, user_id)
  VALUES ('Frijoles Negros (10 lb)', 'dry-goods', 'Beans', 55, 6.50, 10.99, v_supplier_latin, v_user_id)
  RETURNING id INTO v_prod_frijoles;

  INSERT INTO public.products (product_name, product_type, product_category, amount_stock, buy_price, sell_price, supplier_id, user_id)
  VALUES ('Masa Harina (5 lb)', 'dry-goods', 'Flour', 12, 3.40, 5.99, v_supplier_latin, v_user_id)
  RETURNING id INTO v_prod_masa;

  INSERT INTO public.products (product_name, product_type, product_category, amount_stock, buy_price, sell_price, supplier_id, user_id)
  VALUES ('Sofrito Goya (24 oz)', 'dry-goods', 'Seasoning', 7, 2.20, 3.79, v_supplier_latin, v_user_id)
  RETURNING id INTO v_prod_sofrito;

  INSERT INTO public.products (product_name, product_type, product_category, amount_stock, buy_price, sell_price, supplier_id, user_id)
  VALUES ('Aceite de Oliva (32 oz)', 'dry-goods', 'Oil', 0, 5.80, 9.99, v_supplier_latin, v_user_id)
  RETURNING id INTO v_prod_aceite;

  INSERT INTO public.products (product_name, product_type, product_category, amount_stock, buy_price, sell_price, supplier_id, user_id)
  VALUES ('Sazón con Culantro (18-pk)', 'dry-goods', 'Seasoning', 48, 1.50, 2.79, v_supplier_latin, v_user_id)
  RETURNING id INTO v_prod_sazon;

  -- ==========================================================================
  -- PRODUCTS — MEAT & SEAFOOD
  -- ==========================================================================
  INSERT INTO public.products (product_name, product_type, product_category, amount_stock, buy_price, sell_price, supplier_id, user_id)
  VALUES ('Chuletas de Cerdo (lb)', 'meat-seafood', 'Pork', 18, 2.90, 5.49, v_supplier_seafood, v_user_id)
  RETURNING id INTO v_prod_chuletas;

  INSERT INTO public.products (product_name, product_type, product_category, amount_stock, buy_price, sell_price, supplier_id, user_id)
  VALUES ('Pollo Entero (avg 4 lb)', 'meat-seafood', 'Poultry', 30, 4.20, 7.99, v_supplier_seafood, v_user_id)
  RETURNING id INTO v_prod_pollo;

  INSERT INTO public.products (product_name, product_type, product_category, amount_stock, buy_price, sell_price, supplier_id, user_id)
  VALUES ('Camarones Medianos (2 lb)', 'meat-seafood', 'Seafood', 5, 7.50, 13.99, v_supplier_seafood, v_user_id)
  RETURNING id INTO v_prod_camarones;

  INSERT INTO public.products (product_name, product_type, product_category, amount_stock, buy_price, sell_price, supplier_id, user_id)
  VALUES ('Bistec de Res (lb)', 'meat-seafood', 'Beef', 0, 5.20, 9.49, v_supplier_seafood, v_user_id)
  RETURNING id INTO v_prod_bistec;

  -- ==========================================================================
  -- PRODUCTS — BEVERAGES
  -- ==========================================================================
  INSERT INTO public.products (product_name, product_type, product_category, amount_stock, buy_price, sell_price, supplier_id, user_id)
  VALUES ('Jugo de Naranja (gallon)', 'beverages', 'Juice', 40, 3.10, 5.49, v_supplier_latin, v_user_id)
  RETURNING id INTO v_prod_jugo;

  INSERT INTO public.products (product_name, product_type, product_category, amount_stock, buy_price, sell_price, supplier_id, user_id)
  VALUES ('Malta Hatuey (6-pack)', 'beverages', 'Malt Beverage', 25, 4.50, 7.99, v_supplier_latin, v_user_id)
  RETURNING id INTO v_prod_malta;

  INSERT INTO public.products (product_name, product_type, product_category, amount_stock, buy_price, sell_price, supplier_id, user_id)
  VALUES ('Agua de Coco Natural (33 oz)', 'beverages', 'Water', 9, 1.80, 3.29, v_supplier_latin, v_user_id)
  RETURNING id INTO v_prod_coco;

  INSERT INTO public.products (product_name, product_type, product_category, amount_stock, buy_price, sell_price, supplier_id, user_id)
  VALUES ('Café Bustelo (10 oz)', 'beverages', 'Coffee', 55, 4.20, 7.49, v_supplier_latin, v_user_id)
  RETURNING id INTO v_prod_cafe;

  -- ==========================================================================
  -- PURCHASE ORDERS
  -- ==========================================================================

  -- PO-1: Completed restock from Fresh Farms
  INSERT INTO public.orders (po_code, status, total_cost, expected_delivery_date, supplier_id, user_id)
  VALUES ('PO-202506-001', 'Completed', 248.50, NOW() - INTERVAL '20 days', v_supplier_produce, v_user_id)
  RETURNING id INTO v_order_id;

  INSERT INTO public.order_items (order_id, product_id, quantity, cost_per_item)
  VALUES
    (v_order_id, v_prod_platanos, 100, 0.35),
    (v_order_id, v_prod_tomates,  80, 0.60),
    (v_order_id, v_prod_jalapeños, 50, 0.40);

  -- PO-2: Completed restock from Latin Foods
  INSERT INTO public.orders (po_code, status, total_cost, expected_delivery_date, supplier_id, user_id)
  VALUES ('PO-202506-002', 'Completed', 1145.00, NOW() - INTERVAL '15 days', v_supplier_latin, v_user_id)
  RETURNING id INTO v_order_id;

  INSERT INTO public.order_items (order_id, product_id, quantity, cost_per_item)
  VALUES
    (v_order_id, v_prod_arroz,    50, 12.00),
    (v_order_id, v_prod_frijoles, 40,  6.50),
    (v_order_id, v_prod_sazon,    60,  1.50),
    (v_order_id, v_prod_cafe,     50,  4.20);

  -- PO-3: Shipped (in transit) from Coastal Seafood
  INSERT INTO public.orders (po_code, status, total_cost, expected_delivery_date, supplier_id, user_id)
  VALUES ('PO-202507-001', 'Shipped', 462.00, NOW() + INTERVAL '2 days', v_supplier_seafood, v_user_id)
  RETURNING id INTO v_order_id;

  INSERT INTO public.order_items (order_id, product_id, quantity, cost_per_item)
  VALUES
    (v_order_id, v_prod_pollo,    40, 4.20),
    (v_order_id, v_prod_chuletas, 30, 2.90),
    (v_order_id, v_prod_camarones,20, 7.50),
    (v_order_id, v_prod_bistec,   20, 5.20);

  -- PO-4: Pending restock for out-of-stock produce items
  INSERT INTO public.orders (po_code, status, total_cost, expected_delivery_date, supplier_id, user_id)
  VALUES ('PO-202507-002', 'Pending', 315.00, NOW() + INTERVAL '5 days', v_supplier_produce, v_user_id)
  RETURNING id INTO v_order_id;

  INSERT INTO public.order_items (order_id, product_id, quantity, cost_per_item)
  VALUES
    (v_order_id, v_prod_aguacate, 150, 0.90),
    (v_order_id, v_prod_yuca,     100, 0.45);

  -- ==========================================================================
  -- SALES
  -- ==========================================================================

  -- Sale 1 — Little Havana, large basket
  INSERT INTO public.sales (invoice_code, sale_date, total_amount, payment_method, payment_status, customer_id, user_id)
  VALUES ('INV-202507-001', NOW() - INTERVAL '3 days', 142.60, 'Cash', 'Paid', v_cust_havana, v_user_id)
  RETURNING id INTO v_sale_id;

  INSERT INTO public.sales_items (sales_id, product_id, quantity, price_at_sale, cost_at_sale)
  VALUES
    (v_sale_id, v_prod_arroz,    3, 18.99, 12.00),
    (v_sale_id, v_prod_frijoles, 2, 10.99,  6.50),
    (v_sale_id, v_prod_pollo,    4,  7.99,  4.20),
    (v_sale_id, v_prod_cafe,     2,  7.49,  4.20),
    (v_sale_id, v_prod_queso,    1, 14.99,  8.50),
    (v_sale_id, v_prod_platanos, 6,  0.75,  0.35);

  -- Sale 2 — Hialeah
  INSERT INTO public.sales (invoice_code, sale_date, total_amount, payment_method, payment_status, customer_id, user_id)
  VALUES ('INV-202507-002', NOW() - INTERVAL '2 days', 78.34, 'Transfer', 'Paid', v_cust_hialeah, v_user_id)
  RETURNING id INTO v_sale_id;

  INSERT INTO public.sales_items (sales_id, product_id, quantity, price_at_sale, cost_at_sale)
  VALUES
    (v_sale_id, v_prod_leche,     4,  4.49, 2.80),
    (v_sale_id, v_prod_malta,     3,  7.99, 4.50),
    (v_sale_id, v_prod_sazon,     5,  2.79, 1.50),
    (v_sale_id, v_prod_chuletas,  4,  5.49, 2.90),
    (v_sale_id, v_prod_tomates,   6,  1.29, 0.60);

  -- Sale 3 — Doral, unpaid (debt)
  INSERT INTO public.sales (invoice_code, sale_date, total_amount, payment_method, payment_status, customer_id, user_id)
  VALUES ('INV-202507-003', NOW() - INTERVAL '1 day', 95.12, 'Transfer', 'Debt', v_cust_doral, v_user_id)
  RETURNING id INTO v_sale_id;

  INSERT INTO public.sales_items (sales_id, product_id, quantity, price_at_sale, cost_at_sale)
  VALUES
    (v_sale_id, v_prod_arroz,    2, 18.99, 12.00),
    (v_sale_id, v_prod_camarones,2, 13.99,  7.50),
    (v_sale_id, v_prod_jugo,     3,  5.49,  3.10),
    (v_sale_id, v_prod_queso,    1, 14.99,  8.50),
    (v_sale_id, v_prod_masa,     2,  5.99,  3.40);

  -- Sale 4 — Little Havana, today
  INSERT INTO public.sales (invoice_code, sale_date, total_amount, payment_method, payment_status, customer_id, user_id)
  VALUES ('INV-202507-004', NOW(), 53.27, 'Cash', 'Paid', v_cust_havana, v_user_id)
  RETURNING id INTO v_sale_id;

  INSERT INTO public.sales_items (sales_id, product_id, quantity, price_at_sale, cost_at_sale)
  VALUES
    (v_sale_id, v_prod_cafe,     3,  7.49, 4.20),
    (v_sale_id, v_prod_coco,     2,  3.29, 1.80),
    (v_sale_id, v_prod_sofrito,  2,  3.79, 2.20),
    (v_sale_id, v_prod_jalapeños,4,  0.89, 0.40),
    (v_sale_id, v_prod_mantequilla,1,5.49, 3.20);

  RAISE NOTICE 'StoreIQ seed complete. User: %', v_user_id;
  RAISE NOTICE 'Suppliers: 3 | Products: 23 | Orders: 4 | Sales: 4';
  RAISE NOTICE 'Low stock items: Yuca, Crema Mexicana, Mantequilla, Sofrito, Camarones, Agua de Coco';
  RAISE NOTICE 'Out of stock: Aguacate Hass, Aceite de Oliva, Bistec de Res';

END $$;
