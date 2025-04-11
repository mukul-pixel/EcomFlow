-- DIMENSION CUSTOMER
create table sales.dim_customer (
    cdc_operations character varying(50) ENCODE lzo,
    customer_id character varying(64) NOT NULL ENCODE lzo distkey,
    customer_email character varying(64) ENCODE lzo,
    customer_phone character varying(64) ENCODE lzo,
    customer_address character varying(65535) ENCODE lzo,
    customer_country character varying(64) ENCODE lzo,
    customer_city character varying(64) ENCODE lzo,
    hash_value character varying(64) ENCODE lzo,
    record_start_ts timestamp without time zone ENCODE az64,
    record_end_ts timestamp without time zone ENCODE az64,
    active_flag integer ENCODE az64,
    cust_first_name character varying(64) ENCODE lzo,
    cust_last_name character varying(64) ENCODE lzo,
    PRIMARY KEY(customer_id)
) DISTSTYLE KEY;

-- STAGING TABLE CUSTOMERS

create table sales.stage_dim_customer (
    cdc_operations character varying(50) ENCODE lzo,
    customer_id character varying(64) NOT NULL ENCODE lzo distkey,
    customer_email character varying(64) ENCODE lzo,
    customer_phone character varying(64) ENCODE lzo,
    customer_address character varying(65535) ENCODE lzo,
    customer_country character varying(64) ENCODE lzo,
    customer_city character varying(64) ENCODE lzo,
    hash_value character varying(64) ENCODE lzo,
    record_start_ts timestamp without time zone ENCODE az64,
    record_end_ts timestamp without time zone ENCODE az64,
    active_flag integer ENCODE az64,
    cust_first_name character varying(64) ENCODE lzo,
    cust_last_name character varying(64) ENCODE lzo,
    PRIMARY KEY(customer_id)
) BACKUP NO DISTSTYLE KEY;