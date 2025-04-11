-- FACT OrderDetails table

CREATE TABLE sales.fact_order_details(
    order_details_id character varying(64) ENCODE NOT NULL lzo,
    order_id character varying(64) ENCODE lzo,
    product_id character varying(64) ENCODE lzo,
    product_quantity bigint ENCODE az64,
    ingestion_date date ENCODE az64,
    PRIMARY KEY(order_details_id)
) DISTSTYLE AUTO
  SORTKEY AUTO;