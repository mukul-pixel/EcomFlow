-- STORED PROCEDURE FOR OUR Product Table (implementing SCD 2)

CREATE OR REPLACE PROCEDURE sales.sp_dim_product()
LANGUAGE plpgsql
AS $$
BEGIN

-- update the row if there's an 'U' or 'D' operation in staging table
UPDATE sales.dim_product
SET record_end_ts = deduped.record_start_ts - interval '1' second,
    active_flag = 0
FROM (
    with deduped_stage as (
        select *,
                row_number()over(partition by product_id order by record_start_ts desc) as rnk
        from stage_dim_product
    )
    select *
    from deduped_stage
    where rnk = 1
) deduped
where sales.dim_product.product_id = deduped.product_id
    and sales.dim_product.record_end_ts > deduped.record_start_ts
    and sales.dim_product.active_flag = 1
    and deduped.cdc_operations in ('U','D');

-- Insert a new row whenever we get a 'I' or 'U' operation

INSERT INTO sales.dim_product
    (cdc_operations, product_id, product_name,brand_name,product_description,product_price,
    product_category, hash_value, record_start_ts, record_end_ts, active_flag)
select 
    d.cdc_operations,
    d.product_id,
    d.product_name,
    d.brand_name,
    d.product_description,
    d.product_price,
    d.product_category,
    d.hash_value,
    d.record_start_ts,
    d.record_end_ts,
    d.active_flag
from (
    with deduped_product as (
        select *,
        row_number()over(partition by product_id order by record_start_ts desc) as rnk
        from sales.stage_dim_product
    )
        select *
        from deduped_product
        where rnk = 1
    ) d
where d.cdc_operations in ('I','U');

-- TRUNCATE THE Staging table
TRUNCATE TABLE sales.stage_dim_product;

END;
$$