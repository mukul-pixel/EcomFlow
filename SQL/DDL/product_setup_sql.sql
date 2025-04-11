-- DIMENSION PRODUCTS

CREATE TABLE sales.dim_product (
    cdc_operations character varying(50) ENCODE lzo,
    product_id character varying(64) NOT NULL ENCODE lzo distkey,
    product_name character varying(64) ENCODE lzo,
    brand_name character varying(64) ENCODE lzo,
    product_description character varying(65535) ENCODE lzo,
    product_price double precision ENCODE raw,
    product_category character varying(64) ENCODE lzo,
    hash_value character varying(64) ENCODE lzo,
    record_start_ts timestamp without time zone ENCODE az64,
    record_end_ts timestamp without time zone ENCODE az64,
    active_flag integer ENCODE az64,
    PRIMARY KEY(product_id)
) DISTSTYLE key;

-- STAGING TABLE PRODUCTS

CREATE TABLE sales.stage_dim_product (
    cdc_operations character varying(50) ENCODE lzo,
    product_id character varying(64) NOT NULL ENCODE lzo distkey,
    product_name character varying(64) ENCODE lzo,
    brand_name character varying(64) ENCODE lzo,
    product_description character varying(65535) ENCODE lzo,
    product_price double precision ENCODE raw,
    product_category character varying(64) ENCODE lzo,
    hash_value character varying(64) ENCODE lzo,
    record_start_ts timestamp without time zone ENCODE az64,
    record_end_ts timestamp without time zone ENCODE az64,
    active_flag integer ENCODE az64,
    PRIMARY KEY(product_id)
) BACKUP NO DISTSTYLE key;