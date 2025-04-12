CREATE MATERIALIZED VIEW sales.mv_uk_sales_mart
AUTO REFRESH YES
AS
SELECT 
        fo.order_id,
        fo.order_date,
        fo.payment_method,
        fo.order_platform,
        fo.order_month,
        fo.order_year,
        fod.order_details_id,
        fod.product_quantity,
        dp.product_name,
        dp.brand_name,
        dp.product_category,
        (dp.product_price * fod.product_quantity) as lineitem_revenue,
        dc.customer_city,
        dc.customer_country
FROM sales.fact_orders fo
JOIN sales.fact_order_details fod ON fod.order_id = fo.order_id
JOIN sales.dim_product dp ON dp.product_id = fod.product_id and fo.order_date BETWEEN CAST(dp.record_start_ts as date) and CAST(dp.record_end_ts as date)
JOIN sales.dim_customer dc on dc.customer_id = fo.order_customer_id and fo.order_date BETWEEN CAST(dc.record_start_ts as date) and CAST(dc.record_end_ts as date)
