import pandas as pd
import numpy as np
import random
from datetime import datetime, timedelta

# ------------------------
# Settings
# ------------------------

NUM_USERS = 200
START_DATE = datetime(2025, 10, 1)
END_DATE = datetime(2026, 1, 31)

# ------------------------
# 1. Generate Users
# ------------------------

users = []

for i in range(1, NUM_USERS + 1):
    signup = START_DATE + timedelta(days=random.randint(0, 120))
    users.append([i, f'User_{i}', signup.date(), None])

users_df = pd.DataFrame(users, columns=[
    "user_id", "user_name", "signup_date", "referred_by"
])

# ------------------------
# 2. Generate Referrals
# ------------------------

referrals = []
referral_id = 1

referred_users = random.sample(range(2, NUM_USERS + 1), int(NUM_USERS * 0.25))

for user_id in referred_users:
    referrer = random.randint(1, user_id - 1)
    users_df.loc[users_df.user_id == user_id, "referred_by"] = referrer
    referral_date = START_DATE + timedelta(days=random.randint(0, 120))

    referrals.append([
        referral_id,
        referrer,
        user_id,
        referral_date.date()
    ])

    referral_id += 1

referrals_df = pd.DataFrame(referrals, columns=[
    "referral_id", "referrer_id", "referred_user_id", "referral_date"
])

# ------------------------
# 3. Generate Transactions
# ------------------------

transactions = []
txn_id = 1

for user_id in users_df.user_id:

    num_txns = random.randint(10, 30)

    for _ in range(num_txns):

        txn_date = START_DATE + timedelta(days=random.randint(0, 120))
        txn_type = random.choice(["UPI", "CARD"])
        txn_amount = round(random.uniform(50, 5000), 2)

        txn_status = np.random.choice(
            ["SUCCESS", "FAILED"], p=[0.9, 0.1]
        )

        transactions.append([
            txn_id,
            user_id,
            txn_date.date(),
            txn_date.year,
            txn_date.month,
            txn_type,
            txn_amount,
            txn_status
        ])

        txn_id += 1

transactions_df = pd.DataFrame(transactions, columns=[
    "txn_id",
    "user_id",
    "txn_date",
    "txn_year",
    "txn_month",
    "txn_type",
    "txn_amount",
    "txn_status"
])

# ------------------------
# 4. Generate Revenue Table
# ------------------------

revenue_rows = []

for _, row in transactions_df.iterrows():

    if row["txn_type"] == "UPI":
        revenue_percent = 0.005
    else:
        revenue_percent = 0.012

    revenue = row["txn_amount"] * revenue_percent

    revenue_rows.append([
        row["txn_id"],
        row["user_id"],
        row["txn_date"],
        row["txn_year"],
        row["txn_month"],
        row["txn_type"],
        row["txn_amount"],
        revenue_percent,
        revenue
    ])

txn_revenue_df = pd.DataFrame(revenue_rows, columns=[
    "txn_id",
    "user_id",
    "txn_date",
    "txn_year",
    "txn_month",
    "txn_type",
    "txn_amount",
    "revenue_percent",
    "revenue"
])

# ------------------------
# 5. Export CSV Files
# ------------------------

users_df.to_csv("users.csv", index=False)
transactions_df.to_csv("transactions.csv", index=False)
referrals_df.to_csv("referrals.csv", index=False)
txn_revenue_df.to_csv("txn_revenue.csv", index=False)

print("New dataset generated successfully.")