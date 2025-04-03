import mysql.connector
from mysql.connector import Error
import random
import uuid
from datetime import datetime
import boto3
import json
import base64
from botocore.exceptions import ClientError
from faker import Faker
import os
import re
from datetime import timedelta

# initialize faker
fake = Faker()

# map countries to cities
country_city_mapping = {
    'UK':['London','Manchester','Birmingham','Leeds']
}

# Get database credentials from AWS Secrets Manager
def get_db_credentials():
    secret_name = os.getenv('SECRET_NAME') # Get secret name from environment variable
    region_name = os.getenv('REGION_NAME') # Get region name from environment variable

    session = boto3.session.Session()
    client = session.client(service_name = "secretsmanager", region_name = region_name)

    try:
        get_secret_value_response = client.get_secret_value(SecretId = secret_name)

        if "SecretString" in get_secret_value_response:
            secret = get_secret_value_response["SecretString"]
        else:
            secret = base64.b64decode(get_secret_value_response["SecretBinary"])
        
        return json.loads(secret)
    except ClientError as e:
        print(f"error retrieving secret from secrets manager: {e}")
        raise e
    
# create a connection to MySQL(Amazon RDS)
def create_connection():
    # get the database credentials from Secrets Manager
    db_credentials = get_db_credentials()

    try:
        connection = mysql.connector.connect(
            host = db_credentials["host"],
            user = db_credentials["username"],
            password = db_credentials["password"],
            database = db_credentials["dbname"]
        )
        if connection.is_connected():
            print("Connected to MySQL Database")
        return connection
    except Error as e:
        print(f"Error while connecting to MYSQL: {e}")
        return None
    
# Insert Products
def insert_products(cursor, num_products):
    for _ in range(num_products):
        productId = str(uuid.uuid4())
        productName = fake.word().capitalize()
        brandName = random.choices(['Urban Nomad','Coastal','Threads','Silver & Stitch','Lilo'], weights=[10,10,40,20,20])
        print(brandName)
        productDescription = fake.sentence()
        price = round(random.uniform(10,100),2)
        productCategory = random.choices(['Jewelry','Bags','Clothing','Swimwear','Shoes'], weights=[20,10,40,20,10])

        insert_query = """INSERT INTO Product (productId,productName,brandName,productDescription,price,productCategory) VALUES (%s,%s,%s,%s,%s,%s)"""
        cursor.execute(insert_query,(productId,productName,brandName,productDescription,price,productCategory))

# Insert Customers
def insert_customers(cursor,num_customers):
    for _ in range(num_customers):
        customerId = str(uuid.uuid4())
        Name = fake.name()
        # Convert name to lowercase and remove spaces or special characters to create an email
        formatted_name = re.sub(r'[^a-zA-Z]','',Name.lower())
        Email = f"{formatted_name}@email.com"
        Phone = fake.phone_number()
        Address = fake.street_address()
        Country = random.choice(list(country_city_mapping.keys()))
        City = random.choices(country_city_mapping[Country], weights=[60,20,10,10])[0]

        insert_query = """INSERT INTO Customer (customerId,Name,Email,Phone,Address,Country,City) VALUES (%s,%s,%s,%s,%s,%s,%s)"""
        cursor.execute(insert_query,(customerId,Name,Email,Phone,Address,Country,City))
    
# Update Customer Data
def update_customers(cursor):
    cursor.execute("SELECT customerId from Customer")
    customer_ids = [row[0] for row in cursor.fetchall()]

    if customer_ids:
        customerId = random.choice(customer_ids)
        new_email = fake.email()
        new_phone = fake.phone_number()

        update_query = """UPDATE Customer SET Email = %s, Phone = %s where customerId = %s"""
        cursor.execute(update_query,(new_email,new_phone,customerId))

# Delete Customer Data
def delete_customers(cursor):
    cursor.execute("Select customerId from Customer")
    customer_ids = [row[0] for row in cursor.fetchall()]

    if customer_ids:
        customerId = random.choice(customer_ids)
        delete_query = """DELETE FROM Customer WHERE customerId = %s"""
        cursor.execute(delete_query,(customerId,))

def insert_orders_and_order_details(cursor, num_orders):
    cursor.execute("SELECT productId FROM Product")
    product_ids = [row[0]for row in cursor.fetchall()]

    start_date = datetime(2024,1,1)
    end_date = datetime(2024,12,31)
    total_days = (end_date-start_date).days

    cursor.execute("SELECT customerId FROM Customer")
    customer_ids = [row[0] for row in cursor.fetchall()]

    for _ in range(num_orders):
        # Create order
        orderId = str(uuid.uuid4())
        orderCustomerId = random.choice(customer_ids)

        random_days = random.randint(0,total_days)
        orderDate = (start_date + timedelta(days = random_days)).strftime('%Y-%m-%d')

        paymentMethod = random.choices(['Credit Card','PayPal','Bank Transfer'],weights=[80,15,5])[0]
        orderPlatform = random.choices(['Website','Mobile','In-store'],weights=[50,30,20])[0]

        insert_order_query = """INSERT INTO Orders (orderId,orderCustomerId,orderDate,paymentMethod,orderPlatform) VALUES (%s,%s,%s,%s,%s)"""
        cursor.execute(insert_order_query,(orderId,orderCustomerId,orderDate,paymentMethod,orderPlatform))

        # Insert corresponding order details for the created order
        num_order_details = random.randint(1,5) #random number of order details per order
        for _ in range(num_order_details):
            orderDetailsId = str(uuid.uuid4())
            productId = random.choice(product_ids)
            Quantity = random.randint(1,5)

            insert_order_details_query = """INSERT INTO orderDetails (orderDetailsId, orderId, productId, Quantity) VALUES (%s,%s,%s,%s)"""
            cursor.execute(insert_order_details_query,(orderDetailsId, orderId, productId, Quantity))


# Main Lambda Handler Function
def lambda_handler(event, context):
    connection = create_connection()
    if connection is not None:
        cursor = connection.cursor()
        try:
            connection.autocommit = False

            # Insert products occassionally
            if random.random():
                insert_products(cursor,random.randint(1,2))
            
            # Insert customers occassionally
            if random.random():
                insert_customers(cursor,random.randint(1,3))
            
            # Insert orders and their corresponding order details
            insert_orders_and_order_details(cursor,random.randint(5,15))

            # occassionally update and delete customer data
            if random.random()<0.5: #50% chance to update custoemers
                update_customers(cursor)
            if random.random()<0.2: #20% chance to update custoemers
                delete_customers(cursor)
            
            connection.commit()

            return {
                'statusCode':200,
                'body':'Data successfully inserted, updated and/or deleted in the database'
            }
        except Error as e:
            print(f"error while inserting data: {e}")
            connection.rollback()
            return {
                'statusCode':500,
                'body':f"Error occurred: {e}"
            }
        finally:
            cursor.close()
            connection.close()
            print("Connection Closed")
    else:
        return{
            'statusCode':500,
            'body':'failed to connect to the database'
        }






