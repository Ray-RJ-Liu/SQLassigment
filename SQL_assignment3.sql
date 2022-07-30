USE Northwind
GO
--1.Create a view named “view_product_order_[your_last_name]”, list all products and total ordered quantity for that product.
CREATE VIEW view_product_order_LIU
AS
SELECT P.ProductName, SUM(OD.Quantity)NumProduct
FROM dbo.[Order Details] OD LEFT JOIN dbo.Products P ON OD.ProductID = P.ProductID
GROUP BY P.ProductName

GO

SELECT *
FROM view_product_order_LIU
ORDER BY view_product_order_LIU.ProductName

GO

--2.Create a stored procedure “sp_product_order_quantity_[your_last_name]” that accept product id as an input and total quantities of order as output parameter.
CREATE PROC sp_product_order_quantity_LIU
@Productid int,
@TotalNumOrdered int OUT
AS
BEGIN
	WITH cte AS(
		SELECT OD.ProductID, SUM(OD.Quantity)NumProduct
		FROM dbo.[Order Details] OD 
		GROUP BY OD.ProductID)
	SELECT @TotalNumOrdered  = cte.NumProduct FROM cte WHERE cte.ProductID = @Productid
END

BEGIN
DECLARE @en int
EXEC sp_product_order_quantity_LIU 3, @en out
PRINT @en
END

GO
--3.Create a stored procedure “sp_product_order_city_[your_last_name]” that accept product name as an input and top 5 cities that ordered most that product combined with the total quantity of that product ordered from that city as output.
CREATE PROC sp_product_order_city_LIU
@Productname varchar(20)
AS
BEGIN
DECLARE @result table (city varchar(20), num int);
WITH cte AS(
			SELECT dt2.ProductName,C.City,SUM(dt2.Quantity)NumProductOrdered,ROW_NUMBER() OVER(PARTITION BY dt2.ProductName ORDER BY C.City) RNK
			FROM (	SELECT P.ProductName, dt1.Quantity, dt1.CustomerID
					FROM (	SELECT OD.ProductID,OD.Quantity,O.CustomerID
							FROM dbo.[Order Details] OD JOIN dbo.Orders O ON OD.OrderID = O.OrderID
						 )dt1 LEFT JOIN dbo.Products P ON dt1.ProductID = p.ProductID
				 )dt2 LEFT JOIN dbo.Customers C ON dt2.CustomerID = C.CustomerID
			GROUP BY C.City,dt2.ProductName
           )
INSERT INTO @result
SELECT cte.city, cte.NumProductOrdered
FROM cte
WHERE cte.RNK IN (1,2,3,4,5) AND cte.ProductName = @Productname
SELECT *
FROM @result
END
DECLARE @show table (City varchar(20), NumProductOrdered int);
INSERT @show
EXEC sp_product_order_city_LIU [Alice Mutton]
SELECT*
FROM @show

GO


--4.Create 2 new tables “people_your_last_name” “city_your_last_name”. City table has two records: {Id:1, City: Seattle}, {Id:2, City: Green Bay}. 
--People has three records: {id:1, Name: Aaron Rodgers, City: 2}, {id:2, Name: Russell Wilson, City:1}, {Id: 3, Name: Jody Nelson, City:2}. Remove city of Seattle. 
--If there was anyone from Seattle, put them into a new city “Madison”. Create a view “Packers_your_name” lists all people from Green Bay. 
--If any error occurred, no changes should be made to DB. (after test) Drop both tables and view.
CREATE TABLE people_LIU(
PeopleId int Primary Key,
Name varchar(20) NOT NULL,
CityId int NOT NULL
)
INSERT people_LIU VALUES (1,'Aaron Rodgers', 2)
INSERT people_LIU VALUES (2,'Russell Wilson', 1)
INSERT people_LIU VALUES (3,'Russell Wilson', 1)

CREATE TABLE city_LIU(
CityId int Primary Key,
Name varchar(20) NOT NULL
)
INSERT city_LIU VALUES (1,'Seattle')
INSERT city_LIU VALUES (2,'Green Bay')

UPDATE city_LIU
SET Name = 'Madison'
WHERE CityId = 1

GO

CREATE VIEW Packers_RUIJIAN_LIU
AS
SELECT pL.PeopleId,pL.Name
FROM people_LIU pL LEFT JOIN  city_LIU cL ON pL.CityId = cL.CityId
WHERE cL.Name = 'Green Bay'

GO

SELECT *
FROM Packers_RUIJIAN_LIU

DROP TABLE city_LIU
DROP TABLE people_LIU
DROP VIEW Packers_RUIJIAN_LIU
GO
--5.Create a stored procedure “sp_birthday_employees_[you_last_name]” that creates a new table “birthday_employees_your_last_name” and fill it with all employees that have a birthday on Feb. 
--(Make a screen shot) drop the table. Employee table should not be affected.

CREATE PROC sp_birthday_employees_LIU
AS
BEGIN 
CREATE TABLE birthday_employees_LIU(
	EmployeeID int PRIMARY KEY,
	LastName varchar(20) NOT NULL,
	FirstName varchar(20) NOT NULL,
	Title varchar(40) NOT NULL,
	TitleOfCourtesy varchar(10),
	BirthDate datetime NOT NULL,
	HireDate datetime NOT NULL,
	Address varchar(40),
	City varchar (20),
	Region varchar(2),
	PostalCode int,
	Country varchar(10),
	HomePhone varchar(20),
	Extension int,
	Photo IMAGE,
	Note varchar(1000),
	[Reports To] int,
	PhotoPath varchar (100)
	)
INSERT INTO birthday_employees_LIU	
SELECT *
FROM dbo.Employees E
WHERE MONTH (E.BirthDate) = 2
SELECT *
FROM birthday_employees_LIU
END

DECLARE @show table (
	EmployeeID int PRIMARY KEY,
	LastName varchar(20) NOT NULL,
	FirstName varchar(20) NOT NULL,
	Title varchar(40) NOT NULL,
	TitleOfCourtesy varchar(10),
	BirthDate datetime NOT NULL,
	HireDate datetime NOT NULL,
	Address varchar(40),
	City varchar (20),
	Region varchar(2),
	PostalCode int,
	Country varchar(10),
	HomePhone varchar(20),
	Extension int,
	Photo IMAGE,
	Note varchar(1000),
	[Reports To] int,
	PhotoPath varchar (100)
	) ;
INSERT @show
EXEC sp_birthday_employees_LIU
SELECT*
FROM @show

select schema_name(schema_id) as schema_name,
       name as table_name,
       create_date,
       modify_date
from sys.tables
where create_date > DATEADD(DAY, -1, CURRENT_TIMESTAMP)
order by create_date desc;

DROP TABLE birthday_employees_LIU


--6.How do you make sure two tables have the same data?
--First check row number of this two table
--if the row number are not the same then the two tables do not have the same data
--if the row number are the same then select everything from two table and use union function union them together
--then check the row of the union result, if the row number is exactly the same as the original two table then the original two table have the same data, otherwise they don't.

