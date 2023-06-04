/********************
Data Cleaning
*********************/


-- 1. Find the total number of customers
SELECT DISTINCT COUNT(CustomerID) as TotalNumberOfCustomers
FROM ecommercechurn 
-- Answer = There are 5,630 customers in this dataset

-- 2. Check for duplicate rows
SELECT CustomerID, COUNT (CustomerID) as Count
FROM ecommercechurn
GROUP BY CustomerID
Having COUNT (CustomerID) > 1
-- Answer = There are no duplicate rows

-- 3. Check for null values count for columns with null values
SELECT 'Tenure' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE Tenure IS NULL 
UNION
SELECT 'WarehouseToHome' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE warehousetohome IS NULL 
UNION
SELECT 'HourSpendonApp' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE hourspendonapp IS NULL
UNION
SELECT 'OrderAmountHikeFromLastYear' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE orderamounthikefromlastyear IS NULL 
UNION
SELECT 'CouponUsed' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE couponused IS NULL 
UNION
SELECT 'OrderCount' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE ordercount IS NULL 
UNION
SELECT 'DaySinceLastOrder' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE daysincelastorder IS NULL 

-- 3.1 Handle null values
-- We will fill null values with their mean. 
UPDATE ecommercechurn
SET Hourspendonapp = (SELECT AVG(Hourspendonapp) FROM ecommercechurn)
WHERE Hourspendonapp IS NULL 

UPDATE ecommercechurn
SET tenure = (SELECT AVG(tenure) FROM ecommercechurn)
WHERE tenure IS NULL 

UPDATE ecommercechurn
SET orderamounthikefromlastyear = (SELECT AVG(orderamounthikefromlastyear) FROM ecommercechurn)
WHERE orderamounthikefromlastyear IS NULL 

UPDATE ecommercechurn
SET WarehouseToHome = (SELECT  AVG(WarehouseToHome) FROM ecommercechurn)
WHERE WarehouseToHome IS NULL 

UPDATE ecommercechurn
SET couponused = (SELECT AVG(couponused) FROM ecommercechurn)
WHERE couponused IS NULL 

UPDATE ecommercechurn
SET ordercount = (SELECT AVG(ordercount) FROM ecommercechurn)
WHERE ordercount IS NULL 

UPDATE ecommercechurn
SET daysincelastorder = (SELECT AVG(daysincelastorder) FROM ecommercechurn)
WHERE daysincelastorder IS NULL 


--4. Create a new column based off the values of churn column.
-- The values in churn column are 0 and 1 values were O means stayed and 1 means churned. I will create a new column 
-- called customerstatus that shows 'Stayed' and 'Churned' instead of 0 and 1
ALTER TABLE ecommercechurn
ADD CustomerStatus NVARCHAR(50)

UPDATE ecommercechurn
SET CustomerStatus = 
CASE 
    WHEN Churn = 1 THEN 'Churned' 
    WHEN Churn = 0 THEN 'Stayed'
END 

-- 5. Create a new column based off the values of complain column.
-- The values in complain column are 0 and 1 values were O means No and 1 means Yes. I will create a new column 
-- called complainrecieved that shows 'Yes' and 'No' instead of 0 and 1  
ALTER TABLE ecommercechurn
ADD ComplainRecieved NVARCHAR(10)

UPDATE ecommercechurn
SET ComplainRecieved =  
CASE 
    WHEN complain = 1 THEN 'Yes'
    WHEN complain = 0 THEN 'No'
END


-- 6. Check values in each column for correctness and accuracy

-- 6.1 a) Check distinct values for preferredlogindevice column
select distinct preferredlogindevice 
from ecommercechurn
-- the result shows phone and mobile phone which indicates the same thing, so I will replace mobile phone with phone

-- 6.1 b) Replace mobile phone with phone
UPDATE ecommercechurn
SET preferredlogindevice = 'phone'
WHERE preferredlogindevice = 'mobile phone'

-- 6.2 a) Check distinct values for preferedordercat column
select distinct preferedordercat 
from ecommercechurn
-- the result shows mobile phone and mobile, so I replace mobile with mobile phone

-- 6.2 b) Replace mobile with mobile phone
UPDATE ecommercechurn
SET preferedordercat = 'Mobile Phone'
WHERE Preferedordercat = 'Mobile'

-- 6.3 a) Check distinct values for preferredpaymentmode column
select distinct PreferredPaymentMode 
from ecommercechurn
-- the result shows Cash on Delivery and COD which mean the same thing, so I replace COD with Cash on Delivery

-- 6.3 b) Replace mobile with mobile phone
UPDATE ecommercechurn
SET PreferredPaymentMode  = 'Cash on Delivery'
WHERE PreferredPaymentMode  = 'COD'

-- 6.4 a) check distinct value in warehousetohome column
SELECT DISTINCT warehousetohome
FROM ecommercechurn
-- I can see two values 126 and 127 that are outliers, it could be a data entry error, so I will correct it to 26 & 27 respectively

-- 6.4 b) Replace value 127 with 27
UPDATE ecommercechurn
SET warehousetohome = '27'
WHERE warehousetohome = '127'

-- 6.4 C) Replace value 126 with 26
UPDATE ecommercechurn
SET warehousetohome = '26'
WHERE warehousetohome = '126'


/**************************************************
Data Exploration and Answering business questions
***************************************************/


-- 1. What is the overall customer churn rate?
SELECT TotalNumberofCustomers, 
       TotalNumberofChurnedCustomers,
       CAST((TotalNumberofChurnedCustomers * 1.0 / TotalNumberofCustomers * 1.0)*100 AS DECIMAL(10,2)) AS ChurnRate
FROM
(SELECT COUNT(*) AS TotalNumberofCustomers
FROM ecommercechurn) AS Total,
(SELECT COUNT(*) AS TotalNumberofChurnedCustomers
FROM ecommercechurn
WHERE CustomerStatus = 'churned') AS Churned
-- Answer = The Churn rate is 16.84%


-- 2. How does the churn rate vary based on the preferred login device?
SELECT preferredlogindevice, 
        COUNT(*) AS TotalCustomers,
        SUM(churn) AS ChurnedCustomers,
        CAST(SUM (churn) * 1.0 / COUNT(*) * 100 AS DECIMAL(10,2)) AS ChurnRate
FROM ecommercechurn
GROUP BY preferredlogindevice
-- Answer = The prefered login devices are computer and phone. Computer accounts for the highest churnrate
-- with 19.83% and then phone with 15.62%. 


-- 3. What is the distribution of customers across different city tiers?
SELECT citytier, 
       COUNT(*) AS TotalCustomer, 
       SUM(Churn) AS ChurnedCustomers, 
       CAST(SUM (churn) * 1.0 / COUNT(*) * 100 AS DECIMAL(10,2)) AS ChurnRate
FROM ecommercechurn
GROUP BY citytier
ORDER BY churnrate DESC
-- Answer = citytier3 has the highest churn rate, followed by citytier2 and then citytier1 has the least churn rate.


-- 4. Is there any correlation between the warehouse-to-home distance and customer churn?
-- Firstly, we will create a new column that provides a distance range based on the values in warehousetohome column
ALTER TABLE ecommercechurn
ADD warehousetohomerange NVARCHAR(50)

UPDATE ecommercechurn
SET warehousetohomerange =
CASE 
    WHEN warehousetohome <= 10 THEN 'Very close distance'
    WHEN warehousetohome > 10 AND warehousetohome <= 20 THEN 'Close distance'
    WHEN warehousetohome > 20 AND warehousetohome <= 30 THEN 'Moderate distance'
    WHEN warehousetohome > 30 THEN 'Far distance'
END

-- Finding correlation between warehousetohome and churnrate
SELECT warehousetohomerange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY warehousetohomerange
ORDER BY Churnrate DESC
-- Answer = The churn rate increases as the warehousetohome distance increases


-- 5. Which is the most prefered payment mode among churned customers?
SELECT preferredpaymentmode,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY preferredpaymentmode
ORDER BY Churnrate DESC
-- Answer = The most prefered payment mode among churned customers is Cash on Delivery


-- 6. What is the typical tenure for churned customers?
-- Firstly, we will create a new column that provides a tenure range based on the values in tenure column
ALTER TABLE ecommercechurn
ADD TenureRange NVARCHAR(50)

UPDATE ecommercechurn
SET TenureRange =
CASE 
    WHEN tenure <= 6 THEN '6 Months'
    WHEN tenure > 6 AND tenure <= 12 THEN '1 Year'
    WHEN tenure > 12 AND tenure <= 24 THEN '2 Years'
    WHEN tenure > 24 THEN 'more than 2 years'
END

-- Finding typical tenure for churned customers
SELECT TenureRange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY TenureRange
ORDER BY Churnrate DESC
-- Answer = Most customers churned within a 6 months tenure period


-- 7. Is there any difference in churn rate between male and female customers?
SELECT gender,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY gender
ORDER BY Churnrate DESC
-- Answer = More men churned in comaprison to wowen 


-- 8. How does the average time spent on the app differ for churned and non-churned customers?
SELECT customerstatus, avg(hourspendonapp) AS AverageHourSpentonApp
FROM ecommercechurn
GROUP BY customerstatus
-- Answer = There is no difference between the average time spent on the app for churned and non-churned customers


-- 9. Does the number of registered devices impact the likelihood of churn?
SELECT NumberofDeviceRegistered,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY NumberofDeviceRegistered
ORDER BY Churnrate DESC
-- Answer = As the number of registered devices increseas the churn rate increases. 


-- 10. Which order category is most prefered among churned customers?
SELECT preferedordercat,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY preferedordercat
ORDER BY Churnrate DESC
-- Answer = Mobile phone category has the highest churn rate and grocery has the least churn rate


-- 11. Is there any relationship between customer satisfaction scores and churn?
SELECT satisfactionscore,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY satisfactionscore
ORDER BY Churnrate DESC
-- Answer = Customer satisfaction score of 5 has the highest churn rate, satisfaction score of 1 has the least churn rate


-- 12. Does the marital status of customers influence churn behavior?
SELECT maritalstatus,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY maritalstatus
ORDER BY Churnrate DESC
-- Answer = Single customers have the highest churn rate while married customers have the least churn rate


-- 13. How many addresses do churned customers have on average?
SELECT AVG(numberofaddress) AS Averagenumofchurnedcustomeraddress
FROM ecommercechurn
WHERE customerstatus = 'stayed'
-- Answer = On average, churned customers have 4 addresses


-- 14. Does customer complaints influence churned behavior?
SELECT complainrecieved,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY complainrecieved
ORDER BY Churnrate DESC
-- Answer = Customers with complains had the highest churn rate


-- 15. How does the usage of coupons differ between churned and non-churned customers?
SELECT customerstatus, SUM(couponused) AS SumofCouponUsed
FROM ecommercechurn
GROUP BY customerstatus
-- Churned customers used less coupons in comparison to non churned customers


-- 16. What is the average number of days since the last order for churned customers?
SELECT AVG(daysincelastorder) AS AverageNumofDaysSinceLastOrder
FROM ecommercechurn
WHERE customerstatus = 'churned'
-- Answer = The average number of days since last order for churned customer is 3


-- 17. Is there any correlation between cashback amount and churn rate?
-- Firstly, we will create a new column that provides a tenure range based on the values in tenure column
ALTER TABLE ecommercechurn
ADD cashbackamountrange NVARCHAR(50)

UPDATE ecommercechurn
SET cashbackamountrange =
CASE 
    WHEN cashbackamount <= 100 THEN 'Low Cashback Amount'
    WHEN cashbackamount > 100 AND cashbackamount <= 200 THEN 'Moderate Cashback Amount'
    WHEN cashbackamount > 200 AND cashbackamount <= 300 THEN 'High Cashback Amount'
    WHEN cashbackamount > 300 THEN 'Very High Cashback Amount'
END

-- Finding correlation between cashbackamountrange and churned rate
SELECT cashbackamountrange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY cashbackamountrange
ORDER BY Churnrate DESC
-- Answer = Customers with a Moderate Cashback Amount (Between 100 and 200) have the highest churn rate, follwed by
-- High cashback amount, then very high cashback amount and finally low cashback amount




