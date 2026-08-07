"""
Enterprise E-Commerce + Fintech Synthetic Data Generator
Generates realistic raw data mimicking Stitch output with intentional data quality issues
"""

import pandas as pd
import numpy as np
from faker import Faker
from datetime import datetime, timedelta
import json
import random
import os
from pathlib import Path

# ============ CONFIGURATION ============
CONFIG = {
    'NUM_CUSTOMERS': 10000,
    'NUM_PRODUCTS': 500,
    'NUM_ORDERS': 50000,
    'NUM_EVENTS': 500000,
    'NUM_TRANSACTIONS': 100000,
    'NUM_CHARGEBACKS': 500,
    'NUM_RETURNS': 2500,
    'NUM_COMPLAINTS': 1000,
    'NUM_REVIEWS': 5000,
    'NUM_PROMOTIONS': 50,
    'DATE_RANGE_DAYS': 365,  # Last 1 year of data
    'DUPLICATE_RATE': 0.02,  # 2% duplicate events
    'LATE_ARRIVAL_RATE': 0.05,  # 5% transactions arrive 24+ hours late
    'NULL_RATE': 0.01,  # 1% of optional fields are NULL
    'OUTPUT_DIR': 'synthetic_data',
    'RANDOM_SEED': 42
}

# Initialize Faker
fake = Faker()
np.random.seed(CONFIG['RANDOM_SEED'])
random.seed(CONFIG['RANDOM_SEED'])

# Create output directory
Path(CONFIG['OUTPUT_DIR']).mkdir(exist_ok=True)

# ============ HELPER FUNCTIONS ============

def get_date_range():
    """Get start and end dates for data generation"""
    end_date = datetime.now().date()
    start_date = end_date - timedelta(days=CONFIG['DATE_RANGE_DAYS'])
    return start_date, end_date

def random_date(start_date, end_date):
    """Generate random date between start and end"""
    time_between = (end_date - start_date).days
    random_days = random.randint(0, time_between)
    return start_date + timedelta(days=random_days)

def add_late_arrivals(df_transactions, loaded_at_col='_loaded_at', created_at_col='created_at'):
    """Inject late-arriving transactions (arrive 24+ hours after creation)"""
    late_mask = np.random.random(len(df_transactions)) < CONFIG['LATE_ARRIVAL_RATE']
    late_arrivals = (
        pd.to_datetime(df_transactions.loc[late_mask, created_at_col]) +
        pd.to_timedelta(np.random.randint(24, 96, sum(late_mask)), unit='h')
    ).astype(str)
    df_transactions.loc[late_mask, loaded_at_col] = late_arrivals
    return df_transactions

def add_duplicates(df, duplicate_col='id', rate=None):
    """Inject duplicate rows (simulating retry logic)"""
    if rate is None:
        rate = CONFIG['DUPLICATE_RATE']

    if len(df) == 0:
        return df

    num_duplicates = int(len(df) * rate)
    if num_duplicates > 0:
        dup_indices = np.random.choice(df.index, size=num_duplicates, replace=True)
        duplicates = df.loc[dup_indices].copy()
        df = pd.concat([df, duplicates], ignore_index=True)

    return df

def add_nulls(df, cols, rate=None):
    """Inject NULL values into specified columns"""
    if rate is None:
        rate = CONFIG['NULL_RATE']

    for col in cols:
        if col in df.columns:
            null_mask = np.random.random(len(df)) < rate
            df.loc[null_mask, col] = None

    return df

# ============ GENERATE CUSTOMERS ============

