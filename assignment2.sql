use AdventureWorks2019
GO
--1. Write a query that lists the country and province names from person. CountryRegion and person. StateProvince tables. Join them and produce a result set similar to the following.
--  Country                        Province
SELECT PCR.Name Country,PSP.Name Province
FROM Person.CountryRegion PCR FULL JOIN Person.StateProvince PSP ON PCR.CountryRegionCode = PSP.CountryRegionCode

--2. Write a query that lists the country and province names from person. CountryRegion and person. StateProvince tables and list the countries filter them by Germany and Canada. Join them and produce a result set similar to the following.
--  Country                        Province
SELECT PCR.Name Country,PSP.Name Province
FROM Person.CountryRegion PCR FULL JOIN Person.StateProvince PSP ON PCR.CountryRegionCode = PSP.CountryRegionCode
WHERE PCR.NAME IN ('Germany','Canada')

use Northwind
GO
--3. List all Products that has been sold at least once in last 25 years.
SELECT *
FROM dbo.Products P
WHERE P.ProductID IN (
	SELECT OD.ProductID
	FROM dbo.Orders O JOIN dbo.[Order Details] OD ON O.OrderID = OD.OrderID
	WHERE O.OrderDate >= 1997-01-01
)
ORDER BY P.ProductID

--4. List top 5 locations (Zip Code) where the products sold most in last 25 years.
SELECT dt.ProductID, dt.NumProductsSold, dt.ShipPostalCode
FROM (SELECT OD.ProductID, O.ShipPostalCode, SUM(ISNULL(OD.Quantity,0)) NumProductsSold, RANK() OVER (PARTITION BY OD.ProductID ORDER BY SUM(OD.Quantity)DESC ) RNK
	  FROM dbo.Orders O JOIN dbo.[Order Details] OD ON O.OrderID = OD.OrderID
	  WHERE O.OrderDate >= 1997-01-01
      GROUP BY OD.ProductID, O.ShipPostalCode) dt
WHERE dt.RNK <= 5



--5. List all city names and number of customers in that city.
SELECT C.City, COUNT(C.CustomerID) NumOfCustomer
FROM dbo.Customers C
GROUP BY C.City
Order By NumOfCustomer DESC

--6. List city names which have more than 2 customers, and number of customers in that city
SELECT C.City, COUNT(C.CustomerID) NumOfCustomer
FROM dbo.Customers C
GROUP BY C.City
HAVING COUNT(C.CustomerID) >2
Order By NumOfCustomer DESC

--7.Display the names of all customers  along with the  count of products they bought
SELECT C.ContactName, dt.ProductID, dt.NumOfBoughtProduct
FROM (SELECT O.CustomerID, OD.ProductID, SUM(ISNULL(OD.Quantity,0)) NumOfBoughtProduct
	  FROM dbo.Orders O JOIN dbo.[Order Details] OD ON O.OrderID = OD.OrderID
	  GROUP BY OD.ProductID, O.CustomerID) dt left join dbo.Customers C ON dt.CustomerID = C.CustomerID
ORDER BY C.ContactName

--8.Display the customer ids who bought more than 100 Products with count of products.
SELECT C.CustomerID, dt.ProductID, dt.NumOfBoughtProduct
FROM (SELECT O.CustomerID, OD.ProductID, SUM(ISNULL(OD.Quantity,0)) NumOfBoughtProduct
	  FROM dbo.Orders O JOIN dbo.[Order Details] OD ON O.OrderID = OD.OrderID
	  GROUP BY OD.ProductID, O.CustomerID) dt left join dbo.Customers C ON dt.CustomerID = C.CustomerID
WHERE dt.NumOfBoughtProduct > 100
ORDER BY C.ContactName


--9. List all of the possible ways that suppliers can ship their products. Display the results as below
-- Supplier Company Name                Shipping Company Name
SELECT Su.CompanyName [Supplier Company Name], dt3.[Shipping Company Name]
From(	SELECT dt2.SupplierID, Sh.CompanyName [Shipping Company Name]
		FROM(	SELECT  P.SupplierID, dt.ShipVia
				FROM (	SELECT OD.ProductID, O.ShipVia
						FROM dbo.Orders O JOIN dbo.[Order Details] OD on O.OrderID = OD.OrderID
					 )dt LEFT JOIN dbo.Products P ON dt.ProductID = P.ProductID
			)dt2 LEFT JOIN dbo.Shippers Sh ON dt2.ShipVia = Sh.ShipperID
	)dt3 Left JOIN dbo.Suppliers Su ON dt3.SupplierID = Su.SupplierID

--10. Display the products order each day. Show Order date and Product Name.
SELECT dt.OrderDate, P.ProductName
FROM (	SELECT O.OrderDate, OD.ProductID
		FROM dbo.Orders O JOIN dbo.[Order Details] OD on O.OrderID = OD.OrderID
	 )dt LEFT JOIN dbo.Products P ON dt.ProductID = P.ProductID
ORDER BY dt.OrderDate

--11. Displays pairs of employees who have the same job title.
SELECT E.Title,E.FirstName,E.LastName
FROM dbo.Employees E JOIN	(	SELECT E.Title,COUNT(E.Title) NumSameTitle
							FROM dbo.Employees E
							GROUP BY E.Title
							HAVING COUNT(E.Title) >2
							)dt ON E.Title = dt.Title

--12. Display all the Managers who have more than 2 employees reporting to them.
SELECT dt.EmployeeID, dt.Manager
FROM(	SELECT M.EmployeeID, M.FirstName + '' + M.LastName AS Manager, COUNT (M.EmployeeID) Count
		FROM dbo.Employees E JOIN dbo.Employees M ON E.ReportsTo = M.EmployeeID
		GROUP BY M.EmployeeID,(M.FirstName + '' + M.LastName)
	)dt

--13. Display the customers and suppliers by city. The results should have the following columns
--City
--Name
--Contact Name,
--Type (Customer or Supplier)
SELECT CITY City, CompanyName Name, ContactName [Contact Name],'Customer' As Type
FROM dbo.Customers
UNION
SELECT CITY City, CompanyName Name, ContactName [Contact Name],'Supplier' As Type
FROM dbo.Suppliers

--14. List all cities that have both Employees and Customers.
WITH cte AS(
	SELECT CT2.City, ROW_NUMBER() OVER(PARTITION BY CT2.City ORDER BY CT2.City) row_num
	FROM	(	SELECT CT.City
				FROM(	SELECT CITY City, CompanyName Name, ContactName [Contact Name],'Customer' As Type
				FROM dbo.Customers
				UNION
				SELECT CITY City, CompanyName Name, ContactName [Contact Name],'Supplier' As Type
				FROM dbo.Suppliers) CT
				WHERE CT.Type  = 'Customer'
			)CT2
		JOIN
			(	SELECT ST.City
				FROM(	SELECT CITY City, CompanyName Name, ContactName [Contact Name],'Customer' As Type
				FROM dbo.Customers
				UNION
				SELECT CITY City, CompanyName Name, ContactName [Contact Name],'Supplier' As Type
				FROM dbo.Suppliers) ST
				WHERE ST.Type  = 'Supplier'
			)ST2
		ON CT2.City = ST2.City
			)
SELECT cte.City
FROM cte
WHERE cte.row_num = 1

--15.List all cities that have Customers but no Employee.
--a. Use sub-query
SELECT CT.City
FROM(	SELECT CITY City, 'Customer' As Type
		FROM dbo.Customers
		UNION
		SELECT CITY City,'Employee' As Type
		FROM dbo.Employees) CT
WHERE CT.Type  = 'Customer' AND CT.Type != 'Employee'

--b. Do not use sub-query
WITH CustomerEmployeecte AS(
SELECT CITY City, 'Customer' As Type
FROM dbo.Customers
UNION ALL
SELECT CITY City, 'Employee' As Type
FROM dbo.Employees
)
SELECT City
FROM CustomerEmployeecte
WHERE Type  = 'Customer' AND Type != 'Employee'

--16. List all products and their total order quantities throughout all orders.
SELECT OD.ProductID, P.ProductName, SUM(ISNULL(OD.Quantity,0)) NumOrdered
FROM dbo.[Order Details] OD JOIN dbo.Products P on OD.ProductID = P.ProductID
GROUP BY OD.ProductID, P.ProductName
ORDER BY OD.ProductID

--17. List all Customer Cities that have at least two customers.
--a. Use union

WITH Ccte AS(
SELECT C.City, ROW_NUMBER() OVER(PARTITION BY C.City ORDER BY C.City) NumRow
FROM dbo.Customers C)
SELECT Ccte.city
FROM Ccte
WHERE Ccte.NumRow>1
UNION
SELECT Ccte.city
FROM Ccte
WHERE Ccte.NumRow>1

--b. Use no union
SELECT C.City, COUNT(C.CustomerID) NumCustomerInCity
FROM dbo.Customers C
GROUP BY C.City
HAVING COUNT(C.CustomerID) >=2

--18. List all Customer Cities that have ordered at least two different kinds of products.
SELECT dt2.City, COUNT(P.CategoryID) NumKindProduct
FROM(	SELECT c.City, dt.ProductID
		FROM(	SELECT O.CustomerID, OD.ProductID
				FROM dbo.[Order Details] OD JOIN dbo.Orders O ON OD.OrderID = O.OrderID
			)dt LEFT JOIN dbo.Customers C ON dt.CustomerID = c.CustomerID
	)dt2 LEFT JOIN dbo.Products P on dt2.ProductID = P.ProductID
GROUP BY dt2.City
HAVING COUNT(P.CategoryID) >= 2
ORDER BY dt2.City

--19. List 5 most popular products, their average price, and the customer city that ordered most quantity of it.
WITH cte AS(
		SELECT TOP 5 OD.ProductID, SUM(OD.Quantity) NumOrdered, AVG(OD.UnitPrice) AvgPrice
		FROM dbo.[Order Details] OD 
		GROUP BY OD.ProductID
		ORDER BY NumOrdered DESC)
WITH cte2 AS(
SELECT dt.ProductID,C.City,COUNT(dt.ProductID) NumOrderedByCity
FROM(	SELECT O.CustomerID,OD.ProductID
		FROM dbo.[Order Details] OD JOIN dbo.Orders O ON OD.OrderID = O.OrderID
	)dt JOIN dbo.Customers C ON dt.CustomerID = C.CustomerID
GROUP BY C.City, dt.ProductID
ORDER BY dt.ProductID, NumOrderedByCity DESC)

SELECT
FROM 


--20. List one city, if exists, that is the city from where the employee sold most orders (not the product quantity) is, and also the city of most total quantity of products ordered from. (tip: join  sub-query)


--21. How do you remove the duplicates record of a table?
--suppose we have a Table with n column, column names are COLUMN1 to COLUMNn. Use method below to remove the duplicates record of the table 
WITH cte AS (
	SELECT COLUMN1, COLUMN2, ...,COLUMNn ,ROW_NUMBER() OVER(PARTITION BY COLUMN1,...COLUMNn ORDER BY COLUMN1,...,COLUMNn) NumRows
	FROM Table
)
SELECT *
FROM cte
WHERE cte.NumRows = 1


