# Phase 1 - Step 4: Load Data to Snowflake

## Overview
This guide walks you through uploading synthetic data files to Snowflake and loading them into raw tables.

---

## Step 4a: Create Raw Tables (SQL)

**In your Snowflake trial account:**

1. Open the Snowflake web UI: `STBPLNO-WK22236.snowflakecomputing.com`
2. Login with your credentials (AMRITKESHRI12345)
3. Click **Worksheets** → **+ New Worksheet**
4. Open the file: `01_create_raw_tables.sql` (from your project folder)
5. Copy all the SQL and paste it into the worksheet
6. Select all with Ctrl+A, then click **Run All**

**Expected output:**
- Multiple `Table [...] successfully created` messages
- SHOW TABLES commands listing all 11 tables

---

## Step 4b: Upload Files to Snowflake Stages

### Option 1: Using Snowflake Web UI (Easiest)

1. **In Snowflake, navigate to:**
   - Click **Data** → **Databases** → **EXTERNAL_STAGES_DB** → **STAGES**

2. **Upload to ECOMMERCE_STAGE:**
   - Click the **ECOMMERCE_STAGE** stage
   - Click **Upload Files** button
   - Select these files from your `synthetic_data/` folder:
     - `customers.csv`
     - `products.csv`
     - `promotions.csv`
     - `orders.csv`
     - `order_items.csv`
     - `reviews.csv`
   - Click **Upload**

3. **Upload to FINTECH_STAGE:**
   - Click the **FINTECH_STAGE** stage
   - Click **Upload Files** button
   - Select these files:
     - `transactions.csv`
     - `chargebacks.csv`
     - `returns.csv`
     - `complaints.csv`
   - Click **Upload**

4. **Upload to EVENTS_STAGE:**
   - Click the **EVENTS_STAGE** stage
   - Click **Upload Files** button
   - Select:
     - `events.csv`
   - Click **Upload**

**Note:** File sizes will be large (events.csv is ~158 MB). Upload may take a few minutes.

---

### Option 2: Using SnowSQL CLI (Command Line)

If you have SnowSQL installed, you can use this command to upload files:

```bash
# Download SnowSQL from: https://developers.snowflake.com/snowsql/

# Then run (from your synthetic_data folder):
snowsql -a STBPLNO-WK22236 -u AMRITKESHRI12345

# In SnowSQL, run:
PUT file://<full-path>/synthetic_data/customers.csv @EXTERNAL_STAGES_DB.STAGES.ECOMMERCE_STAGE;
PUT file://<full-path>/synthetic_data/products.csv @EXTERNAL_STAGES_DB.STAGES.ECOMMERCE_STAGE;
PUT file://<full-path>/synthetic_data/promotions.csv @EXTERNAL_STAGES_DB.STAGES.ECOMMERCE_STAGE;
PUT file://<full-path>/synthetic_data/orders.csv @EXTERNAL_STAGES_DB.STAGES.ECOMMERCE_STAGE;
PUT file://<full-path>/synthetic_data/order_items.csv @EXTERNAL_STAGES_DB.STAGES.ECOMMERCE_STAGE;
PUT file://<full-path>/synthetic_data/reviews.csv @EXTERNAL_STAGES_DB.STAGES.ECOMMERCE_STAGE;
PUT file://<full-path>/synthetic_data/transactions.csv @EXTERNAL_STAGES_DB.STAGES.FINTECH_STAGE;
PUT file://<full-path>/synthetic_data/chargebacks.csv @EXTERNAL_STAGES_DB.STAGES.FINTECH_STAGE;
PUT file://<full-path>/synthetic_data/returns.csv @EXTERNAL_STAGES_DB.STAGES.FINTECH_STAGE;
PUT file://<full-path>/synthetic_data/complaints.csv @EXTERNAL_STAGES_DB.STAGES.FINTECH_STAGE;
PUT file://<full-path>/synthetic_data/events.csv @EXTERNAL_STAGES_DB.STAGES.EVENTS_STAGE;
```

---

## Step 4c: Load Data (SQL)

Once files are uploaded:

1. **Open a new Snowflake worksheet**
2. **Open the file:** `02_load_data.sql`
3. **Copy all SQL and paste** into the worksheet
4. **Run all** with Ctrl+A → **Run All**

**Expected output:**
- Multiple `Number of rows copied: [number]` messages for each table
- Final verification query showing row counts for all tables

Example:
```
SCHEMA_NAME | TABLE_NAME      | ROW_COUNT
------------|-----------------|----------
ECOMMERCE   | customers       | 10000
ECOMMERCE   | products        | 500
ECOMMERCE   | orders          | 50000
FINTECH     | transactions    | 100000
OPERATIONS  | events          | 500000
...
```

---

## Step 4d: Verify Data Loaded

Run this query in Snowflake to verify:

```sql
USE DATABASE RAW_DB;

-- Sample data from each table
SELECT TOP 5 * FROM SCHEMA_ECOMMERCE.customers;
SELECT TOP 5 * FROM SCHEMA_ECOMMERCE.orders;
SELECT TOP 5 * FROM SCHEMA_FINTECH.transactions;
SELECT TOP 5 * FROM SCHEMA_OPERATIONS.events;

-- Count total records
SELECT 
    'customers' as table_name, COUNT(*) as row_count 
    FROM SCHEMA_ECOMMERCE.customers
UNION ALL
SELECT 'orders', COUNT(*) FROM SCHEMA_ECOMMERCE.orders
UNION ALL
SELECT 'transactions', COUNT(*) FROM SCHEMA_FINTECH.transactions
UNION ALL
SELECT 'events', COUNT(*) FROM SCHEMA_OPERATIONS.events;
```

---

## Troubleshooting

### Error: "File not found in stage"
- Verify files were uploaded successfully to the stage (check Snowflake UI)
- Check file names match exactly (case-sensitive on some systems)

### Error: "Invalid value for dtype 'str'"
- Some CSV rows have parsing issues
- The COPY INTO statement has `ON_ERROR = 'CONTINUE'` to skip bad rows
- Check the warehouse query history for details on skipped rows

### Large files taking too long to upload
- events.csv is 158 MB; this is normal
- Try uploading fewer files at once if timeout occurs
- Use SnowSQL CLI for larger files (more reliable)

---

## Next Steps

Once data is loaded successfully in Snowflake:
- **Phase 2:** Build dbt staging models (transform raw → staging)
- **Phase 3:** Set up Git + GitHub Actions CI/CD
- **Phase 4:** Build dbt marts (facts & dimensions)
- **Phase 5:** Airflow orchestration

---

## Summary

| Step | Action | Status |
|------|--------|--------|
| 4a | Create raw tables | ⏳ TODO |
| 4b | Upload files to stages | ⏳ TODO |
| 4c | Load data (COPY INTO) | ⏳ TODO |
| 4d | Verify data | ⏳ TODO |

Good luck! 🚀
