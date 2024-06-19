import random

# Predefined list of Pakistani names
pakistani_names = [
    "Ahmed Ali", "Muhammad Usman", "Afzal Khan", "Tahir Tariq", "Abdullah Malik",
    "Sahil Qureshi", "Bilal Ahmed", "Amanullah Chaudhry", "Zain Raza", "Hamza Iqbal",
    "Tayyab Ali", "Ali Haider", "Hassan Javed", "Maaz Siddiqui", "Khan Aziz",
    "Ibrahim Khan", "Shehryar Faisal", "Omar Aslam", "Rashid Noor", "Zain Ali",
    "Nadir Zahid", "Rizwan Ahmed", "Saqib Iqbal", "Danish Shah", "Ali Khan"
]

# Predefined list of vehicle types
vehicle_types = ["rikshaw loader", "mazda"]

# Generate a list of records
def generate_carriage_person_records(num_records):
    records = []
    for i in range(1, num_records + 1):
        record = {
            "CarriagePersonID": i,
            "CarriagePersonName": random.choice(pakistani_names),
            "VehicleType": random.choice(vehicle_types)
        }
        records.append(record)
    return records

# Number of records to generate
num_records = 150

# Generate records
carriage_person_records = generate_carriage_person_records(num_records)

# Print records
#for record in carriage_person_records:
#    print(record)

# Optionally, convert records to insert queries
def generate_insert_queries(records):
    queries = []
    for record in records:
        query = (
            f"EXEC InsertCarriage {record['CarriagePersonID']}, '{record['CarriagePersonName']}', '{record['VehicleType']}';"
        )
        queries.append(query)
    return queries
# Generate insert queries
insert_queries = generate_insert_queries(carriage_person_records)

# Print insert queries
for query in insert_queries:
    print(query)