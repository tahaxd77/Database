import random

# Function to generate a random price
def generate_price():
    return round(random.uniform(10.00, 500.00), 2)

order_ids = list(range(1, 601))  # Order IDs from 1 to 600

    # Repeat the order_ids list enough times to cover the number of records needed
repeated_order_ids = order_ids * ((num_records // len(order_ids)) + 1)
random.shuffle(repeated_order_ids)  # Shuffle to distribute uniformly


# Function to generate a list of order details
def generate_order_details(num_records):
    order_details = []
    for i in range(1, num_records + 1):
        order_detail = {
            'OrderDetailID': i,
            'OrderID': repeated_order_ids[i - 1],
            'ProductID': random.randint(1, 55),
            'Quantity': random.randint(1, 100),
            'Price': generate_price()
        }
        order_details.append(order_detail)
    return order_details

# Function to generate single-line EXEC commands for order details
def generate_exec_commands(order_details):
    exec_commands = []
    for detail in order_details:
        command = (f"EXEC InsertOrderDetail {detail['OrderDetailID']},{detail['ProductID']},{detail['Quantity']},{detail['OrderID']};")
        exec_commands.append(command)
    return exec_commands

# Generate the order details
num_records = 1000  # You can adjust this number as needed
order_details = generate_order_details(num_records)

# Generate the EXEC commands
commands = generate_exec_commands(order_details)

# Print the EXEC commands
for command in commands:
    print(command)