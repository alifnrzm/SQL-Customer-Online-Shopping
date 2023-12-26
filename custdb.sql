# SET global to iport table using local infile method
SET GLOBAL local_infile = 'ON';
SHOW VARIABLES LIKE 'secure_file_priv';

# Create table and assigning data types; With dates set to varchar first to avoid error during import
CREATE TABLE custdb (
    noindex INT,
    CustomerID INT,
    Gender CHAR,
    Location VARCHAR(255),
    Tenure INT,
    TransactionID INT,
    TransactionDate VARCHAR(10),
    ProductSKU VARCHAR(255),
    ProductDesc VARCHAR(255),
    ProductCat VARCHAR(255),
    Quantity INT,
    AvgPrice DOUBLE,
    DeliveryCharge DOUBLE,
    CouponStatus VARCHAR(255),
    GST DOUBLE,
    Date_trans VARCHAR(10),
    OfflineSpend DOUBLE,
    OnlineSpend DOUBLE,
    MonthTrans INT,
    CouponCode VARCHAR(255),
    DiscountPct INT
);


# Import csv file into sql and set all blank to nulll in each empty cell in csv
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/file.csv'
INTO TABLE custdb
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@noindex,@CustomerID,@Gender,@Location,@Tenure,@TransactionID,@TransactionDate,@ProductSKU,@ProductDesc,@ProductCat,@Quantity,@AvgPrice,@DeliveryCharge,@CouponStatus,@GST,@Date_trans,@OfflineSpend,@OnlineSpend,@MonthTrans,@CouponCode,@DiscountPct) 
SET
    noindex = NULLIF(@noindex, ''),
    CustomerID = NULLIF(@CustomerID, ''),
    Gender = NULLIF(@Gender, ''),
    Location = NULLIF(@Location, ''),
    Tenure = NULLIF(@Tenure, ''),
    TransactionID = NULLIF(@TransactionID, ''),
    TransactionDate = NULLIF(@TransactionDate, ''),
    ProductSKU = NULLIF(@ProductSKU, ''),
    ProductDesc = NULLIF(@ProductDesc, ''),
    ProductCat = NULLIF(@ProductCat, ''),
    Quantity = NULLIF(@Quantity, ''),
    AvgPrice = NULLIF(@AvgPrice, ''),
    DeliveryCharge = NULLIF(@DeliveryCharge, ''),
    CouponStatus = NULLIF(@CouponStatus, ''),
    GST = NULLIF(@GST, ''),
    Date_trans = NULLIF(@Date_trans, ''),
    OfflineSpend = NULLIF(@OfflineSpend, ''),
    OnlineSpend = NULLIF(@OnlineSpend, ''),
    MonthTrans = NULLIF(@MonthTrans, ''),
    CouponCode = NULLIF(@CouponCode, ''),
    DiscountPct = NULLIF(@DiscountPct, '');

# Delete null customer id as it is the primary key
DELETE FROM custdb
WHERE CustomerID IS NULL;

# Set null values in discountpct to 0 as it will be used in calculation
UPDATE custdb
SET DiscountPct = 0
WHERE DiscountPct IS NULL;

# Dropping columns that are not realted to analysis
ALTER TABLE custdb
DROP COLUMN ProductDesc, DROP COLUMN Date_trans, DROP COLUMN OfflineSpend, DROP COLUMN OnlineSpend;

# Set TransactionDate column to DATE datatype
ALTER TABLE custdb
MODIFY COLUMN TransactionDate DATE;

# Add new column of DiscountedPrice after discount
ALTER TABLE custdb
ADD COLUMN DiscountedPrice DOUBLE;

UPDATE custdb
SET DiscountedPrice=
	CASE
		WHEN CouponStatus = 'Used' THEN ROUND(AvgPrice * (1 - (DiscountPct/100)),2)
        ELSE AvgPrice
	END;

# Add new column of OrderTotal after adding shipping cost and added gst cost
ALTER TABLE custdb
ADD COLUMN OrderTotal DOUBLE;

UPDATE custdb
SET OrderTotal= ROUND(((DiscountedPrice * Quantity) + (GST * DiscountedPrice * Quantity) + DeliveryCharge),2);

# Add new column of Loss between old price to discounted price
ALTER TABLE custdb
ADD COLUMN Loss DOUBLE;

UPDATE custdb
SET Loss = ROUND(((AvgPrice * Quantity) - (DiscountedPrice * Quantity)),2);

SELECT * FROM custdb limit 10