def generate_customers():
    """Generate customer dimension table"""
    print("Generating customers...")
    start_date, end_date = get_date_range()

    customers = []
    for i in range(CONFIG['NUM_CUSTOMERS']):
        customer_id = f"CUST_{str(i+1).zfill(8)}"
        created_date = random_date(start_date, end_date)

        customers.append({
            'customer_id': customer_id,
            'email': fake.email(),
            'phone': fake.phone_number()[:15],
            'first_name': fake.first_name(),
            'last_name': fake.last_name(),
            'date_of_birth': fake.date_of_birth(minimum_age=18, maximum_age=80),
            'country': np.random.choice(['US', 'CA', 'UK', 'DE', 'FR', 'AU'], p=[0.5, 0.15, 0.1, 0.1, 0.1, 0.05]),
            'kyc_status': np.random.choice(['approved', 'pending', 'rejected'], p=[0.85, 0.10, 0.05]),
            'kyc_verified_date': created_date if np.random.random() < 0.85 else None,
            'customer_segment': np.random.choice(['premium', 'standard', 'churn_risk', 'vip'], p=[0.15, 0.60, 0.15, 0.10]),
            'lifetime_purchases': round(np.random.exponential(scale=1000), 2),
            'account_status': np.random.choice(['active', 'inactive', 'suspended'], p=[0.85, 0.10, 0.05]),
            'last_purchase_date': created_date if np.random.random() < 0.70 else None,
            'preferred_currency': 'USD',
            'created_at': created_date.isoformat() + ' 00:00:00',
            '_snapshot_date': end_date.isoformat()
        })

    df = pd.DataFrame(customers)
    df = add_nulls(df, ['phone', 'last_purchase_date'], rate=0.05)

    return df

# ============ GENERATE PRODUCTS ============

def generate_products():
    """Generate product dimension table"""
    print("Generating products...")
    start_date, end_date = get_date_range()

    categories = ['Electronics', 'Clothing', 'Home & Garden', 'Sports', 'Books', 'Beauty', 'Toys', 'Food']

    products = []
    for i in range(CONFIG['NUM_PRODUCTS']):
        product_id = f"PROD_{str(i+1).zfill(8)}"
        created_date = random_date(start_date, end_date)
        cost = round(np.random.uniform(10, 500), 2)
        markup = np.random.uniform(1.3, 3.0)

        products.append({
            'product_id': product_id,
            'product_name': fake.word() + ' ' + fake.word(),
            'category': np.random.choice(categories),
            'subcategory': fake.word(),
            'description': fake.sentence()[:100],
            'list_price': round(cost * markup, 2),
            'cost': cost,
            'current_price': round(cost * np.random.uniform(1.3, 2.5), 2),
            'inventory_count': np.random.randint(0, 1000),
            'supplier_id': f"SUP_{random.randint(1, 50):03d}",
            'weight': round(np.random.uniform(0.1, 50), 2),
            'is_active': True if np.random.random() < 0.95 else False,
            'created_at': created_date.isoformat() + ' 00:00:00',
            'updated_at': created_date.isoformat() + ' 00:00:00',
            '_snapshot_date': end_date.isoformat()
        })

    return pd.DataFrame(products)

# ============ GENERATE PROMOTIONS ============

def generate_promotions():
    """Generate promotions/discounts"""
    print("Generating promotions...")
    start_date, end_date = get_date_range()

    promos = []
    promo_types = ['percentage', 'fixed_amount', 'bogo', 'free_shipping']

    for i in range(CONFIG['NUM_PROMOTIONS']):
        promo_id = f"PROMO_{str(i+1).zfill(6)}"
        start = random_date(start_date, end_date)
        duration = random.randint(7, 90)
        end = start + timedelta(days=duration)

        promos.append({
            'promotion_id': promo_id,
            'promo_code': fake.bothify(text='???###').upper(),
            'promo_type': np.random.choice(promo_types),
            'discount_value': round(np.random.uniform(5, 50), 2),
            'discount_cap': round(np.random.uniform(10, 200), 2),
            'eligible_product_ids': None,  # NULL = all products
            'eligible_customer_segment': np.random.choice(['all', 'premium', 'new_customers', 'inactive']),
            'min_purchase_amount': round(np.random.uniform(0, 100), 2),
            'usage_limit': random.randint(100, 10000),
            'current_usage': random.randint(0, 9000),
            'start_date': start.isoformat(),
            'end_date': end.isoformat(),
            'status': np.random.choice(['active', 'paused', 'expired'], p=[0.6, 0.2, 0.2]),
            'created_at': start.isoformat() + ' 00:00:00'
        })

    return pd.DataFrame(promos)

# ============ GENERATE ORDERS ============

