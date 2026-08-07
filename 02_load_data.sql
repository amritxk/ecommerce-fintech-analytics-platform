-- ============================================================================
-- PHASE 1 STEP 4: Load Data from Stages to Raw Tables
-- Run this script AFTER uploading files to stages
-- ============================================================================

USE ROLE TRANSFORM_ROLE;
USE WAREHOUSE TRANSFORM_WH;
USE DATABASE RAW_DB;

-- ============ E-COMMERCE DATA LOADING ============

USE SCHEMA SCHEMA_ECOMMERCE;

-- Load Customers
COPY INTO customers
FROM @EXTERNAL_STAGES_DB.STAGES.ECOMMERCE_STAGE/customers.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- Load Products
COPY INTO products
FROM @EXTERNAL_STAGES_DB.STAGES.ECOMMERCE_STAGE/products.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- Load Promotions
COPY INTO promotions
FROM @EXTERNAL_STAGES_DB.STAGES.ECOMMERCE_STAGE/promotions.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- Load Orders
COPY INTO orders
FROM @EXTERNAL_STAGES_DB.STAGES.ECOMMERCE_STAGE/orders.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- Load Order Items
COPY INTO order_items
FROM @EXTERNAL_STAGES_DB.STAGES.ECOMMERCE_STAGE/order_items.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- Load Reviews
COPY INTO reviews
FROM @EXTERNAL_STAGES_DB.STAGES.ECOMMERCE_STAGE/reviews.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- ============ FINTECH DATA LOADING ============

USE SCHEMA SCHEMA_FINTECH;

-- Load Transactions
COPY INTO transactions
FROM @EXTERNAL_STAGES_DB.STAGES.FINTECH_STAGE/transactions.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- Load Chargebacks
COPY INTO chargebacks
FROM @EXTERNAL_STAGES_DB.STAGES.FINTECH_STAGE/chargebacks.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- Load Returns
COPY INTO returns
FROM @EXTERNAL_STAGES_DB.STAGES.FINTECH_STAGE/returns.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- Load Complaints
COPY INTO complaints
FROM @EXTERNAL_STAGES_DB.STAGES.FINTECH_STAGE/complaints.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- ============ OPERATIONS DATA LOADING ============

USE SCHEMA SCHEMA_OPERATIONS;

-- Load Events (from CSV for initial testing)
COPY INTO events
FROM @EXTERNAL_STAGES_DB.STAGES.EVENTS_STAGE/events.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- ============ VERIFICATION ============

USE DATABASE RAW_DB;

-- Count rows in each table
SELECT 'ECOMMERCE' as schema_name, 'customers' as table_name, COUNT(*) as row_count FROM SCHEMA_ECOMMERCE.customers
UNION ALL
SELECT 'ECOMMERCE', 'products', COUNT(*) FROM SCHEMA_ECOMMERCE.products
UNION ALL
SELECT 'ECOMMERCE', 'promotions', COUNT(*) FROM SCHEMA_ECOMMERCE.promotions
UNION ALL
SELECT 'ECOMMERCE', 'orders', COUNT(*) FROM SCHEMA_ECOMMERCE.orders
UNION ALL
SELECT 'ECOMMERCE', 'order_items', COUNT(*) FROM SCHEMA_ECOMMERCE.order_items
UNION ALL
SELECT 'ECOMMERCE', 'reviews', COUNT(*) FROM SCHEMA_ECOMMERCE.reviews
UNION ALL
SELECT 'FINTECH', 'transactions', COUNT(*) FROM SCHEMA_FINTECH.transactions
UNION ALL
SELECT 'FINTECH', 'chargebacks', COUNT(*) FROM SCHEMA_FINTECH.chargebacks
UNION ALL
SELECT 'FINTECH', 'returns', COUNT(*) FROM SCHEMA_FINTECH.returns
UNION ALL
SELECT 'FINTECH', 'complaints', COUNT(*) FROM SCHEMA_FINTECH.complaints
UNION ALL
SELECT 'OPERATIONS', 'events', COUNT(*) FROM SCHEMA_OPERATIONS.events
ORDER BY schema_name, table_name;

PRINT 'Data loaded successfully!';
