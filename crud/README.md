## Here is the code for the todo app in terraform using aws
## this includes the following
- aws lambda for CRUD
- aws rds relational database for storing the data
- aws api gateway for the api

## Steps to run the code
- terraform validate
- terraform plan
- terraform apply

## Steps to destroy the code
- terraform destroy

## connect to the database and add create this table

```sql
CREATE TABLE todos (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## things to consider 
- your database is publically accessible, you must change it for prod environment