#!/bin/bash

# Ensure jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Installing jq..."
    sudo yum install -y jq
fi

# Set MySQL connection details
DB_HOST="localhost"  # If running MySQL on the same EC2 instance, use "localhost" or private IP
DB_PORT=3307
DB_NAME="employees"
SECRET_ID="mysql_password_setup"

# Retrieve credentials from AWS Secrets Manager
echo "Fetching database credentials from AWS Secrets Manager..."
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id "$SECRET_ID" --query SecretString --output text)

# Extract username and password from JSON response
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')

# MySQL query
QUERY="
SELECT * FROM dept_emp limit 10;
SELECT * FROM dept_emp_latest_date limit 15;
SELECT * FROM dept_manager limit 15;
SELECT * FROM employees limit 15;
SELECT * FROM salaries limit 13;
SELECT * FROM titles limit 10;
"

# Execute MySQL query
echo "Connecting to MySQL and executing query..."
mysql --host="$DB_HOST" --port="$DB_PORT" --user="$DB_USER" --password="$DB_PASS" --database="$DB_NAME" -e "$QUERY"

# Exit script
exit 0
