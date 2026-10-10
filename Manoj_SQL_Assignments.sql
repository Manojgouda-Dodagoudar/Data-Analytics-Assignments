use classicmodels;
select * from customers;
select * from employees;
select * from offices;
select * from orderdetails;
select * from orders;
select * from payments;
select * from productlines;
select * from products;

-- Q1. a.	Fetch the employee number, first name and last name of those employees who are working as Sales Rep reporting to employee with employeenumber 1102
SELECT  employeeNumber, firstName, lastName FROM employees WHERE jobTitle = 'Sales Rep' AND reportsTo = 1102;

-- Q1. b.	Show the unique productline values containing the word cars at the end from the products table.
SELECT DISTINCT productLine FROM products WHERE productLine LIKE '%Cars';

-- Q2. a. Using a CASE statement, segment customers into three categories based on their country
SELECT customerNumber, customerName, CASE WHEN country IN ('USA', 'Canada') THEN 'North America' WHEN country IN ('UK', 'France', 'Germany') THEN 'Europe'
ELSE 'Other' END AS CustomerSegment FROM customers;

-- Q3. a.	Using the OrderDetails table, identify the top 10 products (by productCode) with the highest total order quantity across all orders.
SELECT productCode, SUM(quantityOrdered) AS total_ordered FROM orderdetails GROUP BY productCode ORDER BY total_ordered DESC LIMIT 10;

-- Q3. b.	Company wants to analyse payment frequency by month. Extract the month name from the payment date to count the total number of payments for each month and include only those months 
       -- with a payment count exceeding 20. Sort the results by total number of payments in descending order
SELECT MONTHNAME(paymentDate) AS payment_month, COUNT(*) AS num_payments FROM payments GROUP BY MONTHNAME(paymentDate), MONTH(paymentDate)
HAVING COUNT(*) > 20 ORDER BY num_payments DESC;

-- Q4. a.	Create a table named Customers to store customer information. Include the following columns:
CREATE DATABASE Customers_Orders;
USE Customers_Orders;
CREATE TABLE Customers (customer_id INT PRIMARY KEY AUTO_INCREMENT, first_name VARCHAR(50) NOT NULL, last_name VARCHAR(50) NOT NULL, email VARCHAR(255) UNIQUE, phone_number VARCHAR(20));

-- Q4. b.	Create a table named Orders to store information about customer orders. Include the following columns:
CREATE TABLE Orders (order_id INT PRIMARY KEY AUTO_INCREMENT, customer_id INT, order_date DATE, total_amount DECIMAL(10,2), FOREIGN KEY (customer_id) REFERENCES Customers(customer_id), CHECK (total_amount > 0));

-- Q5. List the top 5 countries (by order count) that Classic Models ships to.
USE classicmodels;
SELECT c.country, COUNT(o.orderNumber) AS order_count FROM customers c JOIN orders o ON c.customerNumber = o.customerNumber
GROUP BY c.country ORDER BY order_count DESC LIMIT 5;

-- Q6 a. Create a table project with below fields.
CREATE TABLE project (EmployeeID INT PRIMARY KEY AUTO_INCREMENT, FullName VARCHAR(50) NOT NULL, Gender VARCHAR(10), ManagerID INT, CHECK (Gender IN ('Male', 'Female')));
INSERT INTO project (EmployeeID, FullName, Gender, ManagerID)
VALUES
(1, 'Pranaya', 'Male', 3),
(2, 'Priyanka', 'Female', 1),
(3, 'Preety', 'Female', NULL),
(4, 'Anurag', 'Male', 1),
(5, 'Sambit', 'Male', 1),
(6, 'Rajesh', 'Male', 3),
(7, 'Hina', 'Female', 3);
SELECT m.FullName AS Manager_Name, e.FullName AS Emp_Name FROM project e JOIN project m ON e.ManagerID = m.EmployeeID;

-- Q7. a. Create table facility. Add the below fields into it.
CREATE TABLE facility (Facility_ID INT, Name VARCHAR(100), State VARCHAR(100), Country VARCHAR(100));
ALTER TABLE facility MODIFY Facility_ID INT PRIMARY KEY AUTO_INCREMENT;
ALTER TABLE facility ADD city VARCHAR(100) NOT NULL AFTER Name;
select * from facility;
desc facility;

use classicmodels;

-- Q8. a. Create a view named product_category_sales that provides insights into sales performance by product category
CREATE VIEW product_category_sales AS SELECT  p.productLine, SUM(od.quantityOrdered * od.priceEach) AS total_sales, COUNT(DISTINCT o.orderNumber) AS number_of_orders
FROM products p JOIN orderdetails od ON p.productCode = od.productCode JOIN orders o ON od.orderNumber = o.orderNumber GROUP BY p.productLine;
SELECT * FROM product_category_sales;

-- Q9. a. Create a stored procedure Get_country_payments which takes in year and country as inputs and gives year wise, country wise total amount as an output. Format the total amount to nearest thousand unit (K)
DELIMITER //
CREATE PROCEDURE Get_country_payments(IN p_year INT, IN p_country VARCHAR(50))
BEGIN SELECT YEAR(p.paymentDate) AS payment_year, c.country, CONCAT(ROUND(SUM(p.amount) / 1000, 0), 'K') AS total_amount
FROM payments p JOIN customers c ON p.customerNumber = c.customerNumber WHERE YEAR(p.paymentDate) = p_year AND c.country = p_country
GROUP BY YEAR(p.paymentDate), c.country;
END //
DELIMITER ;
CALL Get_country_payments(2003, 'France');

-- Q10. a) Using customers and orders tables, rank the customers based on their order frequency
SELECT  c.customerName, COUNT(o.orderNumber) AS Order_count, DENSE_RANK() OVER (ORDER BY COUNT(o.orderNumber) DESC) AS order_frequency_rnk
FROM customers c JOIN orders o ON c.customerNumber = o.customerNumber GROUP BY c.customerNumber, c.customerName ORDER BY Order_count DESC;

-- Q10. b) Calculate year wise, month name wise count of orders and year over year (YoY) percentage change. Format the YoY values in no decimals and show in % sign.
WITH monthly_orders AS (SELECT YEAR(orderDate) AS Year, MONTH(orderDate) AS Month_Num, MONTHNAME(orderDate) AS Month, COUNT(orderNumber) AS Total_Orders
FROM orders GROUP BY YEAR(orderDate), MONTH(orderDate), MONTHNAME(orderDate))
SELECT Year, Month, Total_Orders, CONCAT(ROUND((Total_Orders - LAG(Total_Orders) OVER (ORDER BY Year, Month_Num))/ LAG(Total_Orders) OVER (ORDER BY Year, Month_Num) * 100,0), '%') AS `% YoY Change`
FROM monthly_orders ORDER BY Year, Month_Num;

-- Q11. a. Find out how many product lines are there for which the buy price value is greater than the average of buy price value. Show the output as product line and its count.
SELECT productLine, COUNT(*) AS Total FROM products WHERE buyPrice > 
(SELECT AVG(buyPrice) FROM products) GROUP BY productLine ORDER BY Total DESC;		

-- Q12.   Create the table Emp_EH. Below are its fields.
CREATE TABLE Emp_EH (EmpID INT PRIMARY KEY, EmpName VARCHAR(100), EmailAddress VARCHAR(255));
DELIMITER //
CREATE PROCEDURE Insert_Emp_EH( IN p_EmpID INT, IN p_EmpName VARCHAR(100), IN p_EmailAddress VARCHAR(255))
BEGIN DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN SELECT 'Error occurred' AS Message; 
END;
INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress) VALUES (p_EmpID, p_EmpName, p_EmailAddress);
END //
DELIMITER ;
CALL Insert_Emp_EH(1, 'Ravi', 'ravi@gmail.com');
select * from Emp_EH;
CALL Insert_Emp_EH(1, 'Ravi', 'ravi@gmail.com');

-- Q13. Create the table Emp_BIT. Add below fields in it.
CREATE TABLE Emp_BIT ( Name VARCHAR(50), Occupation VARCHAR(50), Working_date DATE, Working_hours INT);
INSERT INTO Emp_BIT VALUES
('Robin', 'Scientist', '2020-10-04', 12),
('Warner', 'Engineer', '2020-10-04', 10),
('Peter', 'Actor', '2020-10-04', 13),
('Marco', 'Doctor', '2020-10-04', 14),
('Brayden', 'Teacher', '2020-10-04', 12),
('Antonio', 'Business', '2020-10-04', 11);

select * from Emp_Bit;
DELIMITER //
CREATE TRIGGER before_emp_bit_insert BEFORE INSERT ON Emp_BIT FOR EACH ROW
BEGIN IF NEW.Working_hours < 0 THEN SET NEW.Working_hours = ABS(NEW.Working_hours);
END IF;
END //
DELIMITER ;

INSERT INTO Emp_BIT
VALUES ('Test', 'Engineer', '2020-10-04', -8);

select * from Emp_Bit;