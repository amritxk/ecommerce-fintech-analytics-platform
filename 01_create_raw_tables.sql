-- ============================================================================
-- PHASE 1 STEP 4: Create Raw Tables in Snowflake
-- Run this script in Snowflake as ACCOUNTADMIN or TRANSFORM_ROLE
-- ============================================================================

USE ROLE TRANSFORM_ROLE;
USE WAREHOUSE TRANSFORM_WH;

-- ============ E-COMMERCE SCHEMA ============

USE DATABASE RAW_DB;
USE SCHEMA SCHEMA_ECOMMERCE;

-- Customers
CREATE OR REPLACE TABLE customers (
    customer_id VARCHAR,
    email VARCHAR,
    phone VARCHAR,
    first_name VARCHAR,
    last_name VARCHAR,
    date_of_birth DATE,
    country VARCHAR,
    kyc_status VARCHAR,
    kyc_verified_date DATE,
    customer_segment VARCHAR,
    lifetime_purchases FLOAT,
    account_status VARCHAR,
    last_purchase_date DATE,
    preferred_currency VARCHAR,
    created_at TIMESTAMP,
    _snapshot_date DATE
);

-- Products
CREATE OR REPLACE TABLE products (
    product_id VARCHAR,
    product_name VARCHAR,
    category VARCHAR,
    subcategory VARCHAR,
    description VARCHAR,
    list_price FLOAT,
    cost FLOAT,
    current_price FLOAT,
    inventory_count INTEGER,
    supplier_id VARCHAR,
    weight FLOAT,
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    _snapshot_date DATE
);

-- Promotions
CREATE OR REPLACE TABLE promotions (
    promotion_id VARCHAR,
    promo_code VARCHAR,
    promo_type VARCHAR,
    discount_value FLOAT,
    discount_cap FLOAT,
    eligible_product_ids VARIANT,
    eligible_customer_segment VARCHAR,
    min_purchase_amount FLOAT,
    usage_limit INTEGER,
    current_usage INTEGER,
    start_date DATE,
    end_date DATE,
    status VARCHAR,
    created_at TIMESTAMP
);

-- Orders
CREATE OR REPLACE TABLE orders (
    order_id VARCHAR,
    customer_id VARCHAR,
    order_timestamp TIMESTAMP,
    order_status VARCHAR,
    subtotal_amount FLOAT,
    discount_amount FLOAT,
    discount_code VARCHAR,
    tax_amount FLOAT,
    total_amount FLOAT,
    shipping_address VARIANT,
    payment_method VARCHAR,
    fulfillment_warehouse VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    _snapshot_date DATE
);

-- Order Items
CREATE OR REPLACE TABLE order_items (
    order_item_id VARCHAR,
    order_id VARCHAR,
    product_id VARCHAR,
    quantity INTEGER,
    unit_price FLOAT,
    line_total FLOAT,
    applied_promotions VARIANT,
    restocking_fee FLOAT,
    created_at TIMESTAMP
);

-- Reviews
CREATE OR REPLACE TABLE reviews (
    review_id VARCHAR,
    product_id VARCHAR,
    customer_id VARCHAR,
    order_item_id VARCHAR,
    rating_stars INTEGER,
    review_title VARCHAR,
    review_text VARCHAR,
    sentiment_score FLOAT,
    helpful_count INTEGER,
    unhelpful_count INTEGER,
    verified_purchase BOOLEAN,
    review_status VARCHAR,
    moderated_by VARCHAR,
    created_at TIMESTAMP
);

-- Wishlists
CREATE OR REPLACE TABLE wishlists (
    wishlist_id VARCHAR,
    customer_id VARCHAR,
    product_id VARCHAR,
    wishlist_type VARCHAR,
    quantity INTEGER,
    price_when_added FLOAT,
    current_price FLOAT,
    added_date DATE,
    price_drop_alert BOOLEAN,
    price_drop_notified BOOLEAN,
    abandoned_cart_flag BOOLEAN,
    days_in_cart INTEGER,
    recovered BOOLEAN,
    purchase_date DATE,
    created_at TIMESTAMP
);

-- ============ FINTECH SCHEMA ============

USE SCHEMA SCHEMA_FINTECH;

-- Transactions
CREATE OR REPLACE TABLE transactions (
    transaction_id VARCHAR,
    order_id VARCHAR,
    customer_id VARCHAR,
    transaction_type VARCHAR,
    amount FLOAT,
    currency VARCHAR,
    status VARCHAR,
    payment_method VARCHAR,
    card_last_4 VARCHAR,
    gateway_response VARIANT,
    authorization_code VARCHAR,
    merchant_fee FLOAT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    _loaded_at TIMESTAMP
);

-- Chargebacks
CREATE OR REPLACE TABLE chargebacks (
    chargeback_id VARCHAR,
    transaction_id VARCHAR,
    order_id VARCHAR,
    customer_id VARCHAR,
    dispute_reason VARCHAR,
    amount FLOAT,
    chargeback_status VARCHAR,
    filed_date DATE,
    resolution_date DATE,
    evidence_provided BOOLEAN,
    created_at TIMESTAMP
);

-- Returns
CREATE OR REPLACE TABLE returns (
    return_id VARCHAR,
    order_id VARCHAR,
    order_item_id VARCHAR,
    customer_id VARCHAR,
    product_id VARCHAR,
    return_reason VARCHAR,
    return_status VARCHAR,
    refund_amount FLOAT,
    restocking_fee FLOAT,
    initiated_date DATE,
    received_date DATE,
    refund_date DATE,
    tracking_number VARCHAR,
    created_at TIMESTAMP
);

-- Complaints
CREATE OR REPLACE TABLE complaints (
    complaint_id VARCHAR,
    customer_id VARCHAR,
    order_id VARCHAR,
    complaint_type VARCHAR,
    severity VARCHAR,
    description VARCHAR,
    status VARCHAR,
    resolution VARCHAR,
    response_time_hours INTEGER,
    satisfaction_rating INTEGER,
    assigned_to VARCHAR,
    created_at TIMESTAMP,
    resolved_at TIMESTAMP
);

-- ============ OPERATIONS SCHEMA ============

USE SCHEMA SCHEMA_OPERATIONS;

-- Events
CREATE OR REPLACE TABLE events (
    event_id VARCHAR,
    event_timestamp TIMESTAMP,
    user_id VARCHAR,
    session_id VARCHAR,
    event_type VARCHAR,
    product_id VARCHAR,
    event_value FLOAT,
    event_metadata VARIANT,
    _loaded_at TIMESTAMP
);

-- Summary
SHOW TABLES IN RAW_DB.SCHEMA_ECOMMERCE;
SHOW TABLES IN RAW_DB.SCHEMA_FINTECH;
SHOW TABLES IN RAW_DB.SCHEMA_OPERATIONS;

PRINT 'All raw tables created successfully!';
