-- STORED PROCEDURE FOR OUR Customer Table (implementing SCD 2)

CREATE OR REPLACE PROCEDURE sales.sp_dim_customer()
LANGUAGE plpgsql
AS $$
BEGIN

-- update the row if there's an 'U' or 'D' operation in staging table
UPDATE sales.dim_customer
SET record_end_ts = deduped.record_start_ts - interval '1' second,
    active_flag = 0
FROM (
    with deduped_stage as (
        select *,
                row_number()over(partition by customer_id order by record_start_ts desc) as rnk
        from sales.stage_dim_customer
    )
    select *
    from deduped_stage
    where rnk = 1
) deduped
where sales.dim_customer.customer_id = deduped.customer_id
    and sales.dim_customer.record_end_ts > deduped.record_start_ts
    and sales.dim_customer.active_flag = 1
    and deduped.cdc_operations in ('U','D');

-- Insert a new row whenever we get a 'I' or 'U' operation

INSERT INTO sales.dim_customer
    (cdc_operations, customer_id, customer_email,customer_phone,customer_address,customer_city,
    customer_country, hash_value, record_start_ts, record_end_ts, active_flag, cust_first_name,
    cust_last_name)
select 
    d.cdc_operations,
    d.customer_id,
    d.customer_email,
    d.customer_phone,
    d.customer_address,
    d.customer_city,
    d.customer_country,
    d.hash_value,
    d.record_start_ts,
    d.record_end_ts,
    d.active_flag,
    d.cust_first_name,
    d.cust_last_name
from (
    with deduped_customer as (
        select *,
        row_number()over(partition by customer_id order by record_start_ts desc) as rnk
        from sales.stage_dim_customer
    )
        select *
        from deduped_customer
        where rnk = 1
    ) d
where d.cdc_operations in ('I','U');

-- TRUNCATE THE Staging table
TRUNCATE TABLE sales.stage_dim_customer;

END;
$$