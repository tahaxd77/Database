import random
from datetime import datetime, timedelta

# Predefined list of random locations in Lahore
lahore_locations = [
    "Gulberg", "Model Town", "DHA", "Johar Town", "Cantt",
    "Faisal Town", "Iqbal Town", "Shadman", "Wapda Town", "Bahria Town",
    "Garden Town", "Sabzazar", "Samanabad", "Walled City", "Allama Iqbal Town",
    "Askari", "Gari Shahu", "Mozang", "Ravi Road", "Mughalpura"
]

def random_date(start, end):
    """Generate a random datetime between `start` and `end`."""
    return start + timedelta(
        seconds=random.randint(0, int((end - start).total_seconds())),
    )

# Generate a list of records
def generate_order_records(num_records):
    records = []
    start_date = datetime.strptime('2023-01-01', '%Y-%m-%d')
    end_date = datetime.strptime('2024-04-29', '%Y-%m-%d')

    for i in range(1, num_records + 1):
        order_date = random_date(start_date, end_date)
        shipped_date = order_date + timedelta(days=random.randint(1, 30))
        total_price = round(random.uniform(1000, 50000), 2)
        commission_percentage = random.uniform(10, 25)
        commission = round((commission_percentage / 100) * total_price, 2)

        record = {
            "OrderID": i,
            "CustomerID": random.randint(1, 150),  # Assuming CustomerID ranges from 1 to 100
            "OrderDate": order_date,
            "ShippedDate": shipped_date,
            "CarriagePersonID": random.randint(1, 150),  # Assuming CarriagePersonID ranges from 1 to 50
            "ShipAddress": random.choice(lahore_locations),
            "ShipCity": "Lahore",
            "TotalPrice": total_price,
            "Commission": commission
        }
        records.append(record)
    return records

# Number of records to generate
num_records = 600

# Generate records
order_records = generate_order_records(num_records)

# Print records
#for record in order_records:
 #   print(record)

# Optionally, convert records to insert queries
def generate_insert_queries(records):
    queries = []
    for record in records:
        query = (
            f"EXEC InsertOrder {record['OrderID']},'{record['OrderDate'].strftime('%Y-%m-%d %H:%M:%S')}', "
            f"'{record['ShippedDate'].strftime('%Y-%m-%d %H:%M:%S')}', '{record['ShipAddress']}','{record['ShipCity']}', "
            f"{record['CustomerID']} ,{record['CarriagePersonID']};"
        )
        queries.append(query)
    return queries

# Generate insert queries
insert_queries = generate_insert_queries(order_records)

# Print insert queries
for query in insert_queries:
    print(query)