def generate_orders(customers_df, products_df, promotions_df):
    """Generate orders (header level)"""
    print("Generating orders...")
    start_date, end_date = get_date_range()

    orders = []
    for i in range(CONFIG['NUM_ORDERS']):
        order_id = f"ORD_{str(i+1).zfill(10)}"
        customer_id = np.random.choice(customers_df['customer_id'].values)
        order_date = random_date(start_date, end_date)

        # 30% of orders have a promotion
        promo = None if np.random.random() > 0.30 else np.random.choice(promotions_df['promo_code'].values)

        subtotal = round(np.random.uniform(20, 500), 2)
        discount = round(subtotal * np.random.uniform(0, 0.15), 2) if np.random.random() < 0.30 else 0
        tax = round((subtotal - discount) * 0.08, 2)
        total = subtotal - discount + tax

        orders.append({
            'order_id': order_id,
            'customer_id': customer_id,
            'order_timestamp': order_date.isoformat() + ' ' + fake.time(),
            'order_status': np.random.choice(['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled'],
                                            p=[0.05, 0.10, 0.15, 0.40, 0.25, 0.05]),
            'subtotal_amount': subtotal,
            'discount_amount': discount,
            'discount_code': promo,
            'tax_amount': tax,
            'total_amount': total,
            'shipping_address': json.dumps({
                'street': fake.address().split('\n')[0],
                'city': fake.city(),
                'state': fake.state_abbr(),
                'zip': fake.zipcode(),
                'country': 'US'
            }),
            'payment_method': np.random.choice(['credit_card', 'debit_card', 'wallet', 'bank_transfer']),
            'fulfillment_warehouse': f"WH_{random.randint(1, 5):02d}",
            'created_at': order_date.isoformat() + ' 00:00:00',
            'updated_at': order_date.isoformat() + ' 00:00:00',
            '_snapshot_date': end_date.isoformat()
        })

    return pd.DataFrame(orders)

# ============ GENERATE ORDER ITEMS ============

def generate_order_items(orders_df, products_df):
    """Generate order line items"""
    print("Generating order items...")

    order_items = []
    item_id_counter = 1

    for _, order in orders_df.iterrows():
        num_items = np.random.randint(1, 5)

        for _ in range(num_items):
            product = products_df.sample(1).iloc[0]
            qty = random.randint(1, 10)
            unit_price = product['current_price']

            order_items.append({
                'order_item_id': f"OITEM_{str(item_id_counter).zfill(12)}",
                'order_id': order['order_id'],
                'product_id': product['product_id'],
                'quantity': qty,
                'unit_price': unit_price,
                'line_total': round(qty * unit_price, 2),
                'applied_promotions': None,
                'restocking_fee': 0,
                'created_at': order['created_at']
            })
            item_id_counter += 1

    return pd.DataFrame(order_items)

# ============ GENERATE TRANSACTIONS ============

def generate_transactions(orders_df):
    """Generate payment transactions with late arrivals & duplicates"""
    print("Generating transactions...")

    transactions = []
    txn_id_counter = 1

    for _, order in orders_df.iterrows():
        # 90% of orders have successful transaction, 10% failed/pending
        if np.random.random() < 0.90 and order['order_status'] != 'cancelled':
            txn_status = 'success'
        else:
            txn_status = np.random.choice(['declined', 'failed', 'pending'])

        # Order timestamp + random time offset
        order_time = pd.to_datetime(order['order_timestamp'])
        txn_time = order_time + timedelta(minutes=random.randint(1, 30))

        transactions.append({
            'transaction_id': f"TXN_{str(txn_id_counter).zfill(12)}",
            'order_id': order['order_id'],
            'customer_id': order['customer_id'],
            'transaction_type': np.random.choice(['auth', 'capture', 'refund', 'void'], p=[0.6, 0.3, 0.05, 0.05]),
            'amount': order['total_amount'],
            'currency': 'USD',
            'status': txn_status,
            'payment_method': order['payment_method'],
            'card_last_4': fake.numerify(text='####'),
            'gateway_response': json.dumps({'code': random.randint(100, 999), 'message': 'Processed'}),
            'authorization_code': fake.bothify(text='??????'),
            'merchant_fee': round(order['total_amount'] * 0.029, 2),
            'created_at': txn_time.isoformat(),
            'updated_at': txn_time.isoformat(),
            '_loaded_at': txn_time.isoformat()  # Will be modified for late arrivals
        })
        txn_id_counter += 1

    df = pd.DataFrame(transactions)
    df = add_late_arrivals(df)
    df = add_duplicates(df, rate=0.03)  # 3% duplicate transactions

    return df

# ============ GENERATE CHARGEBACKS ============

def generate_chargebacks(transactions_df, customers_df):
    """Generate chargebacks and disputes"""
    print("Generating chargebacks...")

    chargebacks = []
    cb_id_counter = 1

    # Select random successful transactions
    successful_txns = transactions_df[transactions_df['status'] == 'success'].sample(
        min(CONFIG['NUM_CHARGEBACKS'], len(transactions_df))
    )

    for _, txn in successful_txns.iterrows():
        filed_date = pd.to_datetime(txn['created_at']).date() + timedelta(days=random.randint(10, 60))

        chargebacks.append({
            'chargeback_id': f"CB_{str(cb_id_counter).zfill(10)}"  ,
            'transaction_id': txn['transaction_id'],
            'order_id': txn['order_id'],
            'customer_id': txn['customer_id'],
            'dispute_reason': np.random.choice(['fraud', 'customer_dispute', 'product_not_received', 'not_as_described']),
            'amount': txn['amount'],
            'chargeback_status': np.random.choice(['new', 'investigation', 'lost', 'won', 'resolved'], p=[0.2, 0.3, 0.2, 0.2, 0.1]),
            'filed_date': filed_date.isoformat(),
            'resolution_date': (filed_date + timedelta(days=random.randint(30, 90))).isoformat() if np.random.random() < 0.8 else None,
            'evidence_provided': np.random.choice([True, False]),
            'created_at': filed_date.isoformat() + ' 00:00:00'
        })
        cb_id_counter += 1

    return pd.DataFrame(chargebacks)

# ============ GENERATE RETURNS ============

def generate_returns(orders_df):
    """Generate returns and RMAs"""
    print("Generating returns...")

    returns = []
    ret_id_counter = 1

    # Select subset of delivered orders
    delivered_orders = orders_df[orders_df['order_status'] == 'delivered'].sample(
        min(CONFIG['NUM_RETURNS'], len(orders_df))
    )

    for _, order in delivered_orders.iterrows():
        return_date = pd.to_datetime(order['updated_at']).date() + timedelta(days=random.randint(1, 30))
        refund_amount = round(order['total_amount'] * np.random.uniform(0.5, 1.0), 2)

        returns.append({
            'return_id': f"RET_{str(ret_id_counter).zfill(10)}",
            'order_id': order['order_id'],
            'order_item_id': None,  # Simplified: return at order level
            'customer_id': order['customer_id'],
            'product_id': None,
            'return_reason': np.random.choice(['defective', 'wrong_size', 'damaged', 'not_as_described', 'changed_mind']),
            'return_status': np.random.choice(['initiated', 'received', 'processing', 'approved', 'rejected', 'refunded'],
                                             p=[0.1, 0.15, 0.15, 0.4, 0.05, 0.15]),
            'refund_amount': refund_amount,
            'restocking_fee': round(refund_amount * 0.10, 2) if np.random.random() < 0.3 else 0,
            'initiated_date': return_date.isoformat(),
            'received_date': (return_date + timedelta(days=random.randint(3, 10))).isoformat() if np.random.random() < 0.7 else None,
            'refund_date': (return_date + timedelta(days=random.randint(5, 30))).isoformat() if np.random.random() < 0.6 else None,
            'tracking_number': fake.bothify(text='1Z???????????'),
            'created_at': return_date.isoformat() + ' 00:00:00'
        })
        ret_id_counter += 1

    return pd.DataFrame(returns)

# ============ GENERATE EVENTS (CLICKSTREAM) ============

def generate_events(customers_df, products_df):
    """Generate clickstream events (nested JSON)"""
    print("Generating events...")
    start_date, end_date = get_date_range()

    events = []
    event_id_counter = 1

    event_types = ['view', 'add_to_cart', 'remove_from_cart', 'checkout_start', 'checkout_complete', 'search', 'filter']

    for i in range(CONFIG['NUM_EVENTS']):
        event_date = random_date(start_date, end_date)
        event_time = datetime.combine(event_date, fake.time_object())

        # Most events have product_id, some are generic
        has_product = np.random.random() < 0.70
        product_id = products_df.sample(1)['product_id'].values[0] if has_product else None

        event = {
            'event_id': f"EV_{str(event_id_counter).zfill(15)}",
            'event_timestamp': event_time.isoformat(),
            'user_id': np.random.choice(customers_df['customer_id'].values),
            'session_id': fake.bothify(text='sess_????????????'),
            'event_type': np.random.choice(event_types),
            'product_id': product_id,
            'event_value': round(np.random.uniform(0, 500), 2) if np.random.random() < 0.3 else None,
            'event_metadata': json.dumps({
                'device': np.random.choice(['mobile', 'desktop', 'tablet']),
                'browser': np.random.choice(['Chrome', 'Safari', 'Firefox', 'Edge']),
                'location': {
                    'country': 'US',
                    'region': fake.state_abbr()
                },
                'utm_params': {
                    'source': np.random.choice(['google', 'facebook', 'direct', 'email', None]),
                    'medium': np.random.choice(['organic', 'paid', 'email', 'social', None]),
                    'campaign': fake.word() if np.random.random() < 0.3 else None
                }
            }),
            '_loaded_at': event_time.isoformat()
        }

        events.append(event)
        event_id_counter += 1

    df = pd.DataFrame(events)
    df = add_duplicates(df, rate=0.02)  # 2% duplicate events
    df = add_late_arrivals(df, loaded_at_col='_loaded_at', created_at_col='event_timestamp')

    return df

# ============ GENERATE COMPLAINTS ============

def generate_complaints(customers_df, orders_df):
    """Generate support complaints/tickets"""
    print("Generating complaints...")

    complaints = []
    comp_id_counter = 1

    complaint_types = ['quality_issue', 'delivery_issue', 'billing_issue', 'product_feedback']

    for i in range(CONFIG['NUM_COMPLAINTS']):
        customer = customers_df.sample(1).iloc[0]
        customer_orders = orders_df[orders_df['customer_id'] == customer['customer_id']]

        # Handle case where customer has no orders
        if len(customer_orders) > 0:
            related_order = customer_orders.sample(1)
            order_id = related_order['order_id'].values[0]
        else:
            order_id = None

        complaint_date = random_date(*get_date_range())
        resolution_date = complaint_date + timedelta(days=random.randint(1, 14))

        complaints.append({
            'complaint_id': f"COMP_{str(comp_id_counter).zfill(10)}",
            'customer_id': customer['customer_id'],
            'order_id': order_id,
            'complaint_type': np.random.choice(complaint_types),
            'severity': np.random.choice(['low', 'medium', 'high', 'critical'], p=[0.4, 0.35, 0.20, 0.05]),
            'description': fake.sentence()[:200],
            'status': np.random.choice(['open', 'in_progress', 'resolved', 'closed'], p=[0.1, 0.2, 0.5, 0.2]),
            'resolution': fake.sentence()[:200] if np.random.random() < 0.7 else None,
            'response_time_hours': random.randint(1, 48) if np.random.random() < 0.8 else None,
            'satisfaction_rating': random.randint(1, 5) if np.random.random() < 0.6 else None,
            'assigned_to': fake.name() if np.random.random() < 0.7 else None,
            'created_at': complaint_date.isoformat() + ' 00:00:00',
            'resolved_at': resolution_date.isoformat() + ' 00:00:00' if np.random.random() < 0.7 else None
        })
        comp_id_counter += 1

    return pd.DataFrame(complaints)

# ============ GENERATE REVIEWS ============

def generate_reviews(customers_df, products_df):
    """Generate product reviews"""
    print("Generating reviews...")

    reviews = []
    review_id_counter = 1

    for i in range(CONFIG['NUM_REVIEWS']):
        customer = customers_df.sample(1).iloc[0]
        product = products_df.sample(1).iloc[0]
        rating = np.random.choice([1, 2, 3, 4, 5], p=[0.05, 0.10, 0.15, 0.30, 0.40])
        review_date = random_date(*get_date_range())

        reviews.append({
            'review_id': f"REV_{str(review_id_counter).zfill(10)}",
            'product_id': product['product_id'],
            'customer_id': customer['customer_id'],
            'order_item_id': None,
            'rating_stars': rating,
            'review_title': fake.sentence()[:50],
            'review_text': fake.paragraph()[:500],
            'sentiment_score': round(np.random.uniform(-1, 1), 2),
            'helpful_count': random.randint(0, 100),
            'unhelpful_count': random.randint(0, 20),
            'verified_purchase': np.random.choice([True, False], p=[0.80, 0.20]),
            'review_status': np.random.choice(['pending_moderation', 'approved', 'rejected'], p=[0.1, 0.85, 0.05]),
            'moderated_by': fake.name() if np.random.random() < 0.9 else None,
            'created_at': review_date.isoformat() + ' 00:00:00'
        })
        review_id_counter += 1

    return pd.DataFrame(reviews)

