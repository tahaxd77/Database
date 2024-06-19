import random

# Product names and their corresponding prices
products = [
    ("2ft-6in x 1ft-6in", 500),
    ("3ft-0in x 1ft-5in", 585),
    ("3ft-5in x 1ft-6in", 660),
    ("3ft-6in x 1ft-6in", 675),
    ("4ft-0in x 1ft-6in", 820),
    ("4ft-6in x 1ft-6in", 835),
    ("4ft-6in x 1ft-6in", 1025),
    ("4ft-0in x 1ft-6in", 1040),
    ("5ft-0in x 1ft-6in", 1205),
    ("5ft-6in x 1ft-6in", 1350),
    ("6ft-0in x 1ft-6in", 1720),
    ("6ft-6in x 1ft-6in", 1900),
    ("7ft-0in x 1ft-6in", 2230),
    ("3ft-0in x 1ft-0in", 410),
    ("3ft-6in x 1ft-0in", 505),
    ("3ft-7in x 1ft-0in", 520),
    ("4ft-0in x 1ft-0in", 575),
    ("4ft-1in x 1ft-0in", 590),
    ("4ft-6in x 1ft-0in", 635),
    ("4ft-7in x 1ft-Oin", 645),
    ("5ft-0in x 1ft-0in", 815),
    ("5ft-6in x 1ft-0in", 910),
    ("6ft-0in x 1ft-0in", 1175),
    ("6ft-6in x 1ft-0in", 1255)
]

# Generate list of records
records = []
for size, price in products:
    unit_price = price  # Random price within +/- $50 of the given price
    units_in_stock = random.randint(10, 100)  # Random units in stock between 10 and 100
    category_id = 1  # Set category ID to 1 for all records
    records.append((size, unit_price, units_in_stock, category_id))

# Print the list of records
for record in records:
    print(record)

# Generate SQL insert queries
sql_queries = []
i=0
for record in records:
    query = f"('{record[0]}', {record[1]}, {record[2]}, {record[3]}),"
    sql_queries.append(query)
print("INSERT INTO Products (ProductName, UnitPrice, UnitsInStock, CategoryId) VALUES" )
# Print the SQL insert queries
for query in sql_queries:
    print(query)

# List of product sizes and their prices
product_sizes_prices = {
    "4in x 10in": 630,
    "5in x 12in OLD": 780,
    "5in x 13in": 810,
    "5in x 14in OLD": 1065,
    "6in x 15in OLD": 1245,
    "7in x 18in": 1665,
    "7in x 21in": 1830,
    "8in x 19 ½in": 1835,
    "9in x 19in": 2040,
    "9in x 20in(1)": 2345,
    "9in x 20in (II)": 2245,
    "9in x 20in A+": 2295,
    "8in x 24in": 2390,
    "8in x 27in": 2775,
    "8in x 30in": 3055,
    "9in x 30in": 3375,
    "9in x 32in": 3915,
    "10in x 32in": 4340,
    "12in x 36in": 5520
}

# Separate lists for product sizes and prices
product_sizes = list(product_sizes_prices.keys())
product_prices = list(product_sizes_prices.values())

import random

# Function to generate random unit in stock
def generate_random_stock():
    return random.randint(10, 100)

# Constants
category_id = 2

# Generate list of records
records = []
for size, price in product_sizes_prices.items():
    unit_in_stock = generate_random_stock()
    records.append((size, price, unit_in_stock, category_id))

# Print the list of records
for record in records:
    print(record)

# Generate SQL insert queries
sql_queries = []
for record in records:
    query = f"('{record[0]}', {record[1]}, {record[2]}, {record[3]}),"
    sql_queries.append(query)
print("INSERT INTO Products (ProductName, UnitPrice, UnitsInStock, CategoryId) VALUES")
# Print the SQL insert queries
for query in sql_queries:
    print(query)

import random

# Define product names and corresponding unit prices
column_product_prices = {
    "Column 6in x 6½in upto 10 ft": 395,
    "Column 6in x 6½in 10ft-1in to 11 ft": 425,
    "Column 6in x 6½in 11ft-1in to 12 ft": 435,
    "Column 6in x 6½in 12ft-1in to 13 ft": 520,
    "Column 6in x 6½in 13ft-1in to 14 ft": 540
}

# Separate lists for product sizes and prices
product_sizes = list(column_product_prices.keys())
product_prices = list(column_product_prices.values())


# Function to generate random unit in stock
def generate_random_stock():
    return random.randint(10, 100)


# Generate list of records
records = []
category_id = 3
for size, price in column_product_prices.items():
    unit_in_stock = generate_random_stock()
    records.append((size, price, unit_in_stock, category_id))

# Print the list of records
for record in records:
    print(record)

# Generate SQL insert queries
sql_queries = []
for record in records:
    query = f"('{record[0]}', {record[1]}, {record[2]}, {record[3]}),"
    sql_queries.append(query)
print("INSERT INTO Products (ProductName, UnitPrice, UnitsInStock, CategoryId) VALUES")
# Print the SQL insert queries
for query in sql_queries:
    print(query)

import random

# Define the product records
products = [
    ("Planks 2in x12in x 8ft- 0in", 240),
    ("Planks 2in x 8in x 8ft- 0in", 160),
    ("Color Strip 2in x 3in x 8ft- 0in", 250),
    ("Color Strip 2in x 5in x 8ft- 0in", 325),
    ("Boundary Wall Cap 9in x 9in", 245),
    ("Boundary Wall Cap 72in x12in", 310),
    ("Boundary Wal Cap 17in x 18in", 470)
]

# Generate the list of records
records = []
for product_name, unit_price in products:
    units_in_stock = random.randint(50, 500)
    category_id = 4
    record = {
        "Product Name": product_name,
        "Unit Price": unit_price,
        "Units in Stock": units_in_stock,
        "Category ID": category_id
    }
    records.append(record)

# Print the list of records
for record in records:
    print(record)

# Generate the list of SQL insert queries
sql_queries = []
for record in records:
    query = f"('{record['Product Name']}', {record['Unit Price']}, {record['Units in Stock']}, {record['Category ID']}),"
    sql_queries.append(query)
print("INSERT INTO Products (ProductName, UnitPrice, UnitsInStock, CategoryID) VALUES ")
# Print the list of SQL queries
for query in sql_queries:
    print(query)


records = [
    ('2ft-6in x 1ft-6in', 500, 53, 1),
    ('3ft-0in x 1ft-5in', 585, 67, 1),
    ('3ft-5in x 1ft-6in', 660, 66, 1),
    ('3ft-6in x 1ft-6in', 675, 17, 1),
    ('4ft-0in x 1ft-6in', 820, 74, 1),
    ('4ft-6in x 1ft-6in', 835, 46, 1),
    ('4ft-6in x 1ft-6in', 1025, 90, 1),
    ('4ft-0in x 1ft-6in', 1040, 51, 1),
    ('5ft-0in x 1ft-6in', 1205, 69, 1),
    ('5ft-6in x 1ft-6in', 1350, 18, 1),
    ('6ft-0in x 1ft-6in', 1720, 18, 1),
    ('6ft-6in x 1ft-6in', 1900, 81, 1),
    ('7ft-0in x 1ft-6in', 2230, 23, 1),
    ('3ft-0in x 1ft-0in', 410, 49, 1),
    ('3ft-6in x 1ft-0in', 505, 13, 1),
    ('3ft-7in x 1ft-0in', 520, 68, 1),
    ('4ft-0in x 1ft-0in', 575, 19, 1),
    ('4ft-1in x 1ft-0in', 590, 18, 1),
    ('4ft-6in x 1ft-0in', 635, 42, 1),
    ('4ft-7in x 1ft-Oin', 645, 40, 1),
    ('5ft-0in x 1ft-0in', 815, 88, 1),
    ('5ft-6in x 1ft-0in', 910, 54, 1),
    ('6ft-0in x 1ft-0in', 1175, 68, 1),
    ('6ft-6in x 1ft-0in', 1255, 56, 1),
    ('4in x 10in', 630, 17, 2),
    ('5in x 12in OLD', 780, 94, 2),
    ('5in x 13in', 810, 14, 2),
    ('5in x 14in OLD', 1065, 15, 2),
    ('6in x 15in OLD', 1245, 37, 2),
    ('7in x 18in', 1665, 36, 2),
    ('7in x 21in', 1830, 66, 2),
    ('8in x 19 ½in', 1835, 29, 2),
    ('9in x 19in', 2040, 46, 2),
    ('9in x 20in(1)', 2345, 46, 2),
    ('9in x 20in (II)', 2245, 100, 2),
    ('9in x 20in A+', 2295, 33, 2),
    ('8in x 24in', 2390, 59, 2),
    ('8in x 27in', 2775, 44, 2),
    ('8in x 30in', 3055, 43, 2),
    ('9in x 30in', 3375, 78, 2),
    ('9in x 32in', 3915, 44, 2),
    ('10in x 32in', 4340, 92, 2),
    ('12in x 36in', 5520, 89, 2),
    ('Column 6in x 6½in upto 10 ft', 395, 36, 3),
    ('Column 6in x 6½in 10ft-1in to 11 ft', 425, 51, 3),
    ('Column 6in x 6½in 11ft-1in to 12 ft', 435, 63, 3),
    ('Column 6in x 6½in 12ft-1in to 13 ft', 520, 59, 3),
    ('Column 6in x 6½in 13ft-1in to 14 ft', 540, 80, 3),
    ('Planks 2in x12in x 8ft- 0in', 240, 293, 4),
    ('Planks 2in x 8in x 8ft- 0in', 160, 143, 4),
    ('Color Strip 2in x 3in x 8ft- 0in', 250, 306, 4),
    ('Color Strip 2in x 5in x 8ft- 0in', 325, 381, 4),
    ('Boundary Wall Cap 9in x 9in', 245, 93, 4),
    ('Boundary Wall Cap 72in x12in', 310, 424, 4),
    ('Boundary Wal Cap 17in x 18in', 470, 77, 4)
]
print("INSERT INTO Products(ProductID, ProductName, UnitPrice, UnitsInStock, CategoryID) VALUES ")
for index, record in enumerate(records):
    query = f"({index+1}, '{record[0]}', {record[1]}, {record[2]}, {record[3]}),"
    print(query)
