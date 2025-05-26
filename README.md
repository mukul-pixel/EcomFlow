# EcomFlow

📦 EcomFlow – End-to-End ETL Pipeline on AWS

EcomFlow is a fully automated, end-to-end ETL data pipeline built using AWS cloud services, PySpark, SQL, and Python. It demonstrates how sales data can flow from an on-premise database into a cloud-based data warehouse, be transformed and validated, and then visualized in dashboards.

🧱 Architecture Components

1. MySQL Database:
   - Created a simulated sales database to mimic an on-premise environment.
   - This DB is connected to AWS for further processing.

2. Data Ingestion: S3 + DMS:
   - Used AWS Database Migration Service (DMS) to migrate data from MySQL to S3.
   - Raw data is stored in Parquet format in the Bronze Layer of S3.
   - Data Generation (AWS Lambda + Secrets Manager):
       - AWS Lambda generates and inserts synthetic sales data into MySQL.
       - Secrets Manager securely stores DB credentials for Lambda access.

3. AWS DMS – Migration & Replication:
   - DMS handles data migration from MySQL (source) to S3 (target).
   - Configured replication tasks to support continuous sync.

4. Data Transformation – AWS Glue & PySpark:
   - Used AWS Glue Jobs to:
       Clean and validate data (null checks, data type mismatch, remove duplicates).
       Convert raw data into transformed format (Silver Layer).
   - Glue Bookmarks used for incremental processing.
   - Data stored as Parquet files for optimized storage.

5. Glue Data Catalog:
   - Created crawlers to infer schema and register metadata.
   - Speeds up job execution by avoiding full file reads.

6. Data Warehouse – Amazon Redshift:
   - Created staging tables to load transformed data.
   - Applied SCD Type-2 logic using stored procedures.
   - Final schema includes:
       Product, Customer (Dimension tables)
       Sales (Fact table)

7. Sales Data Mart:
   - Created a separate data mart with Materialized Views for fast query performance.
   - Optimized for KPIs and dashboard use.

8. Orchestration – AWS Step Functions:
   - Automates the complete ETL pipeline:
       S3 → Glue → Redshift → QuickSight

9. Visualization – Amazon QuickSight

10. IAM & Security:
    - IAM roles created to enable secure cross-service communication.
   


<img width="1431" alt="Screenshot 2025-05-07 at 2 04 17 AM" src="https://github.com/user-attachments/assets/0dcb6640-e5ea-44b1-853c-2e18d55e744a" />


    