# ============ EXPORT TO CSV/JSON ============

def export_data(dataframes_dict):
    """Export all dataframes to CSV and JSON files"""

    for table_name, df in dataframes_dict.items():
        # CSV export
        csv_path = f"{CONFIG['OUTPUT_DIR']}/{table_name}.csv"
        df.to_csv(csv_path, index=False)
        print(f"  ✓ Exported {len(df)} rows → {csv_path}")

        # JSON export for tables with JSON columns
        if table_name in ['events', 'transactions', 'chargebacks']:
            json_path = f"{CONFIG['OUTPUT_DIR']}/{table_name}.jsonl"
            df.to_json(json_path, orient='records', lines=True)
            print(f"  ✓ Exported {len(df)} rows → {json_path}")

# ============ MAIN EXECUTION ============

def main():
    print("\n" + "="*80)
    print("ENTERPRISE SYNTHETIC DATA GENERATOR")
    print("="*80 + "\n")

    print(f"Configuration:")
    print(f"  - Customers: {CONFIG['NUM_CUSTOMERS']}")
    print(f"  - Products: {CONFIG['NUM_PRODUCTS']}")
    print(f"  - Orders: {CONFIG['NUM_ORDERS']}")
    print(f"  - Events: {CONFIG['NUM_EVENTS']}")
    print(f"  - Transactions: {CONFIG['NUM_TRANSACTIONS']}")
    print(f"  - Date Range: {CONFIG['DATE_RANGE_DAYS']} days")
    print(f"  - Output Directory: {CONFIG['OUTPUT_DIR']}\n")

    # Generate all tables
    customers_df = generate_customers()
    products_df = generate_products()
    promotions_df = generate_promotions()
    orders_df = generate_orders(customers_df, products_df, promotions_df)
    order_items_df = generate_order_items(orders_df, products_df)
    transactions_df = generate_transactions(orders_df)
    chargebacks_df = generate_chargebacks(transactions_df, customers_df)
    returns_df = generate_returns(orders_df)
    complaints_df = generate_complaints(customers_df, orders_df)
    reviews_df = generate_reviews(customers_df, products_df)
    events_df = generate_events(customers_df, products_df)

    # Compile all tables
    dataframes = {
        'customers': customers_df,
        'products': products_df,
        'promotions': promotions_df,
        'orders': orders_df,
        'order_items': order_items_df,
        'transactions': transactions_df,
        'chargebacks': chargebacks_df,
        'returns': returns_df,
        'complaints': complaints_df,
        'reviews': reviews_df,
        'events': events_df
    }

    # Export
    print("\nExporting data to CSV/JSON files...\n")
    export_data(dataframes)

    # Summary
    print("\n" + "="*80)
    print("DATA GENERATION COMPLETE")
    print("="*80)
    print(f"\nGenerated files in: {CONFIG['OUTPUT_DIR']}/")
    print("\nData Quality Features Included:")
    print(f"  ✓ Late-arriving transactions ({int(CONFIG['LATE_ARRIVAL_RATE']*100)}%)")
    print(f"  ✓ Duplicate events ({int(CONFIG['DUPLICATE_RATE']*100)}%)")
    print(f"  ✓ NULL values in optional fields ({int(CONFIG['NULL_RATE']*100)}%)")
    print(f"  ✓ Realistic business logic (30% orders with promos, 5% returns, etc.)")
    print(f"  ✓ Out-of-order transaction delivery")
    print(f"  ✓ Schema-realistic JSON nested payloads")
    print("\n" + "="*80 + "\n")

if __name__ == "__main__":
    main()
