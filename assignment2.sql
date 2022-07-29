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
--I think this code is not correct, we should seprect products by product id and count the top 5 location. I will rewrite it and submit it later
SELECT TOP 5 O.ShipPostalCode, SUM(OD.Quantity) NumProductsSold
FROM dbo.Orders O JOIN dbo.[Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY O.ShipPostalCode
ORDER BY NumProductsSold DESC

--5. List all city names and number of customers in that city.
SELECT C.City, COUNT( C.CustomerID) NumOfCustomer
FROM dbo.Customers C
GROUP BY C.City
Order By NumOfCustomer DESC

--6. List city names which have more than 2 customers, and number of customers in that city
SELECT C.City, COUNT( C.CustomerID) NumOfCustomer
FROM dbo.Customers C
GROUP BY C.City
HAVING COUNT( C.CustomerID) >2
Order By NumOfCustomer DESC

--7.Display the names of all customers  along with the  count of products they bought
SELECT *
FROM dbo.Customers

SELECT O.OrderID SUM(O.Quantity) NumOfBought
FROM dbo.Orders O JOIN dbo.[Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY O.OrderID

SELECT *
FROM dbo.[Order Details]
--8.Display the customer ids who bought more than 100 Products with count of products.

--9. List all of the possible ways that suppliers can ship their products. Display the results as below
-- Supplier Company Name                Shipping Company Name

--10. Display the products order each day. Show Order date and Product Name.

--11. Displays pairs of employees who have the same job title.

--12. Display all the Managers who have more than 2 employees reporting to them.

--13. Display the customers and suppliers by city. The results should have the following columns

--City
--Name
--Contact Name,
--Type (Customer or Supplier)

use Northwind
GO
