use project
Select * from Orders
Create Procedure GetSalesReport
	@StartDate DATE,
	@EndDate DATE
AS BEGIN
	Select 
		OrderDate, TotalPrice,Commission
	from Orders
	Where OrderDate BETWEEN @StartDate AND @EndDate
	ORDER BY OrderDate
END;


Create Procedure MonthlySalesReport
	@Month INT,
	@Year INT
AS BEGIN 
	SELECT
		MONTH(OrderDate) as SalesMonth,YEAR(OrderDate) as SalesYear,SUM(TotalPrice)as TotalSales
	from Orders
	WHERE MONTH(OrderDate) = @Month AND YEAR(OrderDate) = @Year
	Group BY MONTH(OrderDate) , YEAR(OrderDate)
END

Create Procedure YearlySalesReport
	@Year INT
AS BEGIN
	Select YEAR(OrderDate) as SalesYear, SUM(TotalPrice) TotalSales
	from Orders
	Where YEAR(OrderDate) = @Year
	Group By YEAR(OrderDate)
END

Create Procedure MonthlyProfitReport
	@Month INT,
	@Year INT
AS BEGIN 
	SELECT
		MONTH(OrderDate) as SalesMonth,YEAR(OrderDate) as SalesYear,SUM(Commission)as TotalProfit
	from Orders
	WHERE MONTH(OrderDate) = @Month AND YEAR(OrderDate) = @Year
	Group BY MONTH(OrderDate) , YEAR(OrderDate)
END

Create Procedure YearlyProfitReport
	@Year INT
AS BEGIN
	Select YEAR(OrderDate) as SalesYear, SUM(Commission) TotalProfit
	from Orders
	Where YEAR(OrderDate) = @Year
	Group By YEAR(OrderDate)
END

EXEC MonthlySalesReport 02,2024

EXEC GetSalesReport '2023-04-22','2023-05-23'

EXEC YearlySalesReport 2023

EXEC MonthlyProfitReport 04,2023

EXEC YearlyProfitReport 2024

--REPORTS USING COMPLEX VIEWS
Create View YearlyProductSales AS
	Select p.ProductID,p.ProductName ,Year(o.OrderDate) as SalesYear, SUM(o.TotalPrice) As TotalSales
	from Products p
	Join OrderDetail ord on p.ProductID = ord.ProductID
	Join Orders o on ord.OrderID = o.OrderID
	Group by p.ProductID,p.ProductName, Year(o.OrderDate)


Create View MonthlyProductSalesReport AS
	Select p.ProductID,p.ProductName ,Month(o.OrderDate) as SalesMonth,Year(o.OrderDate) as SalesYear, SUM(o.TotalPrice) As TotalSales
	from Products p
	Join OrderDetail ord on p.ProductID = ord.ProductID
	Join Orders o on ord.OrderID = o.OrderID
	Group by p.ProductID,p.ProductName, Month(o.OrderDate),YEAR(o.OrderDate)

Create View MonthlyCategoriesSalesReport as
	Select c.CategoryID,c.CategoryName,MONTH(o.OrderDate) as SalesMonth,YEAR(o.OrderDate) as SalesYear,SUM(o.TotalPrice) as TotalSales
	from Orders o
	join OrderDetail ord on o.OrderID = ord.OrderID
	Join Products p on p.ProductID = ord.ProductID
	join Categories c on c.CategoryID = p.CategoryID
	Group By c.CategoryID,c.CategoryName,MONTH(o.OrderDate),YEAR(o.OrderDate)

--Execution of the Complex View Reports

Select CategoryName,SalesMonth,SalesYear,SUM(TotalSales) as TotalSales
from MonthlyCategoriesSalesReport
Where SalesMonth = 04 AND SalesYear = 2023
Group By CategoryName,SalesMonth,SalesYear,TotalSales

Select 
	ProductID,ProductName,SalesYear,TotalSales
from YearlyProductSales
Where  SalesYear=2023

select ProductID,ProductName,SalesMonth,SalesYear,TotalSales
from MonthlyProductSalesReport
where SalesMonth = 03 AND SalesYear = 2023
Group By ProductID,ProductName,SalesMonth,SalesYear,TotalSales
Having TotalSales > 5000

select ProductID,ProductName,SalesMonth,SalesYear,TotalSales
from MonthlyProductSalesReport
where SalesMonth = 03 AND SalesYear = 2023

--Materialized Views
Create View CustomerOrders As
	select c.CustomerID,c.CustomerName,o.OrderID,o.OrderDate,o.ShipDate,o.ShipAddress,o.ShipCity,o.TotalPrice,o.Commission,ord.OrderDetailID,
	ord.ProductID,ord.Quantity,ord.Price
	from Customers c
	join Orders o on c.CustomerID = o.CustomerID
	join OrderDetail ord on o.OrderID = ord.OrderID
	group by c.CustomerID,c.CustomerName,o.OrderID,o.OrderDate,o.ShipDate,o.ShipAddress,o.ShipCity,
	o.TotalPrice,o.Commission,ord.OrderDetailID,ord.ProductID,ord.Quantity,ord.Price

Select * from CustomerOrders

Select 
	CustomerID,COUNT(OrderID) as Total_Orders
from CustomerOrders
where CustomerID = 33
Group By CustomerID

Select 
	ShipAddress,COUNT(OrderID) as TotalOrdersDelivered
from CustomerOrders
Where ShipAddress = 'Johar Town' 
group by ShipAddress

Select 
	ShipAddress, SUM(Commission) as TotalCommission
from CustomerOrders
Where ShipAddress ='Allama Iqbal Town'
Group by ShipAddress