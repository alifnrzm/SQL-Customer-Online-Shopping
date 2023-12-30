# SQL and PowerBI Customer Online Shopping

### Project Overview

Data analysis on Customer Online Shopping behavior in a year. The aim is to create a visualisation that informs about the Revenue, type of products sold, Customer demographics, and losses.

### Data sources

Online Shopping Dataset: from [Kaggle](https://www.kaggle.com/datasets/jacksondivakarr/online-shopping-dataset/data) Conists of file.csv database.

### Tools

- SQLite
	- Data cleaning, Data Preparation
- Python
	- Pandas for importing packages
- Jupyter Notebook
	- Reporting Environment
- PowerBI
	- EDA and Data Visualisation

### Data Cleaning and Preparation

1. Importing essential libraries

```Python

import pandas as pd
import sqlite3
!pip install ipython-sql

```

```Python

csv_path = 'C:\\file.csv'
df = pd.read_csv(csv_path)

```

2. Connecting dataframe to SQLite

```Python

cnn = sqlite3.connect('cust_sqldb')
df.to_sql('custdb', cnn)

```

```Python

%load_ext sql

%sql sqlite:///cust_sqldb

```

3. Checking df

```Python

%%sql

SELECT * FROM custdb LIMIT 10;

```


```Python

%%sql

PRAGMA table_info(custdb);

```

4. Checking and dealing with null values

```Python

%%sql 

SELECT COUNT(*) FROM custdb
WHERE CustomerID IS NULL;

```

```Python

%%sql

DELETE FROM custdb
WHERE CustomerID IS NULL;

```
5. Setting null values in Discount_pct column to 0 for calculation

```Python

%%sql

UPDATE custdb
SET Discount_pct = 0
WHERE Discount_pct IS NULL;

```

### Data Tranformation

1. Dropping columns which are not related to analysis


```Python

%%sql

CREATE TABLE custdbsql AS
SELECT
    "CustomerID",
    "Gender",
    "Location",
    "Transaction_ID",
    "Transaction_Date",
    "Product_Category",
    "Quantity",
    "Avg_Price",
    "Delivery_Charges",
    "Coupon_Status",
    "GST",
    "Coupon_Code",
    "Discount_pct"
FROM custdb;

```

```Python

%%sql

DROP TABLE custdb;

```
2. Changing date data type

```Python

%%sql

UPDATE custdbsql
SET Transaction_Date = DATE(Transaction_Date);

```

3. Adding discounted price column, loss column and Order total column.

```Python

%%sql

ALTER TABLE custdbsql
ADD COLUMN DiscountedPrice DOUBLE;


```


```Python

%%sql

UPDATE custdbsql
SET DiscountedPrice=
    CASE
        WHEN Coupon_Status = 'Used' THEN ROUND(Avg_Price * (1 - (Discount_pct/100)),2)
        ELSE Avg_Price
    END;

```

```Python

%%sql

ALTER TABLE custdbsql
ADD COLUMN OrderTotal DOUBLE;

```

```Python

%%sql

UPDATE custdbsql
SET OrderTotal= ROUND(((DiscountedPrice * Quantity) + (GST * DiscountedPrice * Quantity) + Delivery_Charges),2);

```

```Python

%%sql

ALTER TABLE custdbsql
ADD COLUMN Loss DOUBLE;

```

```Python

%%sql

UPDATE custdbsql
SET Loss = ROUND(((Avg_Price * Quantity) - (DiscountedPrice * Quantity)),2);

```

```Python

%%sql

SELECT * FROM custdbsql LIMIT 30

```

### Data Exploration and Visualisation

![Online Shopping Dashboard](https://github.com/alifnrzm/SQL-Customer-Online-Shopping/blob/main/PBICustDb.JPG)
