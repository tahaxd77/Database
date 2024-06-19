import random

# List of Pakistani first names
first_names = ["Muhammad", "Ali", "Fatima", "Aisha", "Ahmed", "Hassan", "Sana", "Saima", "Usman", "Amna", "Zainab", "Farhan", "Sadia", "Bilal", "Sara", "Tariq", "Maryam", "Asad", "Hira", "Naveed"]

# List of Pakistani last names
last_names = ["Khan", "Ahmed", "Malik", "Ali", "Hussain", "Iqbal", "Farooq", "Rehman", "Zahid", "Raza", "Akhtar", "Hassan", "Nawaz", "Yousaf", "Mehmood", "Rashid", "Aslam", "Nasir", "Imran", "Abbas"]

# List of Pakistani area names in Lahore
areas_in_lahore = ["Gulberg", "Model Town", "Johar Town", "Defence", "Township", "Garden Town", "Faisal Town", "Cantt", "Iqbal Town", "Shadman", "Samanabad", "Allama Iqbal Town", "Wapda Town", "Sabzazar", "Ghulshan-e-Ravi", "Raiwind Road", "Liaqatabad", "Shahdara", "DHA", "Gulshan-e-Lahore"]

# Function to generate a Pakistani contact number
def generate_contact_number():
    number = "03" + str(random.randint(10, 99)) + str(random.randint(1000000, 9999999))
    return number

# Generate 50 records for the customer table
customer_records = []
for i in range(1, 151):
    first_name = random.choice(first_names)
    last_name = random.choice(last_names)
    full_name = f"{first_name} {last_name}"
    contact_number = generate_contact_number()
    address = random.choice(areas_in_lahore)
    city = "Lahore"
    customer_id = i
    customer_record = {
        "CustomerID": customer_id,
        "CustomerName": full_name,
        "ContactNumber": contact_number,
        "Address": address,
        "City": city
    }
    customer_records.append(customer_record)

exec_commands = []
for customer in customer_records:
        command = (f"EXEC InsertCustomer {customer['CustomerID']}, '{customer['CustomerName']}','{customer['ContactNumber']}', '{customer['Address']}','{customer['City']}';")
        exec_commands.append(command)
        print(command)
