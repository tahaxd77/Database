use project
create table Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName NVARCHAR(255) NOT NULL,
    ContactNumber NVARCHAR(20) NOT NULL,
    Address NVARCHAR(255) ,
    City NVARCHAR(100)
);
create table Orders (
    OrderID INT PRIMARY KEY,
    OrderDate DATETIME NOT NULL,
    ShipDate DATETIME NOT NULL,
    ShipAddress NVARCHAR(255) NOT NULL,
    ShipCity NVARCHAR(255),
    TotalPrice DECIMAL(10, 2) NOT NULL,
    Commission DECIMAL(10, 2) NOT NULL,
    CustomerID INT NOT NULL,
    CarriageID INT NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE,
    FOREIGN KEY (CarriageID) REFERENCES Carriage(CarriageID) ON DELETE CASCADE
);
create trigger trgUpdateOrderTotal
ON OrderDetail
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Calculate the total price for each affected order
    UPDATE Orders
    SET TotalPrice = (
        SELECT SUM(Price)
        FROM OrderDetail
        WHERE OrderID = Orders.OrderID
    )
    WHERE OrderID = Orders.OrderID;

    -- Update the commission (assuming a commission rate of 10%)
    UPDATE Orders
    SET Commission = TotalPrice * 0.10
    WHERE OrderID =Orders.OrderID;
END;

create table VehicleCharges (
    VehicleType NVARCHAR(50) PRIMARY KEY,
    Charges DECIMAL(10,2) NOT NULL
);

create table Carriage (
    CarriageID INT PRIMARY KEY,
    CarriageResourcePerson NVARCHAR(255) NOT NULL,
    VehicleType NVARCHAR(50) NOT NULL,
    FOREIGN KEY (VehicleType) REFERENCES VehicleCharges(VehicleType) ON DELETE CASCADE
);
create table OrderDetail (
    OrderDetailID INT PRIMARY KEY,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    OrderID INT NOT NULL,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE
);
create table Categories (
    CategoryID INT PRIMARY KEY,
    CategoryName NVARCHAR(255)
);
create table Products (
    ProductID INT PRIMARY KEY,
    ProductName NVARCHAR(255),
    UnitPrice DECIMAL(10, 2),
    UnitsInStock INT,
    CategoryID INT,
	FOREIGN KEY (CategoryID) references Categories(CategoryID) ON DELETE CASCADE  
);
CREATE TABLE ProductPurchase
(
	PurchaseID INT IDENTITY(1,1) PRIMARY KEY,
	ProductID INT,
	PurchaseDate DATETIME,
	Quantity INT,
	TotalPrice Decimal(10,2),
	Foreign Key (ProductID) references Products(ProductID)
);

Create Procedure InsertProductPurchase
	@ProductID INT,
	@PurchaseDate Datetime,
	@Quantity Int
AS 
begin
Declare @UnitPrice Decimal(10,2)
Declare @TotalPrice Decimal(10,2)
(Select @UnitPrice=UnitPrice from Products Where ProductID = @ProductID)
Set @TotalPrice = @UnitPrice * @Quantity

	Insert into ProductPurchase values(@ProductID,@PurchaseDate,@Quantity,@TotalPrice)
END;


Create table ProductsAudit(
AuditID INT Identity(1,1) Primary Key,
ProductID Int,
ProductName NVARCHAR (255),
UnitPrice Decimal(10,2),
UnitsInStock Int,
CategoryID Int,
OperationType Varchar(50),
TimeStamp DATETIME
)

Create Trigger TrgProductUpdateAudit
ON Products 
After update 
AS
BEGIN
	INSERT INTO ProductsAudit (
        ProductID,
		ProductName,
		UnitPrice,
		UnitsInStock,
		CategoryID,
        OperationType,
        Timestamp
    ) 
	SELECT
		o.ProductID,
		o.ProductName,o.UnitPrice,o.UnitsInStock,o.CategoryID,
		'Updated',
		GETDATE()
	from deleted o
END;
Create Trigger TrgProductDeleteAudit
ON Products 
After Delete 
AS
BEGIN
	INSERT INTO ProductsAudit (
        ProductID,
		ProductName,
		UnitPrice,
		UnitsInStock,
		CategoryID,
        OperationType,
        Timestamp
    ) 
	SELECT
		o.ProductID,
		o.ProductName,o.UnitPrice,o.UnitsInStock,o.CategoryID,
		'Deleted',
		GETDATE()
	from deleted o
END;
Create table OrdersAudit 
(
	AuditID INT IDENTITY(1,1) PRIMARY KEY,
	OrderID INT,
	OrderDate DATETIME,
	ShipDate DATETIME,
	ShipAddress NVARCHAR(255),
	ShipCity NVARCHAR(255),
	TotalPrice DECIMAL(10,2),
	Commission DECIMAL(10,2),
	CustomerID INT,
	CarriageID INT,
	OperationType VARCHAR(50),
	Timestamp DATETIME
);

	
Create Trigger TrgOrderUpdateAudit
ON Orders 
After Update 
AS
BEGIN
	INSERT INTO OrdersAudit (
        OrderID,
        OrderDate,
        ShipDate,
        ShipAddress,
        ShipCity,
        TotalPrice,
        Commission,
        CustomerID,
        CarriageID,
        OperationType,
        Timestamp
    ) 
	SELECT
		o.OrderID,
		o.OrderDate,
		o.ShipDate,
		o.ShipAddress,
		o.ShipCity,
		o.TotalPrice,
		o.Commission,
		o.CustomerID,
		o.CarriageID,
		'Updated',
		GETDATE()
	from deleted o
END;

Create Trigger TrgOrderDeleteAudit
ON Orders 
after Delete 
AS
BEGIN
	INSERT INTO OrdersAudit (
        OrderID,
        OrderDate,
        ShipDate,
        ShipAddress,
        ShipCity,
        TotalPrice,
        Commission,
        CustomerID,
        CarriageID,
        OperationType,
        Timestamp
    ) 
	SELECT
		o.OrderID,
		o.OrderDate,
		o.ShipDate,
		o.ShipAddress,
		o.ShipCity,
		o.TotalPrice,
		o.Commission,
		o.CustomerID,
		o.CarriageID,
		'Deleted',
		GETDATE()
	from deleted o
END;

CREATE TABLE OrderDetailAudit
(
	AuditID INT IDENTITY(1,1) PRIMARY KEY,
	OrderDetailID INT,
	ProductID INT,
	Quantity INT,
	Price DECIMAL(10,2),
	OrderID INT,
	OperationType VARCHAR(50),
	Timestamp DATETIME DEFAULT GETDATE()
)
CREATE TRIGGER TrgOrderDetailUpdateAudit
On OrderDetail
AFTER UPDATE
AS BEGIN 
INSERT INTO OrderDetailAudit(OrderDetailID,ProductID,Quantity,Price,OrderID,OperationType,Timestamp)
Select
	d.OrderDetailID,
	d.ProductID,
	d.Quantity,
	d.Price,
	d.OrderID,
	'Updated',
	GETDATE()
from deleted d
END;
CREATE TRIGGER TrgOrderDetailDeleteAudit
On OrderDetail
AFTER DELETE
AS BEGIN 
INSERT INTO OrderDetailAudit(OrderDetailID,ProductID,Quantity,Price,OrderID,OperationType,Timestamp)
Select
	d.OrderDetailID,
	d.ProductID,
	d.Quantity,
	d.Price,
	d.OrderID,
	'Deleted',
	GETDATE()
from deleted d
END;
--Stored Procedures to Insert in Customers
CREATE PROCEDURE InsertCustomer
    @CustomerID INT,
    @CustomerName NVARCHAR(255),
    @ContactNumber NVARCHAR(20),
    @Address NVARCHAR(255),
    @City NVARCHAR(100)
AS
BEGIN
    INSERT INTO Customers (CustomerID, CustomerName, ContactNumber, Address, City)
    VALUES (@CustomerID, @CustomerName, @ContactNumber, @Address, @City);
END;

--Stored Procedure to Insert in Categories
CREATE PROCEDURE InsertCategory
    @CategoryID INT,
    @CategoryName NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    -- Insert the record into the Categories table
    INSERT INTO Categories (CategoryID, CategoryName)
    VALUES (@CategoryID, @CategoryName);
END;


--Stored Procedure to Insert in Products
CREATE PROCEDURE InsertProduct
    @ProductID INT,
    @ProductName NVARCHAR(255),
    @UnitPrice DECIMAL(10, 2),
    @UnitsInStock INT,
    @CategoryID INT
AS
BEGIN
    INSERT INTO Products (ProductID, ProductName, UnitPrice, UnitsInStock, CategoryID)
    VALUES (@ProductID, @ProductName, @UnitPrice, @UnitsInStock, @CategoryID);
END;
--Stored Procedures to Insert in Order
CREATE PROCEDURE InsertOrder
    @OrderID INT,
    @OrderDate DATETIME,
    @ShipDate DATETIME,
    @ShipAddress NVARCHAR(255),
    @ShipCity NVARCHAR(255),
    @CustomerID INT,
    @CarriageID INT
AS
BEGIN
	DECLARE @TotalPrice DECIMAL(10, 2);
	DECLARE @Commission DECIMAL(10, 2);

	SET @TotalPrice= (SELECT SUM(Price) from OrderDetail where
	OrderID = @OrderID)
	SET @Commission = (@TotalPrice *0.15);
    INSERT INTO Orders (OrderID, OrderDate, ShipDate, ShipAddress, ShipCity, TotalPrice, Commission, CustomerID, CarriageID)
    VALUES (@OrderID, @OrderDate, @ShipDate, @ShipAddress, @ShipCity, @TotalPrice, @Commission, @CustomerID, @CarriageID);
END;

--Store Procedure to InsertOrderDetail:
CREATE PROCEDURE InsertOrderDetail
    @OrderDetailID INT,
    @ProductID INT,
    @Quantity INT,
	@OrderID INT
AS
BEGIN
    declare @UnitPrice DECIMAL(10, 2);
    declare @Price DECIMAL(10, 2);
    SELECT @UnitPrice = UnitPrice
    from Products
    where ProductID = @ProductID;
    SET @Price = @UnitPrice * @Quantity;
    INSERT INTO OrderDetail (OrderDetailID, ProductID, Quantity, Price, OrderID)
    values (@OrderDetailID, @ProductID, @Quantity, @Price, @OrderID);
END;

--Stored Procedures to Insert in Carriage
CREATE PROCEDURE InsertCarriage
    @CarriageID INT,
    @CarriageResourcePerson NVARCHAR(255),
    @VehicleType NVARCHAR(50)
AS
BEGIN
    INSERT INTO Carriage (CarriageID, CarriageResourcePerson, VehicleType)
    VALUES (@CarriageID, @CarriageResourcePerson, @VehicleType);
END;

--Stored Procedures to Insert in VehicleCharges
CREATE PROCEDURE InsertVehicleCharge
    @VehicleType NVARCHAR(50),
    @Charges DECIMAL(10, 2)
AS
BEGIN
    INSERT INTO VehicleCharges (VehicleType, Charges)
    VALUES (@VehicleType, @Charges);
END;



-- Update procedure for Customer table
create procedure UpdateCustomer
    @CustomerId INT,
    @CustomerName VARCHAR(70),
    @ContactNumber VARCHAR(11),
    @Address VARCHAR(100),
    @City VARCHAR(50)
AS
BEGIN
    update Customers 
    SET CustomerName = @CustomerName,
        ContactNumber = @ContactNumber,
        [Address] = @Address,
        City = @City
    where CustomerID = @CustomerId;
END;

-- Update procedure for Vehicle table
create procedure UpdateVehicle
    @VehicleType VARCHAR(50),
    @CarriageFees DECIMAL(10, 3)
AS
BEGIN
    update VehicleCharges 
    SET Charges = @CarriageFees
    where VehicleType = @VehicleType;
END;

-- Update procedure for Categories table
create procedure UpdateCategory
    @CategoryId INT,
    @CategoryName VARCHAR(40)
AS
BEGIN
    update Categories 
    SET CategoryName = @CategoryName
    where CategoryId = @CategoryId;
END;

-- Update procedure for Product table
create procedure UpdateProduct
    @ProductId INT,
    @ProductName VARCHAR(200),
    @QuantityInStock INT,
    @UnitPrice DECIMAL(8, 4),
    @CategoryId INT
AS
BEGIN
    update Products 
    SET ProductName = @ProductName,
        UnitsInStock = @QuantityInStock,
        UnitPrice = @UnitPrice,
        CategoryId = @CategoryId
    where ProductID = @ProductId;
END;

-- Update procedure for Order table
create procedure UpdateOrder
    @OrderId INT,
    @OrderDate DATE,
    @ShippedDate DATE,
    @ShipAddress VARCHAR(100),
    @ShipCity VARCHAR(50),
    @TotalPrice DECIMAL(10, 2),
    @Commission DECIMAL(10, 2),
    @CustomerId INT,
    @CarriageId INT
AS
BEGIN
    update Orders 
    SET OrderDate = @OrderDate,
        ShipDate = @ShippedDate,
        ShipAddress = @ShipAddress,
        ShipCity = @ShipCity,
        TotalPrice = @TotalPrice,
        Commission = @Commission,
        CustomerId = @CustomerId,
        CarriageId = @CarriageId
    WHERE OrderId = @OrderId;
END;

-- Update procedure for Carriage table
create procedure UpdateCarriage
    @CarriageId INT,
    @CarriagePersonName VARCHAR(70),
    @VehicleType VARCHAR(50)
AS
BEGIN
    update Carriage 
    SET CarriageResourcePerson = @CarriagePersonName,
        VehicleType = @VehicleType
    where CarriageID = @CarriageId;
END;


-- Deletion procedure for Customer table
create procedure DeleteCustomer
    @CustomerId INT
AS
BEGIN
    DELETE FROM Customers WHERE CustomerID = @CustomerId;
END;

-- Deletion procedure for Vehicle table
create procedure DeleteVehicle
    @VehicleType VARCHAR(50)
AS
BEGIN
    DELETE FROM VehicleCharges WHERE VehicleType = @VehicleType;
END;

-- Deletion procedure for Categories table
create procedure DeleteCategory
    @CategoryId INT
AS
BEGIN
    DELETE FROM Categories WHERE CategoryId = @CategoryId;
END;

-- Deletion procedure for Product table
create procedure DeleteProduct
    @ProductId INT
AS
BEGIN
    DELETE FROM Products WHERE ProductID = @ProductId;
END;

-- Deletion procedure for Order table
create procedure DeleteOrder
    @OrderId INT
AS
BEGIN
    DELETE FROM Orders WHERE OrderID = @OrderId;
END;

-- Deletion procedure for Order details
create procedure DeleteOrderDetails
    @OrderDetailID INT
AS
BEGIN
    DELETE FROM OrderDetail WHERE OrderDetailID = @OrderDetailID;
END;

-- Deletion procedure for Carriage table
create procedure DeleteCarriage
    @CarriageId INT
AS
BEGIN
    DELETE FROM Carriage WHERE CarriageId = @CarriageId;
END;

--Insertion of Categories:
EXEC InsertCategory 1, 'Concrete Slab';
EXEC InsertCategory 2, 'Concrete Girder';
EXEC InsertCategory 3, 'Boundary Wall Column';
EXEC InsertCategory 4, 'Boundary Wall';

--Insertion in Products table
EXEC InsertProduct 1, '2ft-6in x 1ft-6in', 500, 53, 1;
EXEC InsertProduct 2, '3ft-0in x 1ft-5in', 585, 67, 1;
EXEC InsertProduct 3, '3ft-5in x 1ft-6in', 660, 66, 1;
EXEC InsertProduct 4, '3ft-6in x 1ft-6in', 675, 17, 1;
EXEC InsertProduct 5, '4ft-0in x 1ft-6in', 820, 74, 1;
EXEC InsertProduct 6, '4ft-6in x 1ft-6in', 835, 46, 1;
EXEC InsertProduct 7, '4ft-6in x 1ft-6in', 1025, 90, 1;
EXEC InsertProduct 8, '4ft-0in x 1ft-6in', 1040, 51, 1;
EXEC InsertProduct 9, '5ft-0in x 1ft-6in', 1205, 69, 1;
EXEC InsertProduct 10, '5ft-6in x 1ft-6in', 1350, 18, 1;
EXEC InsertProduct 11, '6ft-0in x 1ft-6in', 1720, 18, 1;
EXEC InsertProduct 12, '6ft-6in x 1ft-6in', 1900, 81, 1;
EXEC InsertProduct 13, '7ft-0in x 1ft-6in', 2230, 23, 1;
EXEC InsertProduct 14, '3ft-0in x 1ft-0in', 410, 49, 1;
EXEC InsertProduct 15, '3ft-6in x 1ft-0in', 505, 13, 1;
EXEC InsertProduct 16, '3ft-7in x 1ft-0in', 520, 68, 1;
EXEC InsertProduct 17, '4ft-0in x 1ft-0in', 575, 19, 1;
EXEC InsertProduct 18, '4ft-1in x 1ft-0in', 590, 18, 1;
EXEC InsertProduct 19, '4ft-6in x 1ft-0in', 635, 42, 1;
EXEC InsertProduct 20, '4ft-7in x 1ft-Oin', 645, 40, 1;
EXEC InsertProduct 21, '5ft-0in x 1ft-0in', 815, 88, 1;
EXEC InsertProduct 22, '5ft-6in x 1ft-0in', 910, 54, 1;
EXEC InsertProduct 23, '6ft-0in x 1ft-0in', 1175, 68, 1;
EXEC InsertProduct 24, '6ft-6in x 1ft-0in', 1255, 56, 1;
EXEC InsertProduct 25, '4in x 10in', 630, 17, 2;
EXEC InsertProduct 26, '5in x 12in OLD', 780, 94, 2;
EXEC InsertProduct 27, '5in x 13in', 810, 14, 2;
EXEC InsertProduct 28, '5in x 14in OLD', 1065, 15, 2;
EXEC InsertProduct 29, '6in x 15in OLD', 1245, 37, 2;
EXEC InsertProduct 30, '7in x 18in', 1665, 36, 2;
EXEC InsertProduct 31, '7in x 21in', 1830, 66, 2;
EXEC InsertProduct 32, '8in x 19 퐄n', 1835, 29, 2;
EXEC InsertProduct 33, '9in x 19in', 2040, 46, 2;
EXEC InsertProduct 34, '9in x 20in(1)', 2345, 46, 2;
EXEC InsertProduct 35, '9in x 20in (II)', 2245, 100, 2;
EXEC InsertProduct 36, '9in x 20in A+', 2295, 33, 2;
EXEC InsertProduct 37, '8in x 24in', 2390, 59, 2;
EXEC InsertProduct 38, '8in x 27in', 2775, 44, 2;
EXEC InsertProduct 39, '8in x 30in', 3055, 43, 2;
EXEC InsertProduct 40, '9in x 30in', 3375, 78, 2;
EXEC InsertProduct 41, '9in x 32in', 3915, 44, 2;
EXEC InsertProduct 42, '10in x 32in', 4340, 92, 2;
EXEC InsertProduct 43, '12in x 36in', 5520, 89, 2;
EXEC InsertProduct 44, 'Column 6in x 6퐄n upto 10 ft', 395, 36, 3;
EXEC InsertProduct 45, 'Column 6in x 6퐄n 10ft-1in to 11 ft', 425, 51, 3;
EXEC InsertProduct 46, 'Column 6in x 6퐄n 11ft-1in to 12 ft', 435, 63, 3;
EXEC InsertProduct 47, 'Column 6in x 6퐄n 12ft-1in to 13 ft', 520, 59, 3;
EXEC InsertProduct 48, 'Column 6in x 6퐄n 13ft-1in to 14 ft', 540, 80, 3;
EXEC InsertProduct 49, 'Planks 2in x12in x 8ft- 0in', 240, 293, 4;
EXEC InsertProduct 50, 'Planks 2in x 8in x 8ft- 0in', 160, 143, 4;
EXEC InsertProduct 51, 'Color Strip 2in x 3in x 8ft- 0in', 250, 306, 4;
EXEC InsertProduct 52, 'Color Strip 2in x 5in x 8ft- 0in', 325, 381, 4;
EXEC InsertProduct 53, 'Boundary Wall Cap 9in x 9in', 245, 93, 4;
EXEC InsertProduct 54, 'Boundary Wall Cap 72in x12in', 310, 424, 4;
EXEC InsertProduct 55, 'Boundary Wal Cap 17in x 18in', 470, 77, 4;

--Insertion in Customer table:
EXEC InsertCustomer 1, 'Muhammad Nawaz','03421009941', 'Ghulshan-e-Ravi','Lahore';
EXEC InsertCustomer 2, 'Naveed Iqbal','03189742770', 'Ghulshan-e-Ravi','Lahore';
EXEC InsertCustomer 3, 'Ali Mehmood','03747457549', 'Samanabad','Lahore';
EXEC InsertCustomer 4, 'Aisha Zahid','03177444385', 'Sabzazar','Lahore';
EXEC InsertCustomer 5, 'Usman Abbas','03508831185', 'Johar Town','Lahore';
EXEC InsertCustomer 6, 'Sana Yousaf','03699174866', 'Garden Town','Lahore';
EXEC InsertCustomer 7, 'Bilal Malik','03738019394', 'DHA','Lahore';
EXEC InsertCustomer 8, 'Farhan Yousaf','03613001134', 'Sabzazar','Lahore';
EXEC InsertCustomer 9, 'Hira Abbas','03179350406', 'Gulshan-e-Lahore','Lahore';
EXEC InsertCustomer 10, 'Naveed Hussain','03932929896', 'Wapda Town','Lahore';
EXEC InsertCustomer 11, 'Hira Hussain','03827244309', 'Raiwind Road','Lahore';
EXEC InsertCustomer 12, 'Sara Nawaz','03757561438', 'DHA','Lahore';
EXEC InsertCustomer 13, 'Hira Rashid','03444623036', 'Shahdara','Lahore';
EXEC InsertCustomer 14, 'Amna Aslam','03333361390', 'DHA','Lahore';
EXEC InsertCustomer 15, 'Aisha Zahid','03846453190', 'Model Town','Lahore';
EXEC InsertCustomer 16, 'Hassan Hussain','03253156386', 'Gulshan-e-Lahore','Lahore';
EXEC InsertCustomer 17, 'Ahmed Iqbal','03376530110', 'Township','Lahore';
EXEC InsertCustomer 18, 'Usman Farooq','03653998931', 'Samanabad','Lahore';
EXEC InsertCustomer 19, 'Sana Hassan','03453718270', 'DHA','Lahore';
EXEC InsertCustomer 20, 'Asad Khan','03299570807', 'Shadman','Lahore';
EXEC InsertCustomer 21, 'Zainab Zahid','03177933987', 'Allama Iqbal Town','Lahore';
EXEC InsertCustomer 22, 'Sara Rashid','03397890780', 'Gulberg','Lahore';
EXEC InsertCustomer 23, 'Ali Aslam','03391173030', 'DHA','Lahore';
EXEC InsertCustomer 24, 'Hira Iqbal','03751654157', 'Shahdara','Lahore';
EXEC InsertCustomer 25, 'Fatima Zahid','03676920418', 'Raiwind Road','Lahore';
EXEC InsertCustomer 26, 'Hira Aslam','03215412954', 'Iqbal Town','Lahore';
EXEC InsertCustomer 27, 'Sana Hassan','03702718868', 'Wapda Town','Lahore';
EXEC InsertCustomer 28, 'Sadia Akhtar','03342764584', 'Sabzazar','Lahore';
EXEC InsertCustomer 29, 'Hassan Ali','03458916413', 'Township','Lahore';
EXEC InsertCustomer 30, 'Amna Rashid','03984109319', 'Gulberg','Lahore';
EXEC InsertCustomer 31, 'Sara Malik','03174560862', 'Gulberg','Lahore';
EXEC InsertCustomer 32, 'Asad Nawaz','03274734213', 'Samanabad','Lahore';
EXEC InsertCustomer 33, 'Ahmed Mehmood','03314581102', 'Ghulshan-e-Ravi','Lahore';
EXEC InsertCustomer 34, 'Zainab Khan','03243736705', 'Garden Town','Lahore';
EXEC InsertCustomer 35, 'Sara Farooq','03282326561', 'Cantt','Lahore';
EXEC InsertCustomer 36, 'Sara Hussain','03197448523', 'Raiwind Road','Lahore';
EXEC InsertCustomer 37, 'Zainab Iqbal','03443862040', 'Wapda Town','Lahore';
EXEC InsertCustomer 38, 'Sana Iqbal','03483323826', 'Township','Lahore';
EXEC InsertCustomer 39, 'Amna Farooq','03992584473', 'Garden Town','Lahore';
EXEC InsertCustomer 40, 'Zainab Zahid','03255458228', 'Garden Town','Lahore';
EXEC InsertCustomer 41, 'Usman Zahid','03226685683', 'Iqbal Town','Lahore';
EXEC InsertCustomer 42, 'Hira Hassan','03334114316', 'Samanabad','Lahore';
EXEC InsertCustomer 43, 'Saima Mehmood','03712808726', 'Garden Town','Lahore';
EXEC InsertCustomer 44, 'Fatima Malik','03259356224', 'Iqbal Town','Lahore';
EXEC InsertCustomer 45, 'Tariq Hassan','03779771428', 'Johar Town','Lahore';
EXEC InsertCustomer 46, 'Naveed Rehman','03278560976', 'Gulberg','Lahore';
EXEC InsertCustomer 47, 'Zainab Abbas','03163629998', 'Raiwind Road','Lahore';
EXEC InsertCustomer 48, 'Ahmed Malik','03851485329', 'Sabzazar','Lahore';
EXEC InsertCustomer 49, 'Zainab Hassan','03496850003', 'Model Town','Lahore';
EXEC InsertCustomer 50, 'Muhammad Farooq','03487847839', 'Liaqatabad','Lahore';
EXEC InsertCustomer 51, 'Zainab Ali','03574966697', 'Cantt','Lahore';
EXEC InsertCustomer 52, 'Muhammad Mehmood','03416959379', 'Model Town','Lahore';
EXEC InsertCustomer 53, 'Usman Ahmed','03158623268', 'Iqbal Town','Lahore';
EXEC InsertCustomer 54, 'Ali Nasir','03988214451', 'Defence','Lahore';
EXEC InsertCustomer 55, 'Muhammad Iqbal','03496379158', 'Johar Town','Lahore';
EXEC InsertCustomer 56, 'Asad Nasir','03912321266', 'Garden Town','Lahore';
EXEC InsertCustomer 57, 'Bilal Khan','03224200325', 'Garden Town','Lahore';
EXEC InsertCustomer 58, 'Aisha Yousaf','03559278785', 'Gulberg','Lahore';
EXEC InsertCustomer 59, 'Ahmed Raza','03931006509', 'Cantt','Lahore';
EXEC InsertCustomer 60, 'Zainab Aslam','03858648664', 'Wapda Town','Lahore';
EXEC InsertCustomer 61, 'Sara Hussain','03992749447', 'Liaqatabad','Lahore';
EXEC InsertCustomer 62, 'Hira Yousaf','03615999129', 'Wapda Town','Lahore';
EXEC InsertCustomer 63, 'Hassan Nawaz','03576610771', 'DHA','Lahore';
EXEC InsertCustomer 64, 'Ali Rashid','03781472113', 'Garden Town','Lahore';
EXEC InsertCustomer 65, 'Hira Farooq','03786255383', 'Defence','Lahore';
EXEC InsertCustomer 66, 'Hira Imran','03503978989', 'Township','Lahore';
EXEC InsertCustomer 67, 'Aisha Raza','03312237922', 'Gulshan-e-Lahore','Lahore';
EXEC InsertCustomer 68, 'Naveed Malik','03869542645', 'Township','Lahore';
EXEC InsertCustomer 69, 'Ali Hassan','03771424288', 'Iqbal Town','Lahore';
EXEC InsertCustomer 70, 'Hassan Aslam','03853984348', 'Ghulshan-e-Ravi','Lahore';
EXEC InsertCustomer 71, 'Saima Mehmood','03225081290', 'DHA','Lahore';
EXEC InsertCustomer 72, 'Bilal Akhtar','03868309320', 'Allama Iqbal Town','Lahore';
EXEC InsertCustomer 73, 'Farhan Malik','03978121911', 'Iqbal Town','Lahore';
EXEC InsertCustomer 74, 'Muhammad Mehmood','03738340557', 'Cantt','Lahore';
EXEC InsertCustomer 75, 'Amna Zahid','03617825862', 'Gulberg','Lahore';
EXEC InsertCustomer 76, 'Sana Hussain','03511345228', 'Gulberg','Lahore';
EXEC InsertCustomer 77, 'Saima Hussain','03538356467', 'Defence','Lahore';
EXEC InsertCustomer 78, 'Sara Khan','03915036234', 'Samanabad','Lahore';
EXEC InsertCustomer 79, 'Bilal Rashid','03578760202', 'Model Town','Lahore';
EXEC InsertCustomer 80, 'Bilal Imran','03928925231', 'Gulshan-e-Lahore','Lahore';
EXEC InsertCustomer 81, 'Aisha Aslam','03773795074', 'Faisal Town','Lahore';
EXEC InsertCustomer 82, 'Naveed Imran','03769823498', 'Gulberg','Lahore';
EXEC InsertCustomer 83, 'Sadia Mehmood','03664330147', 'Shahdara','Lahore';
EXEC InsertCustomer 84, 'Fatima Nasir','03611256406', 'Shahdara','Lahore';
EXEC InsertCustomer 85, 'Farhan Nawaz','03874831883', 'Liaqatabad','Lahore';
EXEC InsertCustomer 86, 'Tariq Rashid','03403472882', 'Model Town','Lahore';
EXEC InsertCustomer 87, 'Usman Rashid','03342117803', 'Sabzazar','Lahore';
EXEC InsertCustomer 88, 'Fatima Yousaf','03955380592', 'Iqbal Town','Lahore';
EXEC InsertCustomer 89, 'Sara Yousaf','03153308079', 'Johar Town','Lahore';
EXEC InsertCustomer 90, 'Fatima Imran','03404128178', 'Shahdara','Lahore';
EXEC InsertCustomer 91, 'Saima Malik','03631020435', 'Johar Town','Lahore';
EXEC InsertCustomer 92, 'Asad Aslam','03581412976', 'Samanabad','Lahore';
EXEC InsertCustomer 93, 'Zainab Abbas','03374147819', 'Gulberg','Lahore';
EXEC InsertCustomer 94, 'Tariq Malik','03783323125', 'Ghulshan-e-Ravi','Lahore';
EXEC InsertCustomer 95, 'Asad Raza','03318077041', 'Wapda Town','Lahore';
EXEC InsertCustomer 96, 'Saima Abbas','03423157833', 'Johar Town','Lahore';
EXEC InsertCustomer 97, 'Tariq Zahid','03866599026', 'Garden Town','Lahore';
EXEC InsertCustomer 98, 'Sara Abbas','03602618825', 'Township','Lahore';
EXEC InsertCustomer 99, 'Ali Nawaz','03559026523', 'Johar Town','Lahore';
EXEC InsertCustomer 100, 'Aisha Imran','03986327536', 'Iqbal Town','Lahore';
EXEC InsertCustomer 101, 'Aisha Ali','03842685447', 'Defence','Lahore';
EXEC InsertCustomer 102, 'Aisha Akhtar','03814206490', 'Johar Town','Lahore';
EXEC InsertCustomer 103, 'Fatima Ahmed','03172868977', 'Raiwind Road','Lahore';
EXEC InsertCustomer 104, 'Naveed Rehman','03621129840', 'Defence','Lahore';
EXEC InsertCustomer 105, 'Muhammad Hussain','03914458275', 'Shadman','Lahore';
EXEC InsertCustomer 106, 'Hassan Rehman','03734537517', 'Shahdara','Lahore';
EXEC InsertCustomer 107, 'Bilal Hassan','03385838706', 'Garden Town','Lahore';
EXEC InsertCustomer 108, 'Hassan Hussain','03668290859', 'Raiwind Road','Lahore';
EXEC InsertCustomer 109, 'Saima Abbas','03572830962', 'Wapda Town','Lahore';
EXEC InsertCustomer 110, 'Zainab Akhtar','03217268362', 'Sabzazar','Lahore';
EXEC InsertCustomer 111, 'Amna Iqbal','03601786508', 'DHA','Lahore';
EXEC InsertCustomer 112, 'Amna Malik','03266751014', 'Gulberg','Lahore';
EXEC InsertCustomer 113, 'Saima Khan','03475666402', 'Gulshan-e-Lahore','Lahore';
EXEC InsertCustomer 114, 'Usman Rashid','03422734002', 'Raiwind Road','Lahore';
EXEC InsertCustomer 115, 'Bilal Ali','03223315552', 'Shahdara','Lahore';
EXEC InsertCustomer 116, 'Amna Ali','03909240814', 'Shadman','Lahore';
EXEC InsertCustomer 117, 'Tariq Raza','03876424563', 'Cantt','Lahore';
EXEC InsertCustomer 118, 'Hira Aslam','03651751896', 'Sabzazar','Lahore';
EXEC InsertCustomer 119, 'Tariq Malik','03867208117', 'Faisal Town','Lahore';
EXEC InsertCustomer 120, 'Amna Malik','03505613120', 'Township','Lahore';
EXEC InsertCustomer 121, 'Naveed Ahmed','03597145656', 'Shadman','Lahore';
EXEC InsertCustomer 122, 'Tariq Nasir','03128874882', 'Allama Iqbal Town','Lahore';
EXEC InsertCustomer 123, 'Usman Imran','03397221311', 'Township','Lahore';
EXEC InsertCustomer 124, 'Tariq Mehmood','03621328633', 'Allama Iqbal Town','Lahore';
EXEC InsertCustomer 125, 'Aisha Rashid','03124723626', 'Gulshan-e-Lahore','Lahore';
EXEC InsertCustomer 126, 'Farhan Khan','03778149623', 'Defence','Lahore';
EXEC InsertCustomer 127, 'Muhammad Nawaz','03931349691', 'Sabzazar','Lahore';
EXEC InsertCustomer 128, 'Fatima Nasir','03454293382', 'Raiwind Road','Lahore';
EXEC InsertCustomer 129, 'Maryam Ahmed','03158329961', 'DHA','Lahore';
EXEC InsertCustomer 130, 'Hassan Akhtar','03786539173', 'Liaqatabad','Lahore';
EXEC InsertCustomer 131, 'Ahmed Abbas','03616867194', 'Cantt','Lahore';
EXEC InsertCustomer 132, 'Muhammad Farooq','03171890497', 'Liaqatabad','Lahore';
EXEC InsertCustomer 133, 'Sana Yousaf','03256347509', 'Model Town','Lahore';
EXEC InsertCustomer 134, 'Hira Malik','03513658573', 'Wapda Town','Lahore';
EXEC InsertCustomer 135, 'Farhan Iqbal','03574040139', 'DHA','Lahore';
EXEC InsertCustomer 136, 'Farhan Zahid','03184336609', 'Allama Iqbal Town','Lahore';
EXEC InsertCustomer 137, 'Farhan Rehman','03467386984', 'Iqbal Town','Lahore';
EXEC InsertCustomer 138, 'Sana Farooq','03908025074', 'Iqbal Town','Lahore';
EXEC InsertCustomer 139, 'Maryam Yousaf','03999402386', 'Allama Iqbal Town','Lahore';
EXEC InsertCustomer 140, 'Amna Yousaf','03129611357', 'Ghulshan-e-Ravi','Lahore';
EXEC InsertCustomer 141, 'Farhan Akhtar','03271158560', 'Shadman','Lahore';
EXEC InsertCustomer 142, 'Sana Raza','03799308956', 'Raiwind Road','Lahore';
EXEC InsertCustomer 143, 'Ali Raza','03782619460', 'Faisal Town','Lahore';
EXEC InsertCustomer 144, 'Naveed Nasir','03605255106', 'Gulberg','Lahore';
EXEC InsertCustomer 145, 'Bilal Khan','03994639396', 'Defence','Lahore';
EXEC InsertCustomer 146, 'Sara Hassan','03247100990', 'Gulberg','Lahore';
EXEC InsertCustomer 147, 'Sana Ahmed','03599281070', 'Wapda Town','Lahore';
EXEC InsertCustomer 148, 'Farhan Farooq','03721454799', 'Shadman','Lahore';
EXEC InsertCustomer 149, 'Sara Aslam','03605900264', 'Faisal Town','Lahore';
EXEC InsertCustomer 150, 'Sadia Khan','03636124612', 'Wapda Town','Lahore';

DELETE from Orders
DELETE from OrderDetail
--Insertion in Order Table:
EXEC InsertOrder 1,'2023-01-28 22:44:00', '2023-01-29 22:44:00', 'Cantt','Lahore', 128 ,143;
EXEC InsertOrder 2,'2023-10-23 17:25:57', '2023-11-09 17:25:57', 'Johar Town','Lahore', 140 ,107;
EXEC InsertOrder 3,'2024-03-09 00:01:47', '2024-03-14 00:01:47', 'Sabzazar','Lahore', 96 ,4;
EXEC InsertOrder 4,'2023-06-15 17:23:54', '2023-06-27 17:23:54', 'Johar Town','Lahore', 78 ,99;
EXEC InsertOrder 5,'2023-11-26 09:26:35', '2023-12-19 09:26:35', 'Iqbal Town','Lahore', 29 ,48;
EXEC InsertOrder 6,'2024-01-05 05:02:17', '2024-01-18 05:02:17', 'Gari Shahu','Lahore', 77 ,91;
EXEC InsertOrder 7,'2023-05-18 14:20:35', '2023-06-11 14:20:35', 'Bahria Town','Lahore', 86 ,35;
EXEC InsertOrder 8,'2023-05-30 11:42:49', '2023-06-09 11:42:49', 'Wapda Town','Lahore', 71 ,12;
EXEC InsertOrder 9,'2023-08-18 02:20:02', '2023-09-13 02:20:02', 'Wapda Town','Lahore', 96 ,74;
EXEC InsertOrder 10,'2023-10-14 18:09:55', '2023-11-04 18:09:55', 'Garden Town','Lahore', 119 ,112;
EXEC InsertOrder 11,'2023-08-22 01:11:21', '2023-09-19 01:11:21', 'Sabzazar','Lahore', 83 ,94;
EXEC InsertOrder 12,'2023-01-27 12:58:05', '2023-02-05 12:58:05', 'Mozang','Lahore', 64 ,114;
EXEC InsertOrder 13,'2023-05-27 07:04:23', '2023-06-03 07:04:23', 'Bahria Town','Lahore', 34 ,40;
EXEC InsertOrder 14,'2023-12-31 15:14:07', '2024-01-14 15:14:07', 'Samanabad','Lahore', 130 ,3;
EXEC InsertOrder 15,'2024-03-21 10:03:20', '2024-04-04 10:03:20', 'Iqbal Town','Lahore', 73 ,139;
EXEC InsertOrder 16,'2023-03-24 14:40:30', '2023-04-07 14:40:30', 'Walled City','Lahore', 135 ,138;
EXEC InsertOrder 17,'2023-04-25 06:42:19', '2023-05-17 06:42:19', 'Allama Iqbal Town','Lahore', 120 ,102;
EXEC InsertOrder 18,'2024-04-09 07:17:35', '2024-04-29 07:17:35', 'Johar Town','Lahore', 61 ,51;
EXEC InsertOrder 19,'2023-03-13 03:05:09', '2023-03-30 03:05:09', 'Johar Town','Lahore', 62 ,55;
EXEC InsertOrder 20,'2023-04-07 04:10:06', '2023-04-20 04:10:06', 'Mozang','Lahore', 139 ,22;
EXEC InsertOrder 21,'2023-05-08 05:52:58', '2023-05-25 05:52:58', 'Walled City','Lahore', 11 ,77;
EXEC InsertOrder 22,'2023-11-13 08:03:24', '2023-11-18 08:03:24', 'Cantt','Lahore', 38 ,78;
EXEC InsertOrder 23,'2024-03-13 03:13:40', '2024-03-20 03:13:40', 'Cantt','Lahore', 85 ,106;
EXEC InsertOrder 24,'2024-03-24 14:56:45', '2024-04-22 14:56:45', 'Allama Iqbal Town','Lahore', 54 ,149;
EXEC InsertOrder 25,'2024-04-15 16:06:15', '2024-04-16 16:06:15', 'Garden Town','Lahore', 69 ,124;
EXEC InsertOrder 26,'2023-08-27 18:35:10', '2023-09-15 18:35:10', 'DHA','Lahore', 117 ,67;
EXEC InsertOrder 27,'2023-08-27 04:11:08', '2023-08-28 04:11:08', 'Gulberg','Lahore', 107 ,150;
EXEC InsertOrder 28,'2023-07-30 03:36:52', '2023-08-24 03:36:52', 'Askari','Lahore', 1 ,81;
EXEC InsertOrder 29,'2024-01-05 05:52:54', '2024-01-11 05:52:54', 'Walled City','Lahore', 116 ,94;
EXEC InsertOrder 30,'2023-07-25 00:39:03', '2023-08-23 00:39:03', 'Johar Town','Lahore', 49 ,38;
EXEC InsertOrder 31,'2023-12-13 12:50:14', '2024-01-02 12:50:14', 'Bahria Town','Lahore', 31 ,72;
EXEC InsertOrder 32,'2023-08-17 01:14:19', '2023-09-15 01:14:19', 'Sabzazar','Lahore', 121 ,137;
EXEC InsertOrder 33,'2024-04-16 00:06:04', '2024-04-18 00:06:04', 'Cantt','Lahore', 20 ,52;
EXEC InsertOrder 34,'2023-09-21 02:37:34', '2023-10-11 02:37:34', 'Askari','Lahore', 27 ,145;
EXEC InsertOrder 35,'2023-02-11 16:15:30', '2023-03-03 16:15:30', 'Allama Iqbal Town','Lahore', 69 ,147;
EXEC InsertOrder 36,'2023-10-27 19:14:39', '2023-11-20 19:14:39', 'Gulberg','Lahore', 121 ,107;
EXEC InsertOrder 37,'2023-10-27 17:28:06', '2023-10-28 17:28:06', 'Walled City','Lahore', 8 ,99;
EXEC InsertOrder 38,'2024-03-08 12:21:07', '2024-03-10 12:21:07', 'Model Town','Lahore', 116 ,74;
EXEC InsertOrder 39,'2023-05-27 08:42:55', '2023-05-28 08:42:55', 'Wapda Town','Lahore', 148 ,147;
EXEC InsertOrder 40,'2023-01-01 08:22:04', '2023-01-05 08:22:04', 'Walled City','Lahore', 108 ,2;
EXEC InsertOrder 41,'2024-03-25 06:44:03', '2024-03-29 06:44:03', 'Shadman','Lahore', 51 ,46;
EXEC InsertOrder 42,'2023-05-20 11:33:22', '2023-06-16 11:33:22', 'Ravi Road','Lahore', 129 ,3;
EXEC InsertOrder 43,'2023-12-26 19:56:14', '2024-01-22 19:56:14', 'Bahria Town','Lahore', 32 ,61;
EXEC InsertOrder 44,'2023-10-16 20:05:39', '2023-10-24 20:05:39', 'Johar Town','Lahore', 144 ,130;
EXEC InsertOrder 45,'2023-04-13 19:45:48', '2023-04-28 19:45:48', 'Walled City','Lahore', 65 ,33;
EXEC InsertOrder 46,'2023-12-10 00:15:55', '2023-12-16 00:15:55', 'Wapda Town','Lahore', 75 ,122;
EXEC InsertOrder 47,'2023-03-18 23:00:36', '2023-04-17 23:00:36', 'Askari','Lahore', 66 ,35;
EXEC InsertOrder 48,'2023-07-01 07:03:56', '2023-07-12 07:03:56', 'Cantt','Lahore', 15 ,86;
EXEC InsertOrder 49,'2023-02-02 10:45:25', '2023-02-07 10:45:25', 'Iqbal Town','Lahore', 67 ,34;
EXEC InsertOrder 50,'2023-01-21 23:12:52', '2023-02-16 23:12:52', 'Walled City','Lahore', 106 ,33;
EXEC InsertOrder 51,'2024-01-02 15:21:07', '2024-01-19 15:21:07', 'Johar Town','Lahore', 144 ,59;
EXEC InsertOrder 52,'2023-02-15 12:49:58', '2023-02-20 12:49:58', 'Cantt','Lahore', 85 ,16;
EXEC InsertOrder 53,'2023-05-31 02:58:39', '2023-06-06 02:58:39', 'Gari Shahu','Lahore', 68 ,36;
EXEC InsertOrder 54,'2023-11-10 02:47:22', '2023-12-08 02:47:22', 'Garden Town','Lahore', 135 ,133;
EXEC InsertOrder 55,'2023-09-05 14:07:26', '2023-10-02 14:07:26', 'Mozang','Lahore', 15 ,99;
EXEC InsertOrder 56,'2024-04-26 20:29:50', '2024-05-03 20:29:50', 'Walled City','Lahore', 37 ,30;
EXEC InsertOrder 57,'2023-12-26 23:09:34', '2024-01-04 23:09:34', 'Iqbal Town','Lahore', 64 ,116;
EXEC InsertOrder 58,'2024-02-22 05:14:01', '2024-02-23 05:14:01', 'Askari','Lahore', 46 ,125;
EXEC InsertOrder 59,'2024-04-22 10:32:13', '2024-04-26 10:32:13', 'Wapda Town','Lahore', 6 ,100;
EXEC InsertOrder 60,'2023-02-10 05:30:57', '2023-03-02 05:30:57', 'Iqbal Town','Lahore', 32 ,60;
EXEC InsertOrder 61,'2023-10-03 05:31:09', '2023-10-27 05:31:09', 'Shadman','Lahore', 5 ,137;
EXEC InsertOrder 62,'2024-04-10 00:24:04', '2024-04-25 00:24:04', 'Johar Town','Lahore', 15 ,76;
EXEC InsertOrder 63,'2023-06-12 00:57:31', '2023-06-14 00:57:31', 'Model Town','Lahore', 75 ,25;
EXEC InsertOrder 64,'2023-07-04 02:24:33', '2023-07-27 02:24:33', 'Cantt','Lahore', 107 ,120;
EXEC InsertOrder 65,'2024-02-25 21:44:16', '2024-03-11 21:44:16', 'Iqbal Town','Lahore', 47 ,94;
EXEC InsertOrder 66,'2023-12-14 03:24:04', '2023-12-28 03:24:04', 'Johar Town','Lahore', 109 ,72;
EXEC InsertOrder 67,'2023-10-10 16:42:38', '2023-10-27 16:42:38', 'Gulberg','Lahore', 79 ,115;
EXEC InsertOrder 68,'2023-01-15 05:15:19', '2023-02-05 05:15:19', 'Gari Shahu','Lahore', 65 ,88;
EXEC InsertOrder 69,'2023-03-31 21:40:59', '2023-04-15 21:40:59', 'Allama Iqbal Town','Lahore', 98 ,94;
EXEC InsertOrder 70,'2023-04-08 22:16:45', '2023-04-26 22:16:45', 'Model Town','Lahore', 76 ,60;
EXEC InsertOrder 71,'2023-06-04 12:57:47', '2023-06-13 12:57:47', 'Mozang','Lahore', 116 ,74;
EXEC InsertOrder 72,'2024-04-04 12:38:51', '2024-04-08 12:38:51', 'Mughalpura','Lahore', 2 ,137;
EXEC InsertOrder 73,'2023-02-07 04:42:08', '2023-02-25 04:42:08', 'Ravi Road','Lahore', 40 ,26;
EXEC InsertOrder 74,'2023-09-10 06:05:06', '2023-10-04 06:05:06', 'Model Town','Lahore', 72 ,21;
EXEC InsertOrder 75,'2023-03-14 13:33:18', '2023-04-11 13:33:18', 'Garden Town','Lahore', 137 ,34;
EXEC InsertOrder 76,'2023-12-04 05:43:28', '2023-12-15 05:43:28', 'Iqbal Town','Lahore', 107 ,88;
EXEC InsertOrder 77,'2023-09-02 02:34:03', '2023-09-23 02:34:03', 'Model Town','Lahore', 124 ,68;
EXEC InsertOrder 78,'2024-03-28 23:00:37', '2024-04-15 23:00:37', 'Samanabad','Lahore', 37 ,44;
EXEC InsertOrder 79,'2024-02-19 23:31:00', '2024-03-03 23:31:00', 'Ravi Road','Lahore', 142 ,127;
EXEC InsertOrder 80,'2023-01-11 00:28:36', '2023-01-31 00:28:36', 'Model Town','Lahore', 99 ,17;
EXEC InsertOrder 81,'2023-03-03 18:48:49', '2023-03-25 18:48:49', 'Cantt','Lahore', 62 ,130;
EXEC InsertOrder 82,'2024-02-04 18:12:07', '2024-02-06 18:12:07', 'Model Town','Lahore', 96 ,81;
EXEC InsertOrder 83,'2023-11-19 12:27:55', '2023-11-24 12:27:55', 'Wapda Town','Lahore', 134 ,8;
EXEC InsertOrder 84,'2023-08-02 14:10:24', '2023-08-24 14:10:24', 'Shadman','Lahore', 81 ,49;
EXEC InsertOrder 85,'2024-03-23 22:01:04', '2024-03-26 22:01:04', 'Sabzazar','Lahore', 72 ,108;
EXEC InsertOrder 86,'2024-03-28 16:43:18', '2024-04-16 16:43:18', 'Allama Iqbal Town','Lahore', 43 ,28;
EXEC InsertOrder 87,'2023-08-18 05:53:21', '2023-09-11 05:53:21', 'Samanabad','Lahore', 46 ,12;
EXEC InsertOrder 88,'2023-11-14 18:54:54', '2023-11-28 18:54:54', 'Wapda Town','Lahore', 102 ,144;
EXEC InsertOrder 89,'2023-05-30 01:33:52', '2023-06-02 01:33:52', 'Garden Town','Lahore', 23 ,1;
EXEC InsertOrder 90,'2024-04-25 18:36:28', '2024-05-09 18:36:28', 'Gulberg','Lahore', 101 ,144;
EXEC InsertOrder 91,'2023-01-03 11:58:38', '2023-02-02 11:58:38', 'Askari','Lahore', 122 ,24;
EXEC InsertOrder 92,'2023-12-22 11:21:13', '2024-01-15 11:21:13', 'Mozang','Lahore', 44 ,49;
EXEC InsertOrder 93,'2023-06-25 02:58:22', '2023-07-06 02:58:22', 'Sabzazar','Lahore', 90 ,103;
EXEC InsertOrder 94,'2023-07-16 10:14:20', '2023-08-11 10:14:20', 'Walled City','Lahore', 3 ,75;
EXEC InsertOrder 95,'2023-12-29 18:02:47', '2024-01-01 18:02:47', 'Shadman','Lahore', 90 ,146;
EXEC InsertOrder 96,'2024-02-21 13:32:42', '2024-03-16 13:32:42', 'Iqbal Town','Lahore', 125 ,147;
EXEC InsertOrder 97,'2024-04-23 19:00:04', '2024-05-04 19:00:04', 'DHA','Lahore', 98 ,46;
EXEC InsertOrder 98,'2023-08-03 00:08:44', '2023-08-26 00:08:44', 'Gari Shahu','Lahore', 87 ,53;
EXEC InsertOrder 99,'2023-03-07 20:43:26', '2023-03-10 20:43:26', 'Mughalpura','Lahore', 75 ,72;
EXEC InsertOrder 100,'2023-07-28 09:29:40', '2023-08-04 09:29:40', 'DHA','Lahore', 52 ,45;
EXEC InsertOrder 101,'2023-01-17 19:42:26', '2023-01-31 19:42:26', 'Sabzazar','Lahore', 77 ,51;
EXEC InsertOrder 102,'2023-11-21 11:00:29', '2023-11-22 11:00:29', 'Bahria Town','Lahore', 11 ,91;
EXEC InsertOrder 103,'2023-11-11 21:00:10', '2023-11-13 21:00:10', 'Johar Town','Lahore', 49 ,16;
EXEC InsertOrder 104,'2023-11-30 09:13:25', '2023-12-16 09:13:25', 'Mozang','Lahore', 142 ,44;
EXEC InsertOrder 105,'2023-08-27 04:36:18', '2023-09-15 04:36:18', 'Sabzazar','Lahore', 32 ,102;
EXEC InsertOrder 106,'2023-07-08 17:30:08', '2023-07-21 17:30:08', 'Cantt','Lahore', 64 ,86;
EXEC InsertOrder 107,'2024-04-17 15:49:57', '2024-05-10 15:49:57', 'Faisal Town','Lahore', 28 ,44;
EXEC InsertOrder 108,'2023-08-29 15:23:39', '2023-09-16 15:23:39', 'Mozang','Lahore', 92 ,3;
EXEC InsertOrder 109,'2023-11-18 01:57:19', '2023-12-16 01:57:19', 'Askari','Lahore', 30 ,114;
EXEC InsertOrder 110,'2023-05-24 08:37:48', '2023-05-30 08:37:48', 'Bahria Town','Lahore', 67 ,25;
EXEC InsertOrder 111,'2023-12-12 06:20:47', '2023-12-20 06:20:47', 'Ravi Road','Lahore', 86 ,145;
EXEC InsertOrder 112,'2024-02-18 16:36:04', '2024-03-01 16:36:04', 'Faisal Town','Lahore', 46 ,78;
EXEC InsertOrder 113,'2023-10-23 00:17:44', '2023-10-31 00:17:44', 'Walled City','Lahore', 62 ,128;
EXEC InsertOrder 114,'2023-10-15 17:57:21', '2023-11-12 17:57:21', 'Model Town','Lahore', 66 ,89;
EXEC InsertOrder 115,'2023-01-29 08:25:11', '2023-01-31 08:25:11', 'Bahria Town','Lahore', 28 ,41;
EXEC InsertOrder 116,'2023-04-19 11:49:06', '2023-05-10 11:49:06', 'Walled City','Lahore', 37 ,63;
EXEC InsertOrder 117,'2023-09-01 21:11:42', '2023-10-01 21:11:42', 'Gulberg','Lahore', 28 ,61;
EXEC InsertOrder 118,'2023-11-08 14:24:16', '2023-11-30 14:24:16', 'Ravi Road','Lahore', 27 ,129;
EXEC InsertOrder 119,'2024-03-30 13:30:51', '2024-04-27 13:30:51', 'Mozang','Lahore', 22 ,94;
EXEC InsertOrder 120,'2024-04-15 07:45:55', '2024-04-16 07:45:55', 'Johar Town','Lahore', 148 ,66;
EXEC InsertOrder 121,'2023-05-03 13:17:53', '2023-05-31 13:17:53', 'Gulberg','Lahore', 8 ,107;
EXEC InsertOrder 122,'2023-07-28 00:40:28', '2023-07-30 00:40:28', 'Iqbal Town','Lahore', 62 ,21;
EXEC InsertOrder 123,'2023-06-20 00:21:09', '2023-07-19 00:21:09', 'Garden Town','Lahore', 114 ,29;
EXEC InsertOrder 124,'2023-01-25 06:29:02', '2023-02-05 06:29:02', 'DHA','Lahore', 136 ,91;
EXEC InsertOrder 125,'2023-12-04 21:41:22', '2023-12-20 21:41:22', 'Samanabad','Lahore', 117 ,136;
EXEC InsertOrder 126,'2024-01-11 15:28:42', '2024-02-08 15:28:42', 'Walled City','Lahore', 86 ,127;
EXEC InsertOrder 127,'2023-04-04 11:55:05', '2023-04-25 11:55:05', 'Askari','Lahore', 138 ,68;
EXEC InsertOrder 128,'2023-04-09 15:13:54', '2023-04-18 15:13:54', 'Model Town','Lahore', 8 ,50;
EXEC InsertOrder 129,'2023-12-13 12:16:58', '2023-12-14 12:16:58', 'Cantt','Lahore', 129 ,43;
EXEC InsertOrder 130,'2023-06-14 09:18:21', '2023-07-10 09:18:21', 'Mozang','Lahore', 50 ,149;
EXEC InsertOrder 131,'2023-08-18 03:30:49', '2023-09-12 03:30:49', 'Samanabad','Lahore', 118 ,113;
EXEC InsertOrder 132,'2023-05-01 04:23:19', '2023-05-17 04:23:19', 'Iqbal Town','Lahore', 4 ,120;
EXEC InsertOrder 133,'2023-02-24 02:09:51', '2023-03-03 02:09:51', 'Sabzazar','Lahore', 27 ,37;
EXEC InsertOrder 134,'2023-11-19 16:53:54', '2023-11-24 16:53:54', 'Faisal Town','Lahore', 127 ,60;
EXEC InsertOrder 135,'2023-11-26 12:23:41', '2023-12-11 12:23:41', 'Faisal Town','Lahore', 57 ,113;
EXEC InsertOrder 136,'2023-08-02 22:15:48', '2023-08-19 22:15:48', 'Samanabad','Lahore', 34 ,21;
EXEC InsertOrder 137,'2024-03-30 23:35:52', '2024-04-26 23:35:52', 'Gari Shahu','Lahore', 2 ,73;
EXEC InsertOrder 138,'2023-03-29 15:03:57', '2023-04-06 15:03:57', 'Allama Iqbal Town','Lahore', 9 ,107;
EXEC InsertOrder 139,'2023-04-23 22:28:13', '2023-05-20 22:28:13', 'DHA','Lahore', 139 ,23;
EXEC InsertOrder 140,'2023-02-07 11:12:18', '2023-02-22 11:12:18', 'Samanabad','Lahore', 111 ,14;
EXEC InsertOrder 141,'2023-03-08 13:02:24', '2023-03-24 13:02:24', 'Ravi Road','Lahore', 129 ,8;
EXEC InsertOrder 142,'2023-11-25 06:03:37', '2023-12-16 06:03:37', 'Gulberg','Lahore', 99 ,1;
EXEC InsertOrder 143,'2023-09-23 10:30:08', '2023-09-26 10:30:08', 'Faisal Town','Lahore', 39 ,98;
EXEC InsertOrder 144,'2023-07-30 10:57:35', '2023-08-11 10:57:35', 'Shadman','Lahore', 100 ,104;
EXEC InsertOrder 145,'2024-03-12 11:20:58', '2024-04-11 11:20:58', 'Iqbal Town','Lahore', 34 ,107;
EXEC InsertOrder 146,'2024-01-07 15:36:44', '2024-01-18 15:36:44', 'Shadman','Lahore', 99 ,133;
EXEC InsertOrder 147,'2023-05-02 08:49:54', '2023-05-13 08:49:54', 'Mughalpura','Lahore', 101 ,99;
EXEC InsertOrder 148,'2024-02-06 22:07:05', '2024-03-04 22:07:05', 'Wapda Town','Lahore', 108 ,120;
EXEC InsertOrder 149,'2023-03-10 10:18:12', '2023-04-09 10:18:12', 'Mughalpura','Lahore', 1 ,49;
EXEC InsertOrder 150,'2023-03-13 09:06:52', '2023-03-30 09:06:52', 'Mughalpura','Lahore', 114 ,28;
EXEC InsertOrder 151,'2024-04-03 12:49:25', '2024-04-13 12:49:25', 'DHA','Lahore', 38 ,31;
EXEC InsertOrder 152,'2023-05-07 11:06:17', '2023-05-12 11:06:17', 'Johar Town','Lahore', 40 ,39;
EXEC InsertOrder 153,'2023-02-20 10:10:20', '2023-02-24 10:10:20', 'Allama Iqbal Town','Lahore', 37 ,120;
EXEC InsertOrder 154,'2023-09-19 16:02:20', '2023-10-03 16:02:20', 'Shadman','Lahore', 48 ,117;
EXEC InsertOrder 155,'2023-01-23 16:45:23', '2023-01-28 16:45:23', 'Faisal Town','Lahore', 117 ,149;
EXEC InsertOrder 156,'2023-02-09 20:44:42', '2023-02-27 20:44:42', 'Johar Town','Lahore', 56 ,16;
EXEC InsertOrder 157,'2024-04-25 17:20:33', '2024-05-07 17:20:33', 'Walled City','Lahore', 8 ,73;
EXEC InsertOrder 158,'2024-02-06 02:55:27', '2024-02-27 02:55:27', 'Sabzazar','Lahore', 13 ,9;
EXEC InsertOrder 159,'2023-01-09 03:58:10', '2023-01-30 03:58:10', 'DHA','Lahore', 65 ,139;
EXEC InsertOrder 160,'2024-03-05 20:38:02', '2024-04-01 20:38:02', 'Walled City','Lahore', 13 ,97;
EXEC InsertOrder 161,'2023-04-06 14:52:43', '2023-04-12 14:52:43', 'Wapda Town','Lahore', 100 ,82;
EXEC InsertOrder 162,'2024-02-28 04:35:06', '2024-03-05 04:35:06', 'Gari Shahu','Lahore', 99 ,96;
EXEC InsertOrder 163,'2024-01-10 23:15:41', '2024-01-30 23:15:41', 'Walled City','Lahore', 106 ,105;
EXEC InsertOrder 164,'2023-06-07 04:12:51', '2023-06-11 04:12:51', 'Askari','Lahore', 41 ,88;
EXEC InsertOrder 165,'2023-01-08 21:23:42', '2023-01-28 21:23:42', 'Shadman','Lahore', 35 ,129;
EXEC InsertOrder 166,'2023-08-24 21:25:06', '2023-09-06 21:25:06', 'Johar Town','Lahore', 91 ,66;
EXEC InsertOrder 167,'2023-05-19 09:08:13', '2023-06-05 09:08:13', 'Askari','Lahore', 62 ,39;
EXEC InsertOrder 168,'2024-02-29 11:33:15', '2024-03-25 11:33:15', 'Johar Town','Lahore', 92 ,52;
EXEC InsertOrder 169,'2023-11-07 06:04:21', '2023-11-29 06:04:21', 'Faisal Town','Lahore', 13 ,143;
EXEC InsertOrder 170,'2023-12-24 20:32:59', '2024-01-07 20:32:59', 'Cantt','Lahore', 73 ,87;
EXEC InsertOrder 171,'2024-04-21 22:25:52', '2024-05-18 22:25:52', 'Allama Iqbal Town','Lahore', 133 ,105;
EXEC InsertOrder 172,'2023-09-25 08:24:21', '2023-10-17 08:24:21', 'Gulberg','Lahore', 101 ,43;
EXEC InsertOrder 173,'2023-03-06 00:26:06', '2023-03-07 00:26:06', 'Sabzazar','Lahore', 40 ,133;
EXEC InsertOrder 174,'2023-04-30 08:36:29', '2023-05-11 08:36:29', 'Johar Town','Lahore', 43 ,135;
EXEC InsertOrder 175,'2023-09-25 16:25:02', '2023-10-03 16:25:02', 'Gari Shahu','Lahore', 37 ,62;
EXEC InsertOrder 176,'2023-08-14 10:05:41', '2023-08-21 10:05:41', 'Mughalpura','Lahore', 36 ,122;
EXEC InsertOrder 177,'2023-10-02 00:57:27', '2023-10-06 00:57:27', 'Mughalpura','Lahore', 100 ,107;
EXEC InsertOrder 178,'2023-06-23 13:16:33', '2023-06-28 13:16:33', 'Faisal Town','Lahore', 12 ,64;
EXEC InsertOrder 179,'2023-07-13 06:15:58', '2023-07-26 06:15:58', 'Sabzazar','Lahore', 74 ,88;
EXEC InsertOrder 180,'2024-01-23 05:05:10', '2024-02-17 05:05:10', 'Ravi Road','Lahore', 92 ,61;
EXEC InsertOrder 181,'2023-09-10 23:15:35', '2023-09-27 23:15:35', 'Bahria Town','Lahore', 17 ,58;
EXEC InsertOrder 182,'2023-12-23 23:20:01', '2023-12-27 23:20:01', 'Faisal Town','Lahore', 140 ,35;
EXEC InsertOrder 183,'2023-08-25 14:37:42', '2023-09-04 14:37:42', 'Wapda Town','Lahore', 142 ,74;
EXEC InsertOrder 184,'2023-12-22 21:25:39', '2024-01-05 21:25:39', 'Faisal Town','Lahore', 85 ,103;
EXEC InsertOrder 185,'2023-04-06 00:53:18', '2023-04-14 00:53:18', 'Ravi Road','Lahore', 87 ,106;
EXEC InsertOrder 186,'2023-12-02 22:34:14', '2023-12-17 22:34:14', 'DHA','Lahore', 65 ,137;
EXEC InsertOrder 187,'2023-11-24 11:14:34', '2023-12-18 11:14:34', 'Garden Town','Lahore', 90 ,46;
EXEC InsertOrder 188,'2024-04-04 06:57:26', '2024-05-01 06:57:26', 'Gulberg','Lahore', 27 ,108;
EXEC InsertOrder 189,'2024-04-03 03:34:06', '2024-04-27 03:34:06', 'Ravi Road','Lahore', 24 ,115;
EXEC InsertOrder 190,'2023-06-29 15:43:41', '2023-07-16 15:43:41', 'DHA','Lahore', 136 ,80;
EXEC InsertOrder 191,'2024-03-09 01:34:06', '2024-04-08 01:34:06', 'Mughalpura','Lahore', 92 ,132;
EXEC InsertOrder 192,'2023-09-20 01:01:54', '2023-10-20 01:01:54', 'Walled City','Lahore', 55 ,33;
EXEC InsertOrder 193,'2024-01-24 22:14:27', '2024-01-30 22:14:27', 'Shadman','Lahore', 16 ,143;
EXEC InsertOrder 194,'2023-07-26 23:58:13', '2023-08-15 23:58:13', 'Johar Town','Lahore', 88 ,113;
EXEC InsertOrder 195,'2024-03-14 02:15:41', '2024-03-24 02:15:41', 'Shadman','Lahore', 89 ,31;
EXEC InsertOrder 196,'2024-03-12 00:38:34', '2024-04-06 00:38:34', 'Ravi Road','Lahore', 7 ,63;
EXEC InsertOrder 197,'2023-10-30 18:34:30', '2023-11-02 18:34:30', 'Faisal Town','Lahore', 100 ,76;
EXEC InsertOrder 198,'2023-07-17 02:48:58', '2023-08-09 02:48:58', 'Bahria Town','Lahore', 10 ,30;
EXEC InsertOrder 199,'2023-09-17 18:48:53', '2023-10-15 18:48:53', 'Bahria Town','Lahore', 93 ,109;
EXEC InsertOrder 200,'2023-09-05 01:01:48', '2023-09-19 01:01:48', 'Model Town','Lahore', 83 ,65;
EXEC InsertOrder 201,'2023-11-07 06:48:52', '2023-11-17 06:48:52', 'Johar Town','Lahore', 107 ,70;
EXEC InsertOrder 202,'2023-03-17 03:36:34', '2023-03-25 03:36:34', 'Walled City','Lahore', 52 ,141;
EXEC InsertOrder 203,'2023-07-31 21:11:27', '2023-08-21 21:11:27', 'Walled City','Lahore', 128 ,79;
EXEC InsertOrder 204,'2024-04-26 12:59:33', '2024-05-26 12:59:33', 'Johar Town','Lahore', 58 ,136;
EXEC InsertOrder 205,'2023-06-06 10:47:49', '2023-06-11 10:47:49', 'Mozang','Lahore', 42 ,61;
EXEC InsertOrder 206,'2023-06-26 15:59:04', '2023-06-27 15:59:04', 'Gulberg','Lahore', 43 ,34;
EXEC InsertOrder 207,'2023-05-19 21:39:53', '2023-06-07 21:39:53', 'Walled City','Lahore', 87 ,118;
EXEC InsertOrder 208,'2023-09-09 07:57:21', '2023-10-02 07:57:21', 'Garden Town','Lahore', 133 ,80;
EXEC InsertOrder 209,'2024-01-06 06:23:57', '2024-01-22 06:23:57', 'Iqbal Town','Lahore', 70 ,48;
EXEC InsertOrder 210,'2023-09-04 19:10:13', '2023-09-29 19:10:13', 'Bahria Town','Lahore', 27 ,1;
EXEC InsertOrder 211,'2023-03-02 01:37:28', '2023-03-27 01:37:28', 'Ravi Road','Lahore', 54 ,126;
EXEC InsertOrder 212,'2023-04-27 17:20:58', '2023-05-21 17:20:58', 'Samanabad','Lahore', 20 ,88;
EXEC InsertOrder 213,'2023-07-01 02:08:50', '2023-07-23 02:08:50', 'Garden Town','Lahore', 78 ,67;
EXEC InsertOrder 214,'2023-08-20 02:10:38', '2023-09-03 02:10:38', 'Gari Shahu','Lahore', 6 ,100;
EXEC InsertOrder 215,'2023-06-04 01:08:58', '2023-06-25 01:08:58', 'Samanabad','Lahore', 131 ,120;
EXEC InsertOrder 216,'2023-11-21 01:09:35', '2023-12-02 01:09:35', 'Faisal Town','Lahore', 26 ,106;
EXEC InsertOrder 217,'2023-01-16 21:51:39', '2023-02-11 21:51:39', 'Allama Iqbal Town','Lahore', 55 ,115;
EXEC InsertOrder 218,'2023-02-17 01:26:46', '2023-02-28 01:26:46', 'Johar Town','Lahore', 106 ,118;
EXEC InsertOrder 219,'2023-07-11 16:12:22', '2023-07-17 16:12:22', 'Cantt','Lahore', 27 ,25;
EXEC InsertOrder 220,'2024-03-16 12:11:13', '2024-04-06 12:11:13', 'Faisal Town','Lahore', 78 ,33;
EXEC InsertOrder 221,'2024-01-04 10:02:27', '2024-01-26 10:02:27', 'Askari','Lahore', 144 ,75;
EXEC InsertOrder 222,'2023-01-26 08:25:48', '2023-02-23 08:25:48', 'Model Town','Lahore', 15 ,84;
EXEC InsertOrder 223,'2023-08-28 06:43:41', '2023-09-21 06:43:41', 'Walled City','Lahore', 147 ,7;
EXEC InsertOrder 224,'2023-07-28 02:09:51', '2023-08-25 02:09:51', 'Samanabad','Lahore', 145 ,102;
EXEC InsertOrder 225,'2023-09-17 12:52:19', '2023-10-13 12:52:19', 'Mughalpura','Lahore', 83 ,131;
EXEC InsertOrder 226,'2023-09-05 19:06:54', '2023-10-01 19:06:54', 'Askari','Lahore', 6 ,24;
EXEC InsertOrder 227,'2024-04-24 06:16:03', '2024-05-13 06:16:03', 'Gari Shahu','Lahore', 133 ,144;
EXEC InsertOrder 228,'2023-01-13 06:13:44', '2023-01-22 06:13:44', 'Model Town','Lahore', 104 ,87;
EXEC InsertOrder 229,'2023-01-16 08:36:45', '2023-01-21 08:36:45', 'DHA','Lahore', 28 ,45;
EXEC InsertOrder 230,'2023-11-04 17:42:04', '2023-11-28 17:42:04', 'Mozang','Lahore', 139 ,94;
EXEC InsertOrder 231,'2023-05-30 02:38:47', '2023-06-05 02:38:47', 'DHA','Lahore', 106 ,15;
EXEC InsertOrder 232,'2024-02-07 00:47:18', '2024-02-09 00:47:18', 'Gari Shahu','Lahore', 65 ,140;
EXEC InsertOrder 233,'2023-08-05 03:45:53', '2023-08-12 03:45:53', 'Iqbal Town','Lahore', 6 ,93;
EXEC InsertOrder 234,'2024-03-01 17:15:16', '2024-03-29 17:15:16', 'Wapda Town','Lahore', 31 ,88;
EXEC InsertOrder 235,'2023-07-22 13:27:28', '2023-08-20 13:27:28', 'Faisal Town','Lahore', 40 ,52;
EXEC InsertOrder 236,'2023-08-28 01:25:36', '2023-08-30 01:25:36', 'Garden Town','Lahore', 66 ,28;
EXEC InsertOrder 237,'2023-12-09 23:06:37', '2023-12-27 23:06:37', 'DHA','Lahore', 142 ,19;
EXEC InsertOrder 238,'2023-07-08 20:39:31', '2023-07-24 20:39:31', 'Gari Shahu','Lahore', 127 ,2;
EXEC InsertOrder 239,'2024-01-25 13:22:00', '2024-02-23 13:22:00', 'Model Town','Lahore', 73 ,82;
EXEC InsertOrder 240,'2023-01-10 17:49:23', '2023-02-06 17:49:23', 'Bahria Town','Lahore', 61 ,149;
EXEC InsertOrder 241,'2023-09-06 02:18:51', '2023-10-06 02:18:51', 'Allama Iqbal Town','Lahore', 140 ,129;
EXEC InsertOrder 242,'2024-03-25 19:32:25', '2024-03-31 19:32:25', 'Askari','Lahore', 88 ,89;
EXEC InsertOrder 243,'2023-11-27 17:27:50', '2023-12-19 17:27:50', 'Mozang','Lahore', 68 ,2;
EXEC InsertOrder 244,'2023-03-07 05:01:05', '2023-03-18 05:01:05', 'Mozang','Lahore', 74 ,94;
EXEC InsertOrder 245,'2024-02-19 12:24:21', '2024-03-05 12:24:21', 'Shadman','Lahore', 19 ,145;
EXEC InsertOrder 246,'2023-03-10 02:17:54', '2023-04-07 02:17:54', 'Wapda Town','Lahore', 110 ,130;
EXEC InsertOrder 247,'2023-05-21 15:20:56', '2023-06-10 15:20:56', 'Model Town','Lahore', 91 ,50;
EXEC InsertOrder 248,'2023-07-22 03:06:30', '2023-08-17 03:06:30', 'Askari','Lahore', 2 ,142;
EXEC InsertOrder 249,'2023-05-14 13:34:24', '2023-05-30 13:34:24', 'Sabzazar','Lahore', 21 ,39;
EXEC InsertOrder 250,'2023-02-04 16:56:31', '2023-03-02 16:56:31', 'Iqbal Town','Lahore', 128 ,47;
EXEC InsertOrder 251,'2024-02-12 13:14:23', '2024-03-11 13:14:23', 'DHA','Lahore', 23 ,142;
EXEC InsertOrder 252,'2023-01-06 07:28:02', '2023-01-19 07:28:02', 'Johar Town','Lahore', 134 ,132;
EXEC InsertOrder 253,'2023-02-14 22:32:07', '2023-03-08 22:32:07', 'Johar Town','Lahore', 117 ,24;
EXEC InsertOrder 254,'2024-03-01 23:10:56', '2024-03-21 23:10:56', 'Iqbal Town','Lahore', 129 ,144;
EXEC InsertOrder 255,'2023-03-28 17:47:27', '2023-04-25 17:47:27', 'Mughalpura','Lahore', 117 ,147;
EXEC InsertOrder 256,'2024-01-10 09:24:06', '2024-02-08 09:24:06', 'Ravi Road','Lahore', 90 ,46;
EXEC InsertOrder 257,'2023-10-03 07:49:47', '2023-10-08 07:49:47', 'Gari Shahu','Lahore', 23 ,94;
EXEC InsertOrder 258,'2023-01-27 22:21:09', '2023-02-02 22:21:09', 'Shadman','Lahore', 149 ,102;
EXEC InsertOrder 259,'2023-03-23 11:11:14', '2023-04-04 11:11:14', 'Mozang','Lahore', 85 ,121;
EXEC InsertOrder 260,'2023-08-26 05:43:02', '2023-09-03 05:43:02', 'Model Town','Lahore', 56 ,98;
EXEC InsertOrder 261,'2024-01-24 23:01:57', '2024-02-08 23:01:57', 'Samanabad','Lahore', 4 ,5;
EXEC InsertOrder 262,'2023-02-06 22:56:56', '2023-02-10 22:56:56', 'Faisal Town','Lahore', 135 ,140;
EXEC InsertOrder 263,'2023-10-03 18:04:51', '2023-10-22 18:04:51', 'Cantt','Lahore', 96 ,82;
EXEC InsertOrder 264,'2024-03-05 02:39:47', '2024-03-12 02:39:47', 'Cantt','Lahore', 38 ,5;
EXEC InsertOrder 265,'2023-07-03 13:08:00', '2023-07-24 13:08:00', 'Iqbal Town','Lahore', 83 ,90;
EXEC InsertOrder 266,'2023-08-27 15:28:43', '2023-09-14 15:28:43', 'Mozang','Lahore', 57 ,100;
EXEC InsertOrder 267,'2024-01-16 16:21:52', '2024-01-19 16:21:52', 'Ravi Road','Lahore', 117 ,4;
EXEC InsertOrder 268,'2023-10-04 08:04:03', '2023-10-28 08:04:03', 'Model Town','Lahore', 37 ,103;
EXEC InsertOrder 269,'2023-11-30 08:58:13', '2023-12-27 08:58:13', 'Samanabad','Lahore', 16 ,96;
EXEC InsertOrder 270,'2024-01-04 21:50:13', '2024-01-23 21:50:13', 'Allama Iqbal Town','Lahore', 78 ,23;
EXEC InsertOrder 271,'2023-02-04 02:45:32', '2023-02-25 02:45:32', 'Johar Town','Lahore', 140 ,21;
EXEC InsertOrder 272,'2023-12-05 07:11:36', '2023-12-14 07:11:36', 'Sabzazar','Lahore', 111 ,52;
EXEC InsertOrder 273,'2023-08-17 13:27:20', '2023-08-21 13:27:20', 'Wapda Town','Lahore', 146 ,29;
EXEC InsertOrder 274,'2024-01-24 19:07:07', '2024-02-16 19:07:07', 'Cantt','Lahore', 139 ,140;
EXEC InsertOrder 275,'2023-04-27 08:43:28', '2023-05-08 08:43:28', 'Iqbal Town','Lahore', 117 ,92;
EXEC InsertOrder 276,'2023-11-05 16:00:49', '2023-11-25 16:00:49', 'Faisal Town','Lahore', 121 ,21;
EXEC InsertOrder 277,'2024-01-29 08:03:12', '2024-01-31 08:03:12', 'Bahria Town','Lahore', 134 ,41;
EXEC InsertOrder 278,'2023-02-26 12:34:09', '2023-03-03 12:34:09', 'Mughalpura','Lahore', 114 ,92;
EXEC InsertOrder 279,'2023-04-20 06:30:06', '2023-05-16 06:30:06', 'Garden Town','Lahore', 105 ,103;
EXEC InsertOrder 280,'2023-06-05 12:03:31', '2023-06-29 12:03:31', 'Faisal Town','Lahore', 78 ,135;
EXEC InsertOrder 281,'2023-05-28 19:24:42', '2023-06-23 19:24:42', 'Cantt','Lahore', 125 ,138;
EXEC InsertOrder 282,'2023-01-05 20:25:42', '2023-01-11 20:25:42', 'Mughalpura','Lahore', 13 ,9;
EXEC InsertOrder 283,'2023-10-21 02:44:03', '2023-11-05 02:44:03', 'Wapda Town','Lahore', 37 ,126;
EXEC InsertOrder 284,'2024-01-11 07:35:36', '2024-02-01 07:35:36', 'Gulberg','Lahore', 27 ,66;
EXEC InsertOrder 285,'2023-10-12 06:40:30', '2023-10-30 06:40:30', 'Cantt','Lahore', 61 ,127;
EXEC InsertOrder 286,'2023-09-26 17:53:33', '2023-10-07 17:53:33', 'Sabzazar','Lahore', 125 ,129;
EXEC InsertOrder 287,'2023-05-06 16:25:39', '2023-05-15 16:25:39', 'Wapda Town','Lahore', 44 ,19;
EXEC InsertOrder 288,'2023-02-13 18:22:53', '2023-03-05 18:22:53', 'Walled City','Lahore', 15 ,131;
EXEC InsertOrder 289,'2023-06-11 04:31:53', '2023-06-20 04:31:53', 'Sabzazar','Lahore', 23 ,30;
EXEC InsertOrder 290,'2023-06-21 12:24:02', '2023-07-16 12:24:02', 'Wapda Town','Lahore', 4 ,124;
EXEC InsertOrder 291,'2024-03-22 19:12:34', '2024-04-14 19:12:34', 'Mozang','Lahore', 78 ,73;
EXEC InsertOrder 292,'2023-04-21 23:52:46', '2023-04-24 23:52:46', 'DHA','Lahore', 22 ,125;
EXEC InsertOrder 293,'2023-06-07 04:38:11', '2023-06-21 04:38:11', 'Mughalpura','Lahore', 109 ,136;
EXEC InsertOrder 294,'2024-01-05 02:29:23', '2024-01-16 02:29:23', 'Johar Town','Lahore', 117 ,86;
EXEC InsertOrder 295,'2023-10-16 21:53:05', '2023-11-13 21:53:05', 'Garden Town','Lahore', 87 ,148;
EXEC InsertOrder 296,'2023-01-05 02:09:43', '2023-01-12 02:09:43', 'Shadman','Lahore', 115 ,128;
EXEC InsertOrder 297,'2024-02-02 12:01:25', '2024-02-06 12:01:25', 'Model Town','Lahore', 69 ,59;
EXEC InsertOrder 298,'2024-04-26 01:06:24', '2024-05-03 01:06:24', 'Johar Town','Lahore', 78 ,107;
EXEC InsertOrder 299,'2024-01-19 20:54:48', '2024-02-02 20:54:48', 'Model Town','Lahore', 124 ,8;
EXEC InsertOrder 300,'2023-02-23 18:41:31', '2023-03-21 18:41:31', 'Cantt','Lahore', 86 ,118;
EXEC InsertOrder 301,'2023-10-11 01:29:06', '2023-10-23 01:29:06', 'Mozang','Lahore', 83 ,90;
EXEC InsertOrder 302,'2023-06-07 18:36:46', '2023-06-27 18:36:46', 'Gari Shahu','Lahore', 80 ,54;
EXEC InsertOrder 303,'2023-01-05 13:14:09', '2023-01-17 13:14:09', 'Bahria Town','Lahore', 125 ,6;
EXEC InsertOrder 304,'2023-11-18 14:11:57', '2023-11-29 14:11:57', 'Mughalpura','Lahore', 30 ,95;
EXEC InsertOrder 305,'2023-07-06 17:46:04', '2023-07-25 17:46:04', 'Allama Iqbal Town','Lahore', 3 ,67;
EXEC InsertOrder 306,'2024-01-13 02:04:44', '2024-01-16 02:04:44', 'Gari Shahu','Lahore', 66 ,36;
EXEC InsertOrder 307,'2024-03-16 18:28:13', '2024-04-12 18:28:13', 'Model Town','Lahore', 15 ,52;
EXEC InsertOrder 308,'2023-05-22 14:23:43', '2023-05-25 14:23:43', 'Sabzazar','Lahore', 55 ,136;
EXEC InsertOrder 309,'2024-02-05 07:36:50', '2024-03-03 07:36:50', 'Gulberg','Lahore', 11 ,86;
EXEC InsertOrder 310,'2023-12-06 01:07:23', '2023-12-16 01:07:23', 'Garden Town','Lahore', 67 ,137;
EXEC InsertOrder 311,'2023-08-13 07:12:40', '2023-08-16 07:12:40', 'Gari Shahu','Lahore', 72 ,37;
EXEC InsertOrder 312,'2024-01-28 10:14:05', '2024-02-11 10:14:05', 'Ravi Road','Lahore', 24 ,145;
EXEC InsertOrder 313,'2023-08-27 14:58:25', '2023-08-30 14:58:25', 'Faisal Town','Lahore', 81 ,114;
EXEC InsertOrder 314,'2023-07-31 10:56:02', '2023-08-18 10:56:02', 'Ravi Road','Lahore', 57 ,81;
EXEC InsertOrder 315,'2023-11-29 16:00:46', '2023-12-15 16:00:46', 'DHA','Lahore', 110 ,1;
EXEC InsertOrder 316,'2024-04-04 04:23:10', '2024-04-09 04:23:10', 'Mughalpura','Lahore', 9 ,113;
EXEC InsertOrder 317,'2023-12-19 18:58:07', '2023-12-31 18:58:07', 'Iqbal Town','Lahore', 6 ,69;
EXEC InsertOrder 318,'2023-01-25 16:55:29', '2023-02-08 16:55:29', 'Johar Town','Lahore', 1 ,66;
EXEC InsertOrder 319,'2023-09-21 12:26:57', '2023-10-21 12:26:57', 'Gulberg','Lahore', 105 ,98;
EXEC InsertOrder 320,'2023-01-25 01:29:54', '2023-02-03 01:29:54', 'DHA','Lahore', 87 ,55;
EXEC InsertOrder 321,'2024-01-08 16:54:42', '2024-01-18 16:54:42', 'Johar Town','Lahore', 143 ,90;
EXEC InsertOrder 322,'2023-01-26 12:23:23', '2023-02-18 12:23:23', 'Cantt','Lahore', 100 ,42;
EXEC InsertOrder 323,'2024-04-13 02:22:46', '2024-04-18 02:22:46', 'Shadman','Lahore', 77 ,104;
EXEC InsertOrder 324,'2023-05-11 15:03:10', '2023-05-26 15:03:10', 'Wapda Town','Lahore', 131 ,116;
EXEC InsertOrder 325,'2023-04-17 02:08:26', '2023-04-24 02:08:26', 'Johar Town','Lahore', 12 ,4;
EXEC InsertOrder 326,'2023-12-12 18:05:15', '2024-01-04 18:05:15', 'Gulberg','Lahore', 105 ,90;
EXEC InsertOrder 327,'2023-05-14 01:55:21', '2023-05-19 01:55:21', 'Samanabad','Lahore', 50 ,147;
EXEC InsertOrder 328,'2023-03-17 05:04:42', '2023-03-26 05:04:42', 'Model Town','Lahore', 68 ,48;
EXEC InsertOrder 329,'2023-06-06 06:44:11', '2023-06-24 06:44:11', 'DHA','Lahore', 16 ,50;
EXEC InsertOrder 330,'2023-12-04 11:11:31', '2023-12-15 11:11:31', 'Cantt','Lahore', 20 ,43;
EXEC InsertOrder 331,'2024-01-14 07:20:12', '2024-01-18 07:20:12', 'DHA','Lahore', 45 ,50;
EXEC InsertOrder 332,'2023-03-24 01:46:58', '2023-03-31 01:46:58', 'Mughalpura','Lahore', 44 ,34;
EXEC InsertOrder 333,'2024-03-25 20:44:51', '2024-04-05 20:44:51', 'Faisal Town','Lahore', 80 ,57;
EXEC InsertOrder 334,'2023-12-22 07:00:13', '2024-01-11 07:00:13', 'Samanabad','Lahore', 56 ,36;
EXEC InsertOrder 335,'2023-04-02 10:12:03', '2023-04-11 10:12:03', 'Wapda Town','Lahore', 60 ,111;
EXEC InsertOrder 336,'2024-02-21 00:38:12', '2024-02-24 00:38:12', 'Mozang','Lahore', 127 ,84;
EXEC InsertOrder 337,'2023-03-02 19:09:43', '2023-03-14 19:09:43', 'Garden Town','Lahore', 8 ,22;
EXEC InsertOrder 338,'2023-02-21 08:43:06', '2023-03-13 08:43:06', 'Walled City','Lahore', 133 ,37;
EXEC InsertOrder 339,'2023-10-19 05:30:57', '2023-10-28 05:30:57', 'Cantt','Lahore', 35 ,56;
EXEC InsertOrder 340,'2023-08-03 09:02:04', '2023-08-16 09:02:04', 'Faisal Town','Lahore', 57 ,96;
EXEC InsertOrder 341,'2023-12-29 12:03:39', '2024-01-05 12:03:39', 'Wapda Town','Lahore', 36 ,107;
EXEC InsertOrder 342,'2024-02-03 05:39:47', '2024-02-29 05:39:47', 'Johar Town','Lahore', 97 ,122;
EXEC InsertOrder 343,'2023-08-15 03:29:58', '2023-09-04 03:29:58', 'Gulberg','Lahore', 42 ,39;
EXEC InsertOrder 344,'2023-01-27 08:32:33', '2023-02-16 08:32:33', 'Iqbal Town','Lahore', 129 ,143;
EXEC InsertOrder 345,'2023-04-21 23:27:48', '2023-04-24 23:27:48', 'Faisal Town','Lahore', 68 ,52;
EXEC InsertOrder 346,'2023-09-01 13:28:15', '2023-09-10 13:28:15', 'Allama Iqbal Town','Lahore', 60 ,147;
EXEC InsertOrder 347,'2023-01-05 19:52:05', '2023-01-07 19:52:05', 'Cantt','Lahore', 37 ,116;
EXEC InsertOrder 348,'2023-11-19 03:43:17', '2023-12-17 03:43:17', 'Bahria Town','Lahore', 45 ,98;
EXEC InsertOrder 349,'2024-02-25 19:30:49', '2024-03-09 19:30:49', 'Faisal Town','Lahore', 35 ,118;
EXEC InsertOrder 350,'2023-03-01 06:24:52', '2023-03-06 06:24:52', 'Iqbal Town','Lahore', 106 ,117;
EXEC InsertOrder 351,'2024-02-29 05:14:35', '2024-03-16 05:14:35', 'Gari Shahu','Lahore', 60 ,135;
EXEC InsertOrder 352,'2024-04-08 14:54:24', '2024-04-22 14:54:24', 'Garden Town','Lahore', 30 ,61;
EXEC InsertOrder 353,'2024-02-02 10:21:45', '2024-02-17 10:21:45', 'Mozang','Lahore', 126 ,109;
EXEC InsertOrder 354,'2023-04-26 00:11:31', '2023-05-11 00:11:31', 'Cantt','Lahore', 119 ,73;
EXEC InsertOrder 355,'2023-07-18 22:20:19', '2023-07-25 22:20:19', 'Gari Shahu','Lahore', 121 ,93;
EXEC InsertOrder 356,'2023-06-29 10:59:29', '2023-07-02 10:59:29', 'Model Town','Lahore', 67 ,81;
EXEC InsertOrder 357,'2023-10-15 13:43:18', '2023-10-29 13:43:18', 'Faisal Town','Lahore', 131 ,94;
EXEC InsertOrder 358,'2023-08-05 02:17:10', '2023-09-04 02:17:10', 'Ravi Road','Lahore', 120 ,140;
EXEC InsertOrder 359,'2023-07-29 12:45:00', '2023-08-12 12:45:00', 'Faisal Town','Lahore', 7 ,22;
EXEC InsertOrder 360,'2024-01-12 00:40:39', '2024-01-13 00:40:39', 'Gulberg','Lahore', 10 ,45;
EXEC InsertOrder 361,'2023-09-12 09:14:23', '2023-09-13 09:14:23', 'Faisal Town','Lahore', 93 ,51;
EXEC InsertOrder 362,'2023-02-02 15:52:54', '2023-02-04 15:52:54', 'Cantt','Lahore', 23 ,109;
EXEC InsertOrder 363,'2023-01-08 06:43:39', '2023-01-20 06:43:39', 'Allama Iqbal Town','Lahore', 100 ,96;
EXEC InsertOrder 364,'2023-09-27 00:39:57', '2023-10-10 00:39:57', 'Faisal Town','Lahore', 22 ,46;
EXEC InsertOrder 365,'2023-02-23 10:52:15', '2023-02-27 10:52:15', 'Ravi Road','Lahore', 61 ,80;
EXEC InsertOrder 366,'2023-11-14 12:31:37', '2023-12-06 12:31:37', 'Walled City','Lahore', 71 ,61;
EXEC InsertOrder 367,'2023-12-04 04:38:55', '2023-12-16 04:38:55', 'Cantt','Lahore', 27 ,4;
EXEC InsertOrder 368,'2023-12-06 17:32:14', '2023-12-20 17:32:14', 'Mozang','Lahore', 91 ,7;
EXEC InsertOrder 369,'2024-04-18 11:57:16', '2024-04-20 11:57:16', 'Model Town','Lahore', 17 ,47;
EXEC InsertOrder 370,'2024-04-26 14:24:43', '2024-05-08 14:24:43', 'Bahria Town','Lahore', 148 ,132;
EXEC InsertOrder 371,'2023-06-20 09:31:23', '2023-06-27 09:31:23', 'Samanabad','Lahore', 145 ,112;
EXEC InsertOrder 372,'2023-03-05 00:21:44', '2023-03-27 00:21:44', 'Bahria Town','Lahore', 69 ,54;
EXEC InsertOrder 373,'2023-05-01 12:18:44', '2023-05-09 12:18:44', 'Iqbal Town','Lahore', 150 ,148;
EXEC InsertOrder 374,'2023-05-19 09:48:26', '2023-05-31 09:48:26', 'Gari Shahu','Lahore', 29 ,72;
EXEC InsertOrder 375,'2023-05-23 19:22:53', '2023-05-25 19:22:53', 'Gulberg','Lahore', 131 ,13;
EXEC InsertOrder 376,'2023-11-10 17:01:35', '2023-11-30 17:01:35', 'Mughalpura','Lahore', 110 ,18;
EXEC InsertOrder 377,'2023-06-03 16:16:06', '2023-06-06 16:16:06', 'Askari','Lahore', 28 ,10;
EXEC InsertOrder 378,'2023-10-14 06:39:29', '2023-11-06 06:39:29', 'Model Town','Lahore', 91 ,63;
EXEC InsertOrder 379,'2023-06-09 14:47:34', '2023-06-24 14:47:34', 'Shadman','Lahore', 67 ,67;
EXEC InsertOrder 380,'2024-04-25 05:48:51', '2024-05-17 05:48:51', 'Walled City','Lahore', 32 ,73;
EXEC InsertOrder 381,'2023-08-11 01:56:36', '2023-08-24 01:56:36', 'Sabzazar','Lahore', 80 ,1;
EXEC InsertOrder 382,'2023-09-02 23:59:56', '2023-09-21 23:59:56', 'Cantt','Lahore', 1 ,111;
EXEC InsertOrder 383,'2023-04-20 13:26:55', '2023-05-10 13:26:55', 'Walled City','Lahore', 18 ,15;
EXEC InsertOrder 384,'2024-01-26 01:28:04', '2024-02-23 01:28:04', 'Shadman','Lahore', 99 ,31;
EXEC InsertOrder 385,'2023-06-03 05:39:01', '2023-06-19 05:39:01', 'DHA','Lahore', 27 ,82;
EXEC InsertOrder 386,'2023-08-09 03:34:20', '2023-08-15 03:34:20', 'Model Town','Lahore', 149 ,48;
EXEC InsertOrder 387,'2023-03-19 15:38:58', '2023-04-04 15:38:58', 'Mughalpura','Lahore', 58 ,42;
EXEC InsertOrder 388,'2024-02-08 17:08:17', '2024-02-26 17:08:17', 'Iqbal Town','Lahore', 72 ,40;
EXEC InsertOrder 389,'2024-04-13 12:11:44', '2024-05-13 12:11:44', 'Shadman','Lahore', 4 ,105;
EXEC InsertOrder 390,'2024-02-05 12:07:28', '2024-02-08 12:07:28', 'Cantt','Lahore', 88 ,51;
EXEC InsertOrder 391,'2024-03-09 22:03:22', '2024-04-01 22:03:22', 'Gulberg','Lahore', 150 ,26;
EXEC InsertOrder 392,'2023-04-22 23:25:38', '2023-05-18 23:25:38', 'Askari','Lahore', 121 ,10;
EXEC InsertOrder 393,'2023-10-04 05:02:12', '2023-10-05 05:02:12', 'Allama Iqbal Town','Lahore', 133 ,67;
EXEC InsertOrder 394,'2024-04-10 16:01:16', '2024-04-22 16:01:16', 'Gulberg','Lahore', 86 ,61;
EXEC InsertOrder 395,'2023-11-09 13:45:36', '2023-11-13 13:45:36', 'Iqbal Town','Lahore', 115 ,143;
EXEC InsertOrder 396,'2023-02-13 07:32:47', '2023-02-15 07:32:47', 'Askari','Lahore', 81 ,18;
EXEC InsertOrder 397,'2023-04-15 12:54:44', '2023-04-28 12:54:44', 'Allama Iqbal Town','Lahore', 43 ,54;
EXEC InsertOrder 398,'2023-09-01 21:17:59', '2023-09-09 21:17:59', 'Walled City','Lahore', 21 ,27;
EXEC InsertOrder 399,'2023-01-20 21:11:24', '2023-02-03 21:11:24', 'DHA','Lahore', 9 ,14;
EXEC InsertOrder 400,'2023-04-08 15:44:47', '2023-04-30 15:44:47', 'Bahria Town','Lahore', 51 ,92;
EXEC InsertOrder 401,'2023-10-06 00:23:29', '2023-10-26 00:23:29', 'Wapda Town','Lahore', 62 ,78;
EXEC InsertOrder 402,'2023-02-03 17:26:14', '2023-02-17 17:26:14', 'Bahria Town','Lahore', 148 ,52;
EXEC InsertOrder 403,'2023-10-17 21:43:14', '2023-10-28 21:43:14', 'Samanabad','Lahore', 106 ,7;
EXEC InsertOrder 404,'2024-01-15 18:22:29', '2024-01-30 18:22:29', 'Askari','Lahore', 139 ,130;
EXEC InsertOrder 405,'2023-12-16 02:00:50', '2024-01-05 02:00:50', 'Cantt','Lahore', 18 ,30;
EXEC InsertOrder 406,'2024-03-23 12:58:56', '2024-04-16 12:58:56', 'Samanabad','Lahore', 74 ,120;
EXEC InsertOrder 407,'2023-01-11 21:28:00', '2023-01-25 21:28:00', 'Wapda Town','Lahore', 5 ,48;
EXEC InsertOrder 408,'2023-02-04 22:52:00', '2023-02-27 22:52:00', 'Faisal Town','Lahore', 66 ,99;
EXEC InsertOrder 409,'2024-04-05 00:47:01', '2024-04-25 00:47:01', 'Samanabad','Lahore', 64 ,50;
EXEC InsertOrder 410,'2023-03-04 14:10:59', '2023-04-01 14:10:59', 'Bahria Town','Lahore', 42 ,138;
EXEC InsertOrder 411,'2024-02-16 02:24:35', '2024-03-13 02:24:35', 'Gari Shahu','Lahore', 123 ,24;
EXEC InsertOrder 412,'2023-05-28 11:33:17', '2023-06-09 11:33:17', 'DHA','Lahore', 61 ,38;
EXEC InsertOrder 413,'2023-04-12 20:11:53', '2023-05-09 20:11:53', 'Samanabad','Lahore', 60 ,60;
EXEC InsertOrder 414,'2023-10-07 15:41:53', '2023-10-26 15:41:53', 'Samanabad','Lahore', 75 ,111;
EXEC InsertOrder 415,'2023-10-06 18:47:02', '2023-10-28 18:47:02', 'Iqbal Town','Lahore', 11 ,27;
EXEC InsertOrder 416,'2023-10-04 19:17:30', '2023-10-25 19:17:30', 'Iqbal Town','Lahore', 72 ,140;
EXEC InsertOrder 417,'2023-04-15 10:42:34', '2023-05-03 10:42:34', 'Model Town','Lahore', 90 ,55;
EXEC InsertOrder 418,'2024-01-26 14:23:01', '2024-02-15 14:23:01', 'Garden Town','Lahore', 106 ,49;
EXEC InsertOrder 419,'2024-03-22 18:53:39', '2024-04-13 18:53:39', 'Garden Town','Lahore', 53 ,33;
EXEC InsertOrder 420,'2023-07-01 11:29:45', '2023-07-12 11:29:45', 'Allama Iqbal Town','Lahore', 45 ,70;
EXEC InsertOrder 421,'2023-07-15 11:23:39', '2023-07-23 11:23:39', 'Gari Shahu','Lahore', 41 ,136;
EXEC InsertOrder 422,'2023-11-20 04:17:28', '2023-12-12 04:17:28', 'Johar Town','Lahore', 148 ,49;
EXEC InsertOrder 423,'2023-09-01 12:38:13', '2023-09-16 12:38:13', 'Iqbal Town','Lahore', 70 ,14;
EXEC InsertOrder 424,'2023-10-03 04:36:38', '2023-10-28 04:36:38', 'Mughalpura','Lahore', 46 ,108;
EXEC InsertOrder 425,'2023-05-30 13:03:49', '2023-06-24 13:03:49', 'Cantt','Lahore', 94 ,54;
EXEC InsertOrder 426,'2023-11-11 17:25:00', '2023-11-19 17:25:00', 'Iqbal Town','Lahore', 28 ,27;
EXEC InsertOrder 427,'2023-04-13 00:36:33', '2023-04-27 00:36:33', 'DHA','Lahore', 136 ,17;
EXEC InsertOrder 428,'2023-12-12 20:03:56', '2024-01-04 20:03:56', 'Askari','Lahore', 34 ,91;
EXEC InsertOrder 429,'2023-09-07 20:02:58', '2023-09-26 20:02:58', 'Gari Shahu','Lahore', 33 ,58;
EXEC InsertOrder 430,'2023-01-10 08:16:43', '2023-02-07 08:16:43', 'Faisal Town','Lahore', 112 ,86;
EXEC InsertOrder 431,'2023-07-13 11:15:51', '2023-08-06 11:15:51', 'Gari Shahu','Lahore', 26 ,134;
EXEC InsertOrder 432,'2023-07-25 06:27:41', '2023-08-08 06:27:41', 'Gulberg','Lahore', 9 ,85;
EXEC InsertOrder 433,'2024-02-01 03:23:28', '2024-02-23 03:23:28', 'Johar Town','Lahore', 22 ,20;
EXEC InsertOrder 434,'2024-01-26 07:14:06', '2024-02-20 07:14:06', 'Model Town','Lahore', 135 ,46;
EXEC InsertOrder 435,'2024-03-31 22:50:03', '2024-04-18 22:50:03', 'Sabzazar','Lahore', 81 ,40;
EXEC InsertOrder 436,'2023-05-25 05:47:05', '2023-06-06 05:47:05', 'Model Town','Lahore', 108 ,93;
EXEC InsertOrder 437,'2023-07-09 08:52:40', '2023-07-10 08:52:40', 'DHA','Lahore', 65 ,113;
EXEC InsertOrder 438,'2023-01-23 06:02:44', '2023-02-11 06:02:44', 'Ravi Road','Lahore', 127 ,132;
EXEC InsertOrder 439,'2024-02-01 22:20:20', '2024-02-22 22:20:20', 'Allama Iqbal Town','Lahore', 120 ,144;
EXEC InsertOrder 440,'2023-11-02 05:05:49', '2023-11-21 05:05:49', 'Allama Iqbal Town','Lahore', 47 ,3;
EXEC InsertOrder 441,'2023-06-14 23:49:10', '2023-07-07 23:49:10', 'Wapda Town','Lahore', 87 ,38;
EXEC InsertOrder 442,'2024-04-22 06:42:03', '2024-05-18 06:42:03', 'Askari','Lahore', 137 ,134;
EXEC InsertOrder 443,'2024-01-02 20:41:42', '2024-01-21 20:41:42', 'DHA','Lahore', 16 ,114;
EXEC InsertOrder 444,'2023-04-25 16:10:31', '2023-05-16 16:10:31', 'Walled City','Lahore', 8 ,136;
EXEC InsertOrder 445,'2023-06-09 04:09:04', '2023-06-19 04:09:04', 'Mughalpura','Lahore', 111 ,147;
EXEC InsertOrder 446,'2023-10-10 02:00:31', '2023-10-16 02:00:31', 'Iqbal Town','Lahore', 118 ,11;
EXEC InsertOrder 447,'2023-03-28 03:58:49', '2023-04-13 03:58:49', 'Walled City','Lahore', 129 ,97;
EXEC InsertOrder 448,'2024-03-30 15:58:38', '2024-04-04 15:58:38', 'Cantt','Lahore', 131 ,49;
EXEC InsertOrder 449,'2023-09-27 08:28:22', '2023-09-30 08:28:22', 'Mughalpura','Lahore', 135 ,10;
EXEC InsertOrder 450,'2023-04-03 07:55:54', '2023-04-06 07:55:54', 'Johar Town','Lahore', 75 ,93;
EXEC InsertOrder 451,'2024-03-21 08:59:22', '2024-03-25 08:59:22', 'Shadman','Lahore', 101 ,99;
EXEC InsertOrder 452,'2023-01-20 23:11:24', '2023-01-28 23:11:24', 'Askari','Lahore', 108 ,120;
EXEC InsertOrder 453,'2023-11-25 03:28:53', '2023-12-09 03:28:53', 'Askari','Lahore', 150 ,24;
EXEC InsertOrder 454,'2023-03-29 05:07:31', '2023-04-14 05:07:31', 'Samanabad','Lahore', 136 ,47;
EXEC InsertOrder 455,'2023-03-27 21:24:54', '2023-04-21 21:24:54', 'DHA','Lahore', 26 ,138;
EXEC InsertOrder 456,'2023-12-08 16:45:15', '2023-12-23 16:45:15', 'Gari Shahu','Lahore', 2 ,87;
EXEC InsertOrder 457,'2024-04-05 21:35:40', '2024-04-19 21:35:40', 'Wapda Town','Lahore', 65 ,78;
EXEC InsertOrder 458,'2023-10-22 20:18:24', '2023-11-05 20:18:24', 'Sabzazar','Lahore', 106 ,63;
EXEC InsertOrder 459,'2023-07-19 10:50:40', '2023-08-10 10:50:40', 'Wapda Town','Lahore', 121 ,131;
EXEC InsertOrder 460,'2023-06-25 20:37:56', '2023-07-11 20:37:56', 'Model Town','Lahore', 65 ,5;
EXEC InsertOrder 461,'2024-04-25 11:07:10', '2024-05-08 11:07:10', 'Cantt','Lahore', 131 ,116;
EXEC InsertOrder 462,'2023-04-10 20:36:00', '2023-04-12 20:36:00', 'Ravi Road','Lahore', 95 ,60;
EXEC InsertOrder 463,'2023-08-27 09:25:04', '2023-09-07 09:25:04', 'Johar Town','Lahore', 74 ,116;
EXEC InsertOrder 464,'2023-04-12 22:16:04', '2023-05-05 22:16:04', 'Mughalpura','Lahore', 52 ,76;
EXEC InsertOrder 465,'2023-05-10 01:10:29', '2023-05-19 01:10:29', 'Johar Town','Lahore', 139 ,2;
EXEC InsertOrder 466,'2023-08-18 23:14:08', '2023-08-26 23:14:08', 'Allama Iqbal Town','Lahore', 104 ,130;
EXEC InsertOrder 467,'2023-01-06 01:10:01', '2023-01-29 01:10:01', 'Allama Iqbal Town','Lahore', 66 ,71;
EXEC InsertOrder 468,'2023-08-03 15:25:45', '2023-08-07 15:25:45', 'Shadman','Lahore', 25 ,145;
EXEC InsertOrder 469,'2023-04-24 07:45:40', '2023-05-16 07:45:40', 'Shadman','Lahore', 126 ,37;
EXEC InsertOrder 470,'2023-03-28 11:59:20', '2023-04-19 11:59:20', 'Shadman','Lahore', 47 ,41;
EXEC InsertOrder 471,'2023-07-08 19:23:51', '2023-07-09 19:23:51', 'Bahria Town','Lahore', 98 ,100;
EXEC InsertOrder 472,'2024-03-26 22:55:39', '2024-04-23 22:55:39', 'Samanabad','Lahore', 55 ,111;
EXEC InsertOrder 473,'2023-01-13 02:14:32', '2023-01-14 02:14:32', 'Samanabad','Lahore', 77 ,35;
EXEC InsertOrder 474,'2024-01-23 00:35:07', '2024-02-08 00:35:07', 'Mozang','Lahore', 20 ,129;
EXEC InsertOrder 475,'2023-04-07 20:50:07', '2023-04-21 20:50:07', 'Askari','Lahore', 10 ,124;
EXEC InsertOrder 476,'2023-06-07 10:39:46', '2023-06-11 10:39:46', 'Mughalpura','Lahore', 32 ,119;
EXEC InsertOrder 477,'2023-10-13 16:06:01', '2023-10-15 16:06:01', 'Samanabad','Lahore', 97 ,4;
EXEC InsertOrder 478,'2023-01-03 00:27:13', '2023-01-17 00:27:13', 'Allama Iqbal Town','Lahore', 108 ,44;
EXEC InsertOrder 479,'2023-07-24 15:52:49', '2023-08-01 15:52:49', 'Gulberg','Lahore', 122 ,72;
EXEC InsertOrder 480,'2023-11-13 07:40:07', '2023-12-04 07:40:07', 'Gari Shahu','Lahore', 37 ,68;
EXEC InsertOrder 481,'2023-07-15 19:35:32', '2023-07-16 19:35:32', 'Gari Shahu','Lahore', 22 ,47;
EXEC InsertOrder 482,'2024-01-25 19:09:56', '2024-02-04 19:09:56', 'Iqbal Town','Lahore', 106 ,5;
EXEC InsertOrder 483,'2023-05-18 14:41:54', '2023-05-29 14:41:54', 'Wapda Town','Lahore', 108 ,103;
EXEC InsertOrder 484,'2023-02-14 13:04:48', '2023-03-01 13:04:48', 'Model Town','Lahore', 23 ,121;
EXEC InsertOrder 485,'2023-07-20 22:35:08', '2023-07-25 22:35:08', 'Walled City','Lahore', 82 ,30;
EXEC InsertOrder 486,'2023-08-19 08:43:05', '2023-09-12 08:43:05', 'Faisal Town','Lahore', 77 ,65;
EXEC InsertOrder 487,'2023-10-25 21:13:14', '2023-11-10 21:13:14', 'Allama Iqbal Town','Lahore', 76 ,105;
EXEC InsertOrder 488,'2023-12-11 09:37:19', '2023-12-22 09:37:19', 'Gulberg','Lahore', 133 ,74;
EXEC InsertOrder 489,'2023-06-09 19:55:02', '2023-06-17 19:55:02', 'Shadman','Lahore', 6 ,55;
EXEC InsertOrder 490,'2024-02-23 16:55:12', '2024-02-28 16:55:12', 'Sabzazar','Lahore', 6 ,116;
EXEC InsertOrder 491,'2024-01-15 05:37:06', '2024-02-13 05:37:06', 'Bahria Town','Lahore', 29 ,150;
EXEC InsertOrder 492,'2023-07-15 06:06:13', '2023-08-11 06:06:13', 'Gulberg','Lahore', 57 ,40;
EXEC InsertOrder 493,'2023-04-16 04:51:19', '2023-04-26 04:51:19', 'Iqbal Town','Lahore', 129 ,10;
EXEC InsertOrder 494,'2023-10-17 10:23:56', '2023-11-04 10:23:56', 'Wapda Town','Lahore', 64 ,100;
EXEC InsertOrder 495,'2023-09-11 21:32:25', '2023-09-19 21:32:25', 'Mughalpura','Lahore', 80 ,131;
EXEC InsertOrder 496,'2023-01-01 00:10:42', '2023-01-21 00:10:42', 'Model Town','Lahore', 2 ,4;
EXEC InsertOrder 497,'2023-11-07 09:11:24', '2023-11-11 09:11:24', 'Askari','Lahore', 87 ,15;
EXEC InsertOrder 498,'2023-08-24 07:00:27', '2023-08-25 07:00:27', 'Shadman','Lahore', 37 ,48;
EXEC InsertOrder 499,'2023-10-28 00:16:16', '2023-11-16 00:16:16', 'Johar Town','Lahore', 65 ,57;
EXEC InsertOrder 500,'2024-04-09 07:58:23', '2024-05-05 07:58:23', 'Mughalpura','Lahore', 81 ,146;
EXEC InsertOrder 501,'2023-11-24 08:41:42', '2023-12-14 08:41:42', 'Ravi Road','Lahore', 150 ,140;
EXEC InsertOrder 502,'2023-07-09 07:35:43', '2023-08-02 07:35:43', 'Bahria Town','Lahore', 46 ,67;
EXEC InsertOrder 503,'2023-09-09 20:12:50', '2023-09-10 20:12:50', 'Wapda Town','Lahore', 110 ,7;
EXEC InsertOrder 504,'2023-06-15 16:25:26', '2023-06-18 16:25:26', 'Allama Iqbal Town','Lahore', 129 ,96;
EXEC InsertOrder 505,'2024-02-27 22:33:46', '2024-03-02 22:33:46', 'Bahria Town','Lahore', 7 ,3;
EXEC InsertOrder 506,'2024-01-09 05:15:05', '2024-01-23 05:15:05', 'Cantt','Lahore', 128 ,8;
EXEC InsertOrder 507,'2023-04-29 08:19:26', '2023-04-30 08:19:26', 'Model Town','Lahore', 71 ,91;
EXEC InsertOrder 508,'2024-03-29 14:40:01', '2024-04-28 14:40:01', 'Askari','Lahore', 106 ,60;
EXEC InsertOrder 509,'2024-02-16 10:13:24', '2024-02-22 10:13:24', 'Wapda Town','Lahore', 37 ,136;
EXEC InsertOrder 510,'2023-05-22 17:03:41', '2023-05-29 17:03:41', 'Ravi Road','Lahore', 43 ,93;
EXEC InsertOrder 511,'2023-07-21 13:26:40', '2023-07-29 13:26:40', 'Ravi Road','Lahore', 113 ,128;
EXEC InsertOrder 512,'2023-06-06 22:54:50', '2023-06-29 22:54:50', 'Cantt','Lahore', 104 ,140;
EXEC InsertOrder 513,'2024-01-16 02:05:12', '2024-01-21 02:05:12', 'Mozang','Lahore', 85 ,79;
EXEC InsertOrder 514,'2024-01-27 11:00:33', '2024-02-10 11:00:33', 'Sabzazar','Lahore', 21 ,40;
EXEC InsertOrder 515,'2023-07-30 01:05:32', '2023-08-08 01:05:32', 'Mozang','Lahore', 22 ,25;
EXEC InsertOrder 516,'2024-01-25 16:05:54', '2024-02-11 16:05:54', 'Gulberg','Lahore', 103 ,111;
EXEC InsertOrder 517,'2023-08-08 22:50:42', '2023-08-17 22:50:42', 'Mughalpura','Lahore', 101 ,68;
EXEC InsertOrder 518,'2024-03-09 05:49:56', '2024-03-30 05:49:56', 'Allama Iqbal Town','Lahore', 124 ,127;
EXEC InsertOrder 519,'2024-01-02 21:25:23', '2024-01-07 21:25:23', 'Gulberg','Lahore', 73 ,138;
EXEC InsertOrder 520,'2024-04-26 14:32:39', '2024-05-18 14:32:39', 'Walled City','Lahore', 111 ,55;
EXEC InsertOrder 521,'2023-08-14 17:07:28', '2023-09-11 17:07:28', 'Model Town','Lahore', 3 ,8;
EXEC InsertOrder 522,'2023-05-05 01:20:12', '2023-05-27 01:20:12', 'Walled City','Lahore', 55 ,11;
EXEC InsertOrder 523,'2023-07-31 09:38:41', '2023-08-28 09:38:41', 'Model Town','Lahore', 72 ,134;
EXEC InsertOrder 524,'2023-06-14 11:32:17', '2023-06-19 11:32:17', 'Bahria Town','Lahore', 26 ,37;
EXEC InsertOrder 525,'2023-11-24 22:10:30', '2023-12-17 22:10:30', 'Sabzazar','Lahore', 2 ,5;
EXEC InsertOrder 526,'2024-04-15 03:31:07', '2024-05-09 03:31:07', 'Mughalpura','Lahore', 83 ,69;
EXEC InsertOrder 527,'2024-02-11 18:43:50', '2024-02-27 18:43:50', 'Mughalpura','Lahore', 45 ,34;
EXEC InsertOrder 528,'2023-06-04 14:27:02', '2023-06-16 14:27:02', 'Faisal Town','Lahore', 73 ,20;
EXEC InsertOrder 529,'2024-02-13 05:37:20', '2024-02-20 05:37:20', 'Iqbal Town','Lahore', 146 ,58;
EXEC InsertOrder 530,'2024-01-24 23:46:58', '2024-02-01 23:46:58', 'Wapda Town','Lahore', 78 ,58;
EXEC InsertOrder 531,'2024-03-08 02:30:09', '2024-04-07 02:30:09', 'Bahria Town','Lahore', 68 ,87;
EXEC InsertOrder 532,'2024-03-25 13:41:37', '2024-04-10 13:41:37', 'Gari Shahu','Lahore', 89 ,124;
EXEC InsertOrder 533,'2024-02-11 16:11:16', '2024-02-20 16:11:16', 'Mughalpura','Lahore', 100 ,58;
EXEC InsertOrder 534,'2024-04-05 01:10:20', '2024-04-18 01:10:20', 'Johar Town','Lahore', 112 ,86;
EXEC InsertOrder 535,'2024-01-01 00:47:09', '2024-01-26 00:47:09', 'Model Town','Lahore', 133 ,48;
EXEC InsertOrder 536,'2024-02-20 13:26:49', '2024-03-07 13:26:49', 'Iqbal Town','Lahore', 125 ,92;
EXEC InsertOrder 537,'2023-10-23 03:58:50', '2023-11-20 03:58:50', 'Faisal Town','Lahore', 61 ,51;
EXEC InsertOrder 538,'2023-12-01 21:36:02', '2023-12-31 21:36:02', 'Walled City','Lahore', 101 ,83;
EXEC InsertOrder 539,'2023-09-29 18:25:58', '2023-10-13 18:25:58', 'Shadman','Lahore', 90 ,43;
EXEC InsertOrder 540,'2023-05-22 09:27:53', '2023-06-10 09:27:53', 'Mozang','Lahore', 136 ,33;
EXEC InsertOrder 541,'2023-09-05 08:32:31', '2023-10-05 08:32:31', 'Gulberg','Lahore', 110 ,42;
EXEC InsertOrder 542,'2023-04-02 19:10:13', '2023-04-10 19:10:13', 'Mughalpura','Lahore', 54 ,141;
EXEC InsertOrder 543,'2023-02-14 16:56:58', '2023-02-25 16:56:58', 'Mughalpura','Lahore', 64 ,74;
EXEC InsertOrder 544,'2023-01-12 21:40:22', '2023-01-15 21:40:22', 'Walled City','Lahore', 28 ,52;
EXEC InsertOrder 545,'2024-02-24 16:45:05', '2024-03-12 16:45:05', 'Allama Iqbal Town','Lahore', 137 ,79;
EXEC InsertOrder 546,'2023-01-30 23:14:59', '2023-02-15 23:14:59', 'Iqbal Town','Lahore', 72 ,114;
EXEC InsertOrder 547,'2023-08-14 23:11:34', '2023-09-03 23:11:34', 'Gulberg','Lahore', 82 ,74;
EXEC InsertOrder 548,'2024-03-03 02:02:28', '2024-03-24 02:02:28', 'Gulberg','Lahore', 86 ,29;
EXEC InsertOrder 549,'2023-09-28 14:11:59', '2023-10-03 14:11:59', 'Gari Shahu','Lahore', 55 ,44;
EXEC InsertOrder 550,'2023-06-11 01:17:07', '2023-06-29 01:17:07', 'Gari Shahu','Lahore', 40 ,29;
EXEC InsertOrder 551,'2023-08-11 14:07:43', '2023-08-31 14:07:43', 'Ravi Road','Lahore', 10 ,38;
EXEC InsertOrder 552,'2023-03-27 04:01:37', '2023-04-22 04:01:37', 'Mughalpura','Lahore', 98 ,129;
EXEC InsertOrder 553,'2023-04-23 01:27:55', '2023-05-23 01:27:55', 'Sabzazar','Lahore', 64 ,133;
EXEC InsertOrder 554,'2023-08-24 15:53:28', '2023-09-13 15:53:28', 'Sabzazar','Lahore', 70 ,53;
EXEC InsertOrder 555,'2023-07-08 04:43:34', '2023-07-20 04:43:34', 'Cantt','Lahore', 68 ,130;
EXEC InsertOrder 556,'2024-03-17 09:52:22', '2024-04-04 09:52:22', 'Sabzazar','Lahore', 30 ,8;
EXEC InsertOrder 557,'2023-07-29 09:52:50', '2023-08-26 09:52:50', 'Sabzazar','Lahore', 136 ,143;
EXEC InsertOrder 558,'2023-03-09 05:48:12', '2023-03-27 05:48:12', 'Gari Shahu','Lahore', 129 ,95;
EXEC InsertOrder 559,'2023-07-19 01:23:05', '2023-08-14 01:23:05', 'Allama Iqbal Town','Lahore', 60 ,73;
EXEC InsertOrder 560,'2023-11-07 15:07:05', '2023-11-21 15:07:05', 'Sabzazar','Lahore', 121 ,9;
EXEC InsertOrder 561,'2023-02-12 11:08:32', '2023-03-06 11:08:32', 'Model Town','Lahore', 12 ,18;
EXEC InsertOrder 562,'2023-04-10 15:40:24', '2023-05-01 15:40:24', 'Bahria Town','Lahore', 125 ,141;
EXEC InsertOrder 563,'2023-12-08 14:56:12', '2023-12-26 14:56:12', 'Faisal Town','Lahore', 17 ,13;
EXEC InsertOrder 564,'2023-02-24 15:10:41', '2023-03-16 15:10:41', 'Iqbal Town','Lahore', 85 ,70;
EXEC InsertOrder 565,'2024-04-26 00:56:30', '2024-05-14 00:56:30', 'Faisal Town','Lahore', 71 ,68;
EXEC InsertOrder 566,'2023-06-28 16:04:38', '2023-07-19 16:04:38', 'Allama Iqbal Town','Lahore', 38 ,29;
EXEC InsertOrder 567,'2023-07-20 21:44:50', '2023-08-05 21:44:50', 'Gari Shahu','Lahore', 5 ,85;
EXEC InsertOrder 568,'2023-12-18 05:50:25', '2024-01-03 05:50:25', 'Sabzazar','Lahore', 93 ,24;
EXEC InsertOrder 569,'2023-04-07 06:54:27', '2023-05-04 06:54:27', 'Mozang','Lahore', 111 ,87;
EXEC InsertOrder 570,'2023-03-20 01:59:03', '2023-04-11 01:59:03', 'Mozang','Lahore', 125 ,64;
EXEC InsertOrder 571,'2023-09-20 13:22:39', '2023-10-08 13:22:39', 'Sabzazar','Lahore', 135 ,102;
EXEC InsertOrder 572,'2023-11-02 08:20:07', '2023-11-08 08:20:07', 'Faisal Town','Lahore', 116 ,17;
EXEC InsertOrder 573,'2024-03-10 05:48:20', '2024-03-31 05:48:20', 'Gari Shahu','Lahore', 112 ,28;
EXEC InsertOrder 574,'2024-01-11 04:53:54', '2024-01-24 04:53:54', 'Garden Town','Lahore', 8 ,71;
EXEC InsertOrder 575,'2023-06-27 11:46:53', '2023-07-05 11:46:53', 'Sabzazar','Lahore', 18 ,113;
EXEC InsertOrder 576,'2023-02-20 20:07:45', '2023-03-18 20:07:45', 'Gulberg','Lahore', 65 ,27;
EXEC InsertOrder 577,'2023-10-31 18:51:50', '2023-11-21 18:51:50', 'Mughalpura','Lahore', 46 ,120;
EXEC InsertOrder 578,'2023-11-02 20:17:20', '2023-12-01 20:17:20', 'Johar Town','Lahore', 22 ,121;
EXEC InsertOrder 579,'2023-01-08 11:14:04', '2023-01-17 11:14:04', 'Bahria Town','Lahore', 102 ,90;
EXEC InsertOrder 580,'2023-07-13 08:58:59', '2023-07-27 08:58:59', 'Cantt','Lahore', 25 ,31;
EXEC InsertOrder 581,'2024-03-27 09:58:12', '2024-03-28 09:58:12', 'Iqbal Town','Lahore', 143 ,40;
EXEC InsertOrder 582,'2023-07-21 22:26:06', '2023-08-06 22:26:06', 'Allama Iqbal Town','Lahore', 126 ,144;
EXEC InsertOrder 583,'2024-02-20 03:27:23', '2024-03-01 03:27:23', 'Askari','Lahore', 115 ,110;
EXEC InsertOrder 584,'2023-02-15 20:53:27', '2023-03-11 20:53:27', 'Mozang','Lahore', 60 ,7;
EXEC InsertOrder 585,'2023-03-17 15:04:48', '2023-04-09 15:04:48', 'Wapda Town','Lahore', 106 ,12;
EXEC InsertOrder 586,'2023-07-06 06:28:48', '2023-08-03 06:28:48', 'DHA','Lahore', 116 ,149;
EXEC InsertOrder 587,'2024-03-25 14:03:07', '2024-04-08 14:03:07', 'Sabzazar','Lahore', 138 ,142;
EXEC InsertOrder 588,'2023-06-18 00:06:38', '2023-06-28 00:06:38', 'Faisal Town','Lahore', 146 ,72;
EXEC InsertOrder 589,'2023-04-17 18:31:48', '2023-05-07 18:31:48', 'Garden Town','Lahore', 18 ,86;
EXEC InsertOrder 590,'2023-10-04 18:19:09', '2023-10-05 18:19:09', 'Allama Iqbal Town','Lahore', 131 ,58;
EXEC InsertOrder 591,'2023-10-31 04:53:32', '2023-11-07 04:53:32', 'Allama Iqbal Town','Lahore', 100 ,116;
EXEC InsertOrder 592,'2024-03-20 07:43:24', '2024-03-27 07:43:24', 'Bahria Town','Lahore', 40 ,86;
EXEC InsertOrder 593,'2023-05-06 09:14:50', '2023-05-07 09:14:50', 'Allama Iqbal Town','Lahore', 78 ,129;
EXEC InsertOrder 594,'2023-12-17 04:47:52', '2023-12-30 04:47:52', 'Johar Town','Lahore', 54 ,94;
EXEC InsertOrder 595,'2023-07-29 22:34:13', '2023-08-04 22:34:13', 'Gari Shahu','Lahore', 75 ,90;
EXEC InsertOrder 596,'2024-04-20 22:44:23', '2024-05-17 22:44:23', 'Samanabad','Lahore', 51 ,30;
EXEC InsertOrder 597,'2024-01-11 19:00:58', '2024-02-02 19:00:58', 'Samanabad','Lahore', 40 ,67;
EXEC InsertOrder 598,'2023-08-22 05:11:57', '2023-09-02 05:11:57', 'Bahria Town','Lahore', 44 ,61;
EXEC InsertOrder 599,'2023-04-10 12:48:36', '2023-04-18 12:48:36', 'Shadman','Lahore', 33 ,32;
EXEC InsertOrder 600,'2023-08-14 06:51:21', '2023-08-31 06:51:21', 'Askari','Lahore', 29 ,18;

--Insertion in OrderDetails:
EXEC InsertOrderDetail 1,43,35,244;
EXEC InsertOrderDetail 2,1,22,111;
EXEC InsertOrderDetail 3,53,21,560;
EXEC InsertOrderDetail 4,22,23,542;
EXEC InsertOrderDetail 5,18,90,208;
EXEC InsertOrderDetail 6,9,24,489;
EXEC InsertOrderDetail 7,54,32,558;
EXEC InsertOrderDetail 8,1,54,136;
EXEC InsertOrderDetail 9,15,37,94;
EXEC InsertOrderDetail 10,6,88,371;
EXEC InsertOrderDetail 11,18,95,534;
EXEC InsertOrderDetail 12,7,21,462;
EXEC InsertOrderDetail 13,30,94,349;
EXEC InsertOrderDetail 14,28,53,391;
EXEC InsertOrderDetail 15,55,34,53;
EXEC InsertOrderDetail 16,55,58,75;
EXEC InsertOrderDetail 17,47,10,578;
EXEC InsertOrderDetail 18,42,44,159;
EXEC InsertOrderDetail 19,40,77,487;
EXEC InsertOrderDetail 20,44,84,472;
EXEC InsertOrderDetail 21,36,75,132;
EXEC InsertOrderDetail 22,39,12,98;
EXEC InsertOrderDetail 23,2,98,530;
EXEC InsertOrderDetail 24,24,34,4;
EXEC InsertOrderDetail 25,47,4,485;
EXEC InsertOrderDetail 26,32,67,153;
EXEC InsertOrderDetail 27,49,62,328;
EXEC InsertOrderDetail 28,54,36,106;
EXEC InsertOrderDetail 29,51,100,400;
EXEC InsertOrderDetail 30,28,99,389;
EXEC InsertOrderDetail 31,48,81,112;
EXEC InsertOrderDetail 32,19,86,134;
EXEC InsertOrderDetail 33,29,37,139;
EXEC InsertOrderDetail 34,27,89,516;
EXEC InsertOrderDetail 35,26,61,542;
EXEC InsertOrderDetail 36,32,70,300;
EXEC InsertOrderDetail 37,48,89,549;
EXEC InsertOrderDetail 38,4,21,357;
EXEC InsertOrderDetail 39,2,26,434;
EXEC InsertOrderDetail 40,13,10,211;
EXEC InsertOrderDetail 41,12,34,557;
EXEC InsertOrderDetail 42,44,16,122;
EXEC InsertOrderDetail 43,16,27,284;
EXEC InsertOrderDetail 44,28,7,23;
EXEC InsertOrderDetail 45,29,67,229;
EXEC InsertOrderDetail 46,55,97,66;
EXEC InsertOrderDetail 47,6,47,518;
EXEC InsertOrderDetail 48,25,55,586;
EXEC InsertOrderDetail 49,15,43,24;
EXEC InsertOrderDetail 50,47,70,12;
EXEC InsertOrderDetail 51,32,5,388;
EXEC InsertOrderDetail 52,29,34,586;
EXEC InsertOrderDetail 53,4,9,167;
EXEC InsertOrderDetail 54,31,64,597;
EXEC InsertOrderDetail 55,27,39,143;
EXEC InsertOrderDetail 56,28,28,146;
EXEC InsertOrderDetail 57,46,66,502;
EXEC InsertOrderDetail 58,55,41,295;
EXEC InsertOrderDetail 59,16,10,65;
EXEC InsertOrderDetail 60,18,65,6;
EXEC InsertOrderDetail 61,9,42,22;
EXEC InsertOrderDetail 62,14,68,540;
EXEC InsertOrderDetail 63,13,93,442;
EXEC InsertOrderDetail 64,38,47,58;
EXEC InsertOrderDetail 65,25,51,19;
EXEC InsertOrderDetail 66,34,65,345;
EXEC InsertOrderDetail 67,55,46,474;
EXEC InsertOrderDetail 68,45,27,452;
EXEC InsertOrderDetail 69,19,14,237;
EXEC InsertOrderDetail 70,13,75,175;
EXEC InsertOrderDetail 71,10,12,456;
EXEC InsertOrderDetail 72,20,55,416;
EXEC InsertOrderDetail 73,2,66,219;
EXEC InsertOrderDetail 74,45,54,250;
EXEC InsertOrderDetail 75,44,62,60;
EXEC InsertOrderDetail 76,47,5,59;
EXEC InsertOrderDetail 77,14,16,515;
EXEC InsertOrderDetail 78,35,82,468;
EXEC InsertOrderDetail 79,29,90,309;
EXEC InsertOrderDetail 80,41,86,388;
EXEC InsertOrderDetail 81,54,68,269;
EXEC InsertOrderDetail 82,53,97,254;
EXEC InsertOrderDetail 83,46,52,125;
EXEC InsertOrderDetail 84,18,40,64;
EXEC InsertOrderDetail 85,34,87,174;
EXEC InsertOrderDetail 86,29,60,394;
EXEC InsertOrderDetail 87,8,94,589;
EXEC InsertOrderDetail 88,55,29,483;
EXEC InsertOrderDetail 89,52,93,209;
EXEC InsertOrderDetail 90,37,49,190;
EXEC InsertOrderDetail 91,32,48,454;
EXEC InsertOrderDetail 92,35,99,422;
EXEC InsertOrderDetail 93,53,4,166;
EXEC InsertOrderDetail 94,1,7,426;
EXEC InsertOrderDetail 95,51,97,1;
EXEC InsertOrderDetail 96,45,38,500;
EXEC InsertOrderDetail 97,54,1,433;
EXEC InsertOrderDetail 98,10,36,575;
EXEC InsertOrderDetail 99,39,56,33;
EXEC InsertOrderDetail 100,8,29,351;
EXEC InsertOrderDetail 101,32,52,396;
EXEC InsertOrderDetail 102,1,18,533;
EXEC InsertOrderDetail 103,28,5,528;
EXEC InsertOrderDetail 104,54,65,571;
EXEC InsertOrderDetail 105,50,58,62;
EXEC InsertOrderDetail 106,51,2,301;
EXEC InsertOrderDetail 107,4,57,471;
EXEC InsertOrderDetail 108,5,12,108;
EXEC InsertOrderDetail 109,23,56,196;
EXEC InsertOrderDetail 110,29,16,249;
EXEC InsertOrderDetail 111,7,49,405;
EXEC InsertOrderDetail 112,44,51,477;
EXEC InsertOrderDetail 113,54,82,337;
EXEC InsertOrderDetail 114,38,77,534;
EXEC InsertOrderDetail 115,19,9,244;
EXEC InsertOrderDetail 116,4,41,71;
EXEC InsertOrderDetail 117,7,13,48;
EXEC InsertOrderDetail 118,11,4,221;
EXEC InsertOrderDetail 119,41,9,172;
EXEC InsertOrderDetail 120,26,47,322;
EXEC InsertOrderDetail 121,32,80,575;
EXEC InsertOrderDetail 122,11,8,515;
EXEC InsertOrderDetail 123,12,17,527;
EXEC InsertOrderDetail 124,24,64,64;
EXEC InsertOrderDetail 125,36,48,445;
EXEC InsertOrderDetail 126,11,51,453;
EXEC InsertOrderDetail 127,25,15,30;
EXEC InsertOrderDetail 128,46,73,227;
EXEC InsertOrderDetail 129,2,76,463;
EXEC InsertOrderDetail 130,14,41,228;
EXEC InsertOrderDetail 131,54,15,459;
EXEC InsertOrderDetail 132,5,44,4;
EXEC InsertOrderDetail 133,33,30,242;
EXEC InsertOrderDetail 134,9,96,245;
EXEC InsertOrderDetail 135,12,34,599;
EXEC InsertOrderDetail 136,49,60,576;
EXEC InsertOrderDetail 137,34,28,96;
EXEC InsertOrderDetail 138,20,57,497;
EXEC InsertOrderDetail 139,53,51,304;
EXEC InsertOrderDetail 140,9,74,109;
EXEC InsertOrderDetail 141,22,88,503;
EXEC InsertOrderDetail 142,38,59,529;
EXEC InsertOrderDetail 143,33,73,475;
EXEC InsertOrderDetail 144,3,86,17;
EXEC InsertOrderDetail 145,40,18,514;
EXEC InsertOrderDetail 146,39,61,280;
EXEC InsertOrderDetail 147,26,18,275;
EXEC InsertOrderDetail 148,49,79,260;
EXEC InsertOrderDetail 149,11,86,198;
EXEC InsertOrderDetail 150,44,41,162;
EXEC InsertOrderDetail 151,31,37,373;
EXEC InsertOrderDetail 152,34,60,233;
EXEC InsertOrderDetail 153,43,8,180;
EXEC InsertOrderDetail 154,8,14,370;
EXEC InsertOrderDetail 155,32,51,67;
EXEC InsertOrderDetail 156,9,35,126;
EXEC InsertOrderDetail 157,32,39,520;
EXEC InsertOrderDetail 158,29,9,268;
EXEC InsertOrderDetail 159,17,92,265;
EXEC InsertOrderDetail 160,18,91,8;
EXEC InsertOrderDetail 161,26,76,87;
EXEC InsertOrderDetail 162,44,69,546;
EXEC InsertOrderDetail 163,39,97,352;
EXEC InsertOrderDetail 164,30,50,503;
EXEC InsertOrderDetail 165,13,49,559;
EXEC InsertOrderDetail 166,32,69,331;
EXEC InsertOrderDetail 167,1,31,568;
EXEC InsertOrderDetail 168,44,62,334;
EXEC InsertOrderDetail 169,10,35,478;
EXEC InsertOrderDetail 170,1,18,371;
EXEC InsertOrderDetail 171,16,89,545;
EXEC InsertOrderDetail 172,43,83,328;
EXEC InsertOrderDetail 173,21,21,429;
EXEC InsertOrderDetail 174,6,29,317;
EXEC InsertOrderDetail 175,36,27,248;
EXEC InsertOrderDetail 176,54,92,251;
EXEC InsertOrderDetail 177,13,66,293;
EXEC InsertOrderDetail 178,6,42,513;
EXEC InsertOrderDetail 179,43,20,357;
EXEC InsertOrderDetail 180,18,31,286;
EXEC InsertOrderDetail 181,53,75,55;
EXEC InsertOrderDetail 182,24,44,562;
EXEC InsertOrderDetail 183,54,29,135;
EXEC InsertOrderDetail 184,33,85,386;
EXEC InsertOrderDetail 185,13,47,581;
EXEC InsertOrderDetail 186,41,61,119;
EXEC InsertOrderDetail 187,7,3,89;
EXEC InsertOrderDetail 188,48,47,182;
EXEC InsertOrderDetail 189,1,31,216;
EXEC InsertOrderDetail 190,36,80,115;
EXEC InsertOrderDetail 191,36,45,375;
EXEC InsertOrderDetail 192,26,97,156;
EXEC InsertOrderDetail 193,17,24,26;
EXEC InsertOrderDetail 194,45,19,591;
EXEC InsertOrderDetail 195,25,92,202;
EXEC InsertOrderDetail 196,36,62,458;
EXEC InsertOrderDetail 197,3,80,168;
EXEC InsertOrderDetail 198,20,25,577;
EXEC InsertOrderDetail 199,14,90,376;
EXEC InsertOrderDetail 200,6,51,600;
EXEC InsertOrderDetail 201,8,99,346;
EXEC InsertOrderDetail 202,24,18,411;
EXEC InsertOrderDetail 203,23,79,151;
EXEC InsertOrderDetail 204,55,98,51;
EXEC InsertOrderDetail 205,9,5,338;
EXEC InsertOrderDetail 206,1,62,53;
EXEC InsertOrderDetail 207,53,42,74;
EXEC InsertOrderDetail 208,46,11,317;
EXEC InsertOrderDetail 209,32,56,54;
EXEC InsertOrderDetail 210,27,77,495;
EXEC InsertOrderDetail 211,47,51,195;
EXEC InsertOrderDetail 212,37,36,466;
EXEC InsertOrderDetail 213,7,85,264;
EXEC InsertOrderDetail 214,49,65,281;
EXEC InsertOrderDetail 215,18,97,26;
EXEC InsertOrderDetail 216,30,72,439;
EXEC InsertOrderDetail 217,26,57,449;
EXEC InsertOrderDetail 218,14,21,209;
EXEC InsertOrderDetail 219,31,100,484;
EXEC InsertOrderDetail 220,19,88,541;
EXEC InsertOrderDetail 221,6,80,264;
EXEC InsertOrderDetail 222,8,60,207;
EXEC InsertOrderDetail 223,13,33,517;
EXEC InsertOrderDetail 224,40,85,380;
EXEC InsertOrderDetail 225,24,84,288;
EXEC InsertOrderDetail 226,8,39,223;
EXEC InsertOrderDetail 227,23,85,573;
EXEC InsertOrderDetail 228,3,68,274;
EXEC InsertOrderDetail 229,55,19,215;
EXEC InsertOrderDetail 230,13,30,65;
EXEC InsertOrderDetail 231,7,44,390;
EXEC InsertOrderDetail 232,33,14,49;
EXEC InsertOrderDetail 233,44,93,359;
EXEC InsertOrderDetail 234,49,21,583;
EXEC InsertOrderDetail 235,21,12,231;
EXEC InsertOrderDetail 236,34,93,348;
EXEC InsertOrderDetail 237,47,29,453;
EXEC InsertOrderDetail 238,16,16,523;
EXEC InsertOrderDetail 239,48,64,519;
EXEC InsertOrderDetail 240,5,15,62;
EXEC InsertOrderDetail 241,51,67,595;
EXEC InsertOrderDetail 242,50,92,11;
EXEC InsertOrderDetail 243,16,30,417;
EXEC InsertOrderDetail 244,12,93,117;
EXEC InsertOrderDetail 245,20,25,435;
EXEC InsertOrderDetail 246,32,49,91;
EXEC InsertOrderDetail 247,12,62,555;
EXEC InsertOrderDetail 248,3,40,318;
EXEC InsertOrderDetail 249,6,15,596;
EXEC InsertOrderDetail 250,24,55,521;
EXEC InsertOrderDetail 251,47,7,229;
EXEC InsertOrderDetail 252,37,95,341;
EXEC InsertOrderDetail 253,1,81,46;
EXEC InsertOrderDetail 254,7,47,314;
EXEC InsertOrderDetail 255,49,65,369;
EXEC InsertOrderDetail 256,46,28,425;
EXEC InsertOrderDetail 257,50,43,353;
EXEC InsertOrderDetail 258,25,86,363;
EXEC InsertOrderDetail 259,36,55,262;
EXEC InsertOrderDetail 260,45,63,525;
EXEC InsertOrderDetail 261,29,92,35;
EXEC InsertOrderDetail 262,50,30,369;
EXEC InsertOrderDetail 263,44,21,205;
EXEC InsertOrderDetail 264,20,75,199;
EXEC InsertOrderDetail 265,7,17,178;
EXEC InsertOrderDetail 266,21,11,548;
EXEC InsertOrderDetail 267,50,63,193;
EXEC InsertOrderDetail 268,49,77,315;
EXEC InsertOrderDetail 269,11,17,456;
EXEC InsertOrderDetail 270,22,24,491;
EXEC InsertOrderDetail 271,19,9,44;
EXEC InsertOrderDetail 272,53,46,156;
EXEC InsertOrderDetail 273,55,62,144;
EXEC InsertOrderDetail 274,24,98,493;
EXEC InsertOrderDetail 275,49,26,367;
EXEC InsertOrderDetail 276,54,54,451;
EXEC InsertOrderDetail 277,52,79,212;
EXEC InsertOrderDetail 278,1,6,32;
EXEC InsertOrderDetail 279,26,2,350;
EXEC InsertOrderDetail 280,13,23,294;
EXEC InsertOrderDetail 281,16,71,415;
EXEC InsertOrderDetail 282,16,27,430;
EXEC InsertOrderDetail 283,7,20,572;
EXEC InsertOrderDetail 284,10,62,364;
EXEC InsertOrderDetail 285,2,69,290;
EXEC InsertOrderDetail 286,3,25,311;
EXEC InsertOrderDetail 287,37,85,20;
EXEC InsertOrderDetail 288,1,44,50;
EXEC InsertOrderDetail 289,42,34,423;
EXEC InsertOrderDetail 290,3,24,511;
EXEC InsertOrderDetail 291,48,93,563;
EXEC InsertOrderDetail 292,47,45,154;
EXEC InsertOrderDetail 293,20,45,8;
EXEC InsertOrderDetail 294,4,1,543;
EXEC InsertOrderDetail 295,27,43,545;
EXEC InsertOrderDetail 296,1,51,365;
EXEC InsertOrderDetail 297,24,86,257;
EXEC InsertOrderDetail 298,6,87,241;
EXEC InsertOrderDetail 299,33,64,203;
EXEC InsertOrderDetail 300,22,57,114;
EXEC InsertOrderDetail 301,49,29,570;
EXEC InsertOrderDetail 302,47,48,188;
EXEC InsertOrderDetail 303,5,35,273;
EXEC InsertOrderDetail 304,17,67,27;
EXEC InsertOrderDetail 305,51,54,214;
EXEC InsertOrderDetail 306,55,68,110;
EXEC InsertOrderDetail 307,4,6,212;
EXEC InsertOrderDetail 308,46,36,215;
EXEC InsertOrderDetail 309,53,15,593;
EXEC InsertOrderDetail 310,27,88,182;
EXEC InsertOrderDetail 311,13,45,370;
EXEC InsertOrderDetail 312,47,67,499;
EXEC InsertOrderDetail 313,10,6,379;
EXEC InsertOrderDetail 314,38,57,441;
EXEC InsertOrderDetail 315,9,98,45;
EXEC InsertOrderDetail 316,34,85,526;
EXEC InsertOrderDetail 317,35,6,509;
EXEC InsertOrderDetail 318,22,62,164;
EXEC InsertOrderDetail 319,42,58,340;
EXEC InsertOrderDetail 320,6,44,118;
EXEC InsertOrderDetail 321,40,99,24;
EXEC InsertOrderDetail 322,44,69,321;
EXEC InsertOrderDetail 323,21,21,124;
EXEC InsertOrderDetail 324,40,82,551;
EXEC InsertOrderDetail 325,28,43,277;
EXEC InsertOrderDetail 326,12,49,266;
EXEC InsertOrderDetail 327,12,80,308;
EXEC InsertOrderDetail 328,16,8,494;
EXEC InsertOrderDetail 329,8,96,401;
EXEC InsertOrderDetail 330,15,33,582;
EXEC InsertOrderDetail 331,38,89,495;
EXEC InsertOrderDetail 332,25,65,362;
EXEC InsertOrderDetail 333,3,60,153;
EXEC InsertOrderDetail 334,24,2,259;
EXEC InsertOrderDetail 335,20,56,79;
EXEC InsertOrderDetail 336,32,66,461;
EXEC InsertOrderDetail 337,24,55,19;
EXEC InsertOrderDetail 338,7,29,481;
EXEC InsertOrderDetail 339,53,2,391;
EXEC InsertOrderDetail 340,49,14,210;
EXEC InsertOrderDetail 341,36,14,109;
EXEC InsertOrderDetail 342,48,51,147;
EXEC InsertOrderDetail 343,42,41,99;
EXEC InsertOrderDetail 344,14,56,436;
EXEC InsertOrderDetail 345,9,43,438;
EXEC InsertOrderDetail 346,23,51,267;
EXEC InsertOrderDetail 347,11,9,368;
EXEC InsertOrderDetail 348,12,18,407;
EXEC InsertOrderDetail 349,54,84,269;
EXEC InsertOrderDetail 350,51,21,344;
EXEC InsertOrderDetail 351,6,93,343;
EXEC InsertOrderDetail 352,22,95,320;
EXEC InsertOrderDetail 353,33,27,273;
EXEC InsertOrderDetail 354,4,81,402;
EXEC InsertOrderDetail 355,45,6,155;
EXEC InsertOrderDetail 356,13,98,285;
EXEC InsertOrderDetail 357,8,46,43;
EXEC InsertOrderDetail 358,31,17,361;
EXEC InsertOrderDetail 359,50,29,225;
EXEC InsertOrderDetail 360,45,98,177;
EXEC InsertOrderDetail 361,10,49,253;
EXEC InsertOrderDetail 362,30,46,70;
EXEC InsertOrderDetail 363,16,36,319;
EXEC InsertOrderDetail 364,4,20,444;
EXEC InsertOrderDetail 365,21,10,436;
EXEC InsertOrderDetail 366,33,33,306;
EXEC InsertOrderDetail 367,5,99,372;
EXEC InsertOrderDetail 368,45,65,346;
EXEC InsertOrderDetail 369,14,64,443;
EXEC InsertOrderDetail 370,49,56,168;
EXEC InsertOrderDetail 371,52,10,483;
EXEC InsertOrderDetail 372,46,80,482;
EXEC InsertOrderDetail 373,22,82,104;
EXEC InsertOrderDetail 374,16,36,179;
EXEC InsertOrderDetail 375,32,78,423;
EXEC InsertOrderDetail 376,28,18,1;
EXEC InsertOrderDetail 377,51,94,16;
EXEC InsertOrderDetail 378,47,50,580;
EXEC InsertOrderDetail 379,41,85,38;
EXEC InsertOrderDetail 380,9,89,517;
EXEC InsertOrderDetail 381,29,35,263;
EXEC InsertOrderDetail 382,52,66,502;
EXEC InsertOrderDetail 383,26,100,375;
EXEC InsertOrderDetail 384,55,17,10;
EXEC InsertOrderDetail 385,33,93,434;
EXEC InsertOrderDetail 386,10,30,103;
EXEC InsertOrderDetail 387,52,33,508;
EXEC InsertOrderDetail 388,37,79,276;
EXEC InsertOrderDetail 389,42,38,313;
EXEC InsertOrderDetail 390,55,87,115;
EXEC InsertOrderDetail 391,16,3,184;
EXEC InsertOrderDetail 392,38,87,472;
EXEC InsertOrderDetail 393,29,8,556;
EXEC InsertOrderDetail 394,40,20,580;
EXEC InsertOrderDetail 395,40,94,200;
EXEC InsertOrderDetail 396,12,22,326;
EXEC InsertOrderDetail 397,11,33,207;
EXEC InsertOrderDetail 398,26,1,93;
EXEC InsertOrderDetail 399,27,58,255;
EXEC InsertOrderDetail 400,39,37,16;
EXEC InsertOrderDetail 401,9,27,232;
EXEC InsertOrderDetail 402,24,22,2;
EXEC InsertOrderDetail 403,11,95,18;
EXEC InsertOrderDetail 404,24,35,336;
EXEC InsertOrderDetail 405,30,9,398;
EXEC InsertOrderDetail 406,51,74,469;
EXEC InsertOrderDetail 407,7,40,160;
EXEC InsertOrderDetail 408,35,96,450;
EXEC InsertOrderDetail 409,4,22,343;
EXEC InsertOrderDetail 410,14,41,358;
EXEC InsertOrderDetail 411,31,87,93;
EXEC InsertOrderDetail 412,6,63,205;
EXEC InsertOrderDetail 413,48,54,132;
EXEC InsertOrderDetail 414,35,48,393;
EXEC InsertOrderDetail 415,48,20,302;
EXEC InsertOrderDetail 416,42,6,75;
EXEC InsertOrderDetail 417,41,1,56;
EXEC InsertOrderDetail 418,45,28,473;
EXEC InsertOrderDetail 419,6,16,101;
EXEC InsertOrderDetail 420,17,44,121;
EXEC InsertOrderDetail 421,5,32,120;
EXEC InsertOrderDetail 422,1,25,470;
EXEC InsertOrderDetail 423,44,93,355;
EXEC InsertOrderDetail 424,18,47,135;
EXEC InsertOrderDetail 425,41,16,100;
EXEC InsertOrderDetail 426,36,70,236;
EXEC InsertOrderDetail 427,53,14,354;
EXEC InsertOrderDetail 428,38,83,98;
EXEC InsertOrderDetail 429,23,21,500;
EXEC InsertOrderDetail 430,35,74,217;
EXEC InsertOrderDetail 431,12,24,161;
EXEC InsertOrderDetail 432,10,48,504;
EXEC InsertOrderDetail 433,42,73,587;
EXEC InsertOrderDetail 434,48,57,492;
EXEC InsertOrderDetail 435,11,30,91;
EXEC InsertOrderDetail 436,8,56,403;
EXEC InsertOrderDetail 437,28,15,489;
EXEC InsertOrderDetail 438,28,71,530;
EXEC InsertOrderDetail 439,17,27,467;
EXEC InsertOrderDetail 440,31,23,158;
EXEC InsertOrderDetail 441,49,74,101;
EXEC InsertOrderDetail 442,44,79,287;
EXEC InsertOrderDetail 443,33,81,486;
EXEC InsertOrderDetail 444,12,72,467;
EXEC InsertOrderDetail 445,31,92,574;
EXEC InsertOrderDetail 446,48,60,29;
EXEC InsertOrderDetail 447,5,78,506;
EXEC InsertOrderDetail 448,50,1,355;
EXEC InsertOrderDetail 449,47,75,72;
EXEC InsertOrderDetail 450,47,13,512;
EXEC InsertOrderDetail 451,45,33,97;
EXEC InsertOrderDetail 452,23,57,490;
EXEC InsertOrderDetail 453,54,98,11;
EXEC InsertOrderDetail 454,10,17,576;
EXEC InsertOrderDetail 455,10,82,191;
EXEC InsertOrderDetail 456,43,24,220;
EXEC InsertOrderDetail 457,4,92,446;
EXEC InsertOrderDetail 458,10,97,145;
EXEC InsertOrderDetail 459,40,78,32;
EXEC InsertOrderDetail 460,52,67,498;
EXEC InsertOrderDetail 461,54,68,590;
EXEC InsertOrderDetail 462,24,32,174;
EXEC InsertOrderDetail 463,35,62,213;
EXEC InsertOrderDetail 464,24,76,99;
EXEC InsertOrderDetail 465,22,40,175;
EXEC InsertOrderDetail 466,23,28,290;
EXEC InsertOrderDetail 467,35,31,169;
EXEC InsertOrderDetail 468,6,41,447;
EXEC InsertOrderDetail 469,44,80,83;
EXEC InsertOrderDetail 470,14,23,18;
EXEC InsertOrderDetail 471,25,39,9;
EXEC InsertOrderDetail 472,24,74,76;
EXEC InsertOrderDetail 473,3,40,396;
EXEC InsertOrderDetail 474,24,99,221;
EXEC InsertOrderDetail 475,27,54,409;
EXEC InsertOrderDetail 476,2,82,501;
EXEC InsertOrderDetail 477,3,47,572;
EXEC InsertOrderDetail 478,41,50,488;
EXEC InsertOrderDetail 479,1,92,415;
EXEC InsertOrderDetail 480,24,85,122;
EXEC InsertOrderDetail 481,46,97,34;
EXEC InsertOrderDetail 482,16,48,176;
EXEC InsertOrderDetail 483,2,74,69;
EXEC InsertOrderDetail 484,48,3,405;
EXEC InsertOrderDetail 485,38,42,105;
EXEC InsertOrderDetail 486,53,19,236;
EXEC InsertOrderDetail 487,29,6,176;
EXEC InsertOrderDetail 488,33,1,595;
EXEC InsertOrderDetail 489,1,40,56;
EXEC InsertOrderDetail 490,25,91,77;
EXEC InsertOrderDetail 491,2,63,594;
EXEC InsertOrderDetail 492,20,57,422;
EXEC InsertOrderDetail 493,45,51,60;
EXEC InsertOrderDetail 494,8,2,169;
EXEC InsertOrderDetail 495,14,57,14;
EXEC InsertOrderDetail 496,33,62,376;
EXEC InsertOrderDetail 497,32,27,479;
EXEC InsertOrderDetail 498,24,63,275;
EXEC InsertOrderDetail 499,45,54,84;
EXEC InsertOrderDetail 500,29,72,417;
EXEC InsertOrderDetail 501,40,43,419;
EXEC InsertOrderDetail 502,50,33,270;
EXEC InsertOrderDetail 503,15,95,335;
EXEC InsertOrderDetail 504,3,47,217;
EXEC InsertOrderDetail 505,49,97,178;
EXEC InsertOrderDetail 506,12,7,395;
EXEC InsertOrderDetail 507,21,83,446;
EXEC InsertOrderDetail 508,32,2,432;
EXEC InsertOrderDetail 509,19,54,123;
EXEC InsertOrderDetail 510,1,92,181;
EXEC InsertOrderDetail 511,10,59,118;
EXEC InsertOrderDetail 512,12,72,521;
EXEC InsertOrderDetail 513,24,62,170;
EXEC InsertOrderDetail 514,25,76,342;
EXEC InsertOrderDetail 515,4,32,74;
EXEC InsertOrderDetail 516,6,36,485;
EXEC InsertOrderDetail 517,28,1,498;
EXEC InsertOrderDetail 518,42,74,433;
EXEC InsertOrderDetail 519,30,44,466;
EXEC InsertOrderDetail 520,10,86,219;
EXEC InsertOrderDetail 521,52,5,309;
EXEC InsertOrderDetail 522,15,19,128;
EXEC InsertOrderDetail 523,54,44,149;
EXEC InsertOrderDetail 524,21,62,452;
EXEC InsertOrderDetail 525,33,21,230;
EXEC InsertOrderDetail 526,2,86,481;
EXEC InsertOrderDetail 527,2,60,33;
EXEC InsertOrderDetail 528,39,2,143;
EXEC InsertOrderDetail 529,5,24,579;
EXEC InsertOrderDetail 530,32,53,552;
EXEC InsertOrderDetail 531,19,61,225;
EXEC InsertOrderDetail 532,55,26,76;
EXEC InsertOrderDetail 533,37,97,340;
EXEC InsertOrderDetail 534,45,87,82;
EXEC InsertOrderDetail 535,8,22,424;
EXEC InsertOrderDetail 536,42,25,90;
EXEC InsertOrderDetail 537,14,43,313;
EXEC InsertOrderDetail 538,18,95,146;
EXEC InsertOrderDetail 539,9,10,413;
EXEC InsertOrderDetail 540,39,31,20;
EXEC InsertOrderDetail 541,45,7,553;
EXEC InsertOrderDetail 542,54,90,195;
EXEC InsertOrderDetail 543,30,69,567;
EXEC InsertOrderDetail 544,53,64,538;
EXEC InsertOrderDetail 545,38,33,183;
EXEC InsertOrderDetail 546,52,69,468;
EXEC InsertOrderDetail 547,50,27,584;
EXEC InsertOrderDetail 548,40,16,311;
EXEC InsertOrderDetail 549,31,69,237;
EXEC InsertOrderDetail 550,4,64,224;
EXEC InsertOrderDetail 551,7,96,404;
EXEC InsertOrderDetail 552,17,51,305;
EXEC InsertOrderDetail 553,28,15,512;
EXEC InsertOrderDetail 554,50,26,492;
EXEC InsertOrderDetail 555,3,35,561;
EXEC InsertOrderDetail 556,17,70,441;
EXEC InsertOrderDetail 557,7,24,257;
EXEC InsertOrderDetail 558,37,93,84;
EXEC InsertOrderDetail 559,9,87,297;
EXEC InsertOrderDetail 560,37,73,352;
EXEC InsertOrderDetail 561,36,36,286;
EXEC InsertOrderDetail 562,32,2,9;
EXEC InsertOrderDetail 563,13,49,442;
EXEC InsertOrderDetail 564,39,57,287;
EXEC InsertOrderDetail 565,1,100,416;
EXEC InsertOrderDetail 566,46,18,397;
EXEC InsertOrderDetail 567,16,60,71;
EXEC InsertOrderDetail 568,30,66,368;
EXEC InsertOrderDetail 569,28,91,185;
EXEC InsertOrderDetail 570,12,75,141;
EXEC InsertOrderDetail 571,54,75,247;
EXEC InsertOrderDetail 572,7,77,312;
EXEC InsertOrderDetail 573,35,57,539;
EXEC InsertOrderDetail 574,47,16,14;
EXEC InsertOrderDetail 575,49,60,113;
EXEC InsertOrderDetail 576,29,60,202;
EXEC InsertOrderDetail 577,33,98,497;
EXEC InsertOrderDetail 578,24,45,61;
EXEC InsertOrderDetail 579,22,74,235;
EXEC InsertOrderDetail 580,12,40,356;
EXEC InsertOrderDetail 581,22,11,72;
EXEC InsertOrderDetail 582,19,30,341;
EXEC InsertOrderDetail 583,55,28,589;
EXEC InsertOrderDetail 584,51,82,381;
EXEC InsertOrderDetail 585,4,89,544;
EXEC InsertOrderDetail 586,7,49,303;
EXEC InsertOrderDetail 587,52,41,142;
EXEC InsertOrderDetail 588,33,43,187;
EXEC InsertOrderDetail 589,40,87,361;
EXEC InsertOrderDetail 590,11,3,162;
EXEC InsertOrderDetail 591,35,28,57;
EXEC InsertOrderDetail 592,9,87,127;
EXEC InsertOrderDetail 593,2,81,312;
EXEC InsertOrderDetail 594,25,93,360;
EXEC InsertOrderDetail 595,10,36,535;
EXEC InsertOrderDetail 596,32,52,186;
EXEC InsertOrderDetail 597,48,12,358;
EXEC InsertOrderDetail 598,34,38,238;
EXEC InsertOrderDetail 599,10,2,42;
EXEC InsertOrderDetail 600,39,87,438;
EXEC InsertOrderDetail 601,7,23,79;
EXEC InsertOrderDetail 602,19,87,387;
EXEC InsertOrderDetail 603,43,8,365;
EXEC InsertOrderDetail 604,3,40,316;
EXEC InsertOrderDetail 605,54,14,410;
EXEC InsertOrderDetail 606,36,58,523;
EXEC InsertOrderDetail 607,25,82,88;
EXEC InsertOrderDetail 608,20,97,39;
EXEC InsertOrderDetail 609,18,79,158;
EXEC InsertOrderDetail 610,9,47,200;
EXEC InsertOrderDetail 611,27,50,330;
EXEC InsertOrderDetail 612,34,57,63;
EXEC InsertOrderDetail 613,24,95,582;
EXEC InsertOrderDetail 614,45,11,450;
EXEC InsertOrderDetail 615,51,68,124;
EXEC InsertOrderDetail 616,35,49,307;
EXEC InsertOrderDetail 617,5,86,427;
EXEC InsertOrderDetail 618,19,41,39;
EXEC InsertOrderDetail 619,7,75,126;
EXEC InsertOrderDetail 620,52,96,137;
EXEC InsertOrderDetail 621,7,69,279;
EXEC InsertOrderDetail 622,10,72,80;
EXEC InsertOrderDetail 623,28,48,420;
EXEC InsertOrderDetail 624,51,14,588;
EXEC InsertOrderDetail 625,17,93,77;
EXEC InsertOrderDetail 626,30,90,364;
EXEC InsertOrderDetail 627,49,52,13;
EXEC InsertOrderDetail 628,38,87,484;
EXEC InsertOrderDetail 629,51,15,57;
EXEC InsertOrderDetail 630,14,31,155;
EXEC InsertOrderDetail 631,21,23,379;
EXEC InsertOrderDetail 632,21,65,421;
EXEC InsertOrderDetail 633,13,10,301;
EXEC InsertOrderDetail 634,46,53,246;
EXEC InsertOrderDetail 635,16,9,598;
EXEC InsertOrderDetail 636,33,1,123;
EXEC InsertOrderDetail 637,33,70,262;
EXEC InsertOrderDetail 638,35,83,157;
EXEC InsertOrderDetail 639,25,2,409;
EXEC InsertOrderDetail 640,20,27,339;
EXEC InsertOrderDetail 641,18,96,179;
EXEC InsertOrderDetail 642,8,75,408;
EXEC InsertOrderDetail 643,18,85,460;
EXEC InsertOrderDetail 644,26,47,565;
EXEC InsertOrderDetail 645,50,48,28;
EXEC InsertOrderDetail 646,21,73,10;
EXEC InsertOrderDetail 647,46,90,141;
EXEC InsertOrderDetail 648,13,22,377;
EXEC InsertOrderDetail 649,34,1,339;
EXEC InsertOrderDetail 650,52,46,599;
EXEC InsertOrderDetail 651,27,95,196;
EXEC InsertOrderDetail 652,12,24,170;
EXEC InsertOrderDetail 653,37,74,553;
EXEC InsertOrderDetail 654,32,90,507;
EXEC InsertOrderDetail 655,26,1,58;
EXEC InsertOrderDetail 656,50,17,411;
EXEC InsertOrderDetail 657,32,68,145;
EXEC InsertOrderDetail 658,2,95,119;
EXEC InsertOrderDetail 659,40,42,278;
EXEC InsertOrderDetail 660,49,59,171;
EXEC InsertOrderDetail 661,24,61,30;
EXEC InsertOrderDetail 662,11,46,231;
EXEC InsertOrderDetail 663,36,38,201;
EXEC InsertOrderDetail 664,44,52,577;
EXEC InsertOrderDetail 665,38,45,551;
EXEC InsertOrderDetail 666,14,93,531;
EXEC InsertOrderDetail 667,5,63,406;
EXEC InsertOrderDetail 668,24,61,223;
EXEC InsertOrderDetail 669,29,32,487;
EXEC InsertOrderDetail 670,17,58,104;
EXEC InsertOrderDetail 671,2,54,31;
EXEC InsertOrderDetail 672,11,77,166;
EXEC InsertOrderDetail 673,33,80,501;
EXEC InsertOrderDetail 674,25,17,52;
EXEC InsertOrderDetail 675,1,92,81;
EXEC InsertOrderDetail 676,17,51,412;
EXEC InsertOrderDetail 677,34,38,385;
EXEC InsertOrderDetail 678,11,57,412;
EXEC InsertOrderDetail 679,35,17,380;
EXEC InsertOrderDetail 680,39,18,560;
EXEC InsertOrderDetail 681,39,38,297;
EXEC InsertOrderDetail 682,55,19,399;
EXEC InsertOrderDetail 683,3,60,107;
EXEC InsertOrderDetail 684,2,94,277;
EXEC InsertOrderDetail 685,10,94,549;
EXEC InsertOrderDetail 686,31,100,246;
EXEC InsertOrderDetail 687,49,24,94;
EXEC InsertOrderDetail 688,43,63,163;
EXEC InsertOrderDetail 689,42,59,360;
EXEC InsertOrderDetail 690,28,37,31;
EXEC InsertOrderDetail 691,12,58,392;
EXEC InsertOrderDetail 692,32,10,78;
EXEC InsertOrderDetail 693,22,27,240;
EXEC InsertOrderDetail 694,46,25,50;
EXEC InsertOrderDetail 695,41,83,378;
EXEC InsertOrderDetail 696,7,22,292;
EXEC InsertOrderDetail 697,53,35,163;
EXEC InsertOrderDetail 698,50,15,233;
EXEC InsertOrderDetail 699,36,8,138;
EXEC InsertOrderDetail 700,6,50,537;
EXEC InsertOrderDetail 701,49,44,526;
EXEC InsertOrderDetail 702,3,35,569;
EXEC InsertOrderDetail 703,24,7,486;
EXEC InsertOrderDetail 704,48,38,537;
EXEC InsertOrderDetail 705,42,69,268;
EXEC InsertOrderDetail 706,21,88,424;
EXEC InsertOrderDetail 707,2,34,547;
EXEC InsertOrderDetail 708,24,30,298;
EXEC InsertOrderDetail 709,3,72,525;
EXEC InsertOrderDetail 710,38,11,140;
EXEC InsertOrderDetail 711,52,48,113;
EXEC InsertOrderDetail 712,27,14,131;
EXEC InsertOrderDetail 713,33,55,314;
EXEC InsertOrderDetail 714,32,63,543;
EXEC InsertOrderDetail 715,33,8,36;
EXEC InsertOrderDetail 716,52,31,2;
EXEC InsertOrderDetail 717,44,57,402;
EXEC InsertOrderDetail 718,23,19,567;
EXEC InsertOrderDetail 719,48,84,80;
EXEC InsertOrderDetail 720,37,66,38;
EXEC InsertOrderDetail 721,51,24,284;
EXEC InsertOrderDetail 722,52,41,210;
EXEC InsertOrderDetail 723,52,90,439;
EXEC InsertOrderDetail 724,9,41,401;
EXEC InsertOrderDetail 725,25,72,536;
EXEC InsertOrderDetail 726,18,58,35;
EXEC InsertOrderDetail 727,40,57,108;
EXEC InsertOrderDetail 728,1,75,281;
EXEC InsertOrderDetail 729,32,1,199;
EXEC InsertOrderDetail 730,21,2,588;
EXEC InsertOrderDetail 731,9,77,47;
EXEC InsertOrderDetail 732,15,51,374;
EXEC InsertOrderDetail 733,36,91,13;
EXEC InsertOrderDetail 734,41,69,192;
EXEC InsertOrderDetail 735,53,67,5;
EXEC InsertOrderDetail 736,13,95,455;
EXEC InsertOrderDetail 737,38,18,136;
EXEC InsertOrderDetail 738,8,90,546;
EXEC InsertOrderDetail 739,19,62,283;
EXEC InsertOrderDetail 740,33,8,181;
EXEC InsertOrderDetail 741,53,1,522;
EXEC InsertOrderDetail 742,46,37,304;
EXEC InsertOrderDetail 743,37,66,240;
EXEC InsertOrderDetail 744,19,95,121;
EXEC InsertOrderDetail 745,36,11,524;
EXEC InsertOrderDetail 746,8,55,374;
EXEC InsertOrderDetail 747,37,67,82;
EXEC InsertOrderDetail 748,38,39,496;
EXEC InsertOrderDetail 749,21,1,329;
EXEC InsertOrderDetail 750,36,64,414;
EXEC InsertOrderDetail 751,28,88,333;
EXEC InsertOrderDetail 752,31,69,235;
EXEC InsertOrderDetail 753,29,43,366;
EXEC InsertOrderDetail 754,1,61,88;
EXEC InsertOrderDetail 755,53,59,48;
EXEC InsertOrderDetail 756,21,20,243;
EXEC InsertOrderDetail 757,26,78,443;
EXEC InsertOrderDetail 758,43,20,90;
EXEC InsertOrderDetail 759,34,90,232;
EXEC InsertOrderDetail 760,4,63,51;
EXEC InsertOrderDetail 761,9,88,321;
EXEC InsertOrderDetail 762,30,36,406;
EXEC InsertOrderDetail 763,6,46,431;
EXEC InsertOrderDetail 764,18,10,557;
EXEC InsertOrderDetail 765,10,48,114;
EXEC InsertOrderDetail 766,24,31,367;
EXEC InsertOrderDetail 767,5,55,106;
EXEC InsertOrderDetail 768,19,57,55;
EXEC InsertOrderDetail 769,36,56,460;
EXEC InsertOrderDetail 770,43,44,267;
EXEC InsertOrderDetail 771,5,100,386;
EXEC InsertOrderDetail 772,17,65,239;
EXEC InsertOrderDetail 773,26,52,92;
EXEC InsertOrderDetail 774,1,13,392;
EXEC InsertOrderDetail 775,27,14,206;
EXEC InsertOrderDetail 776,34,55,377;
EXEC InsertOrderDetail 777,15,88,234;
EXEC InsertOrderDetail 778,36,59,47;
EXEC InsertOrderDetail 779,19,85,89;
EXEC InsertOrderDetail 780,32,78,430;
EXEC InsertOrderDetail 781,11,47,294;
EXEC InsertOrderDetail 782,53,95,387;
EXEC InsertOrderDetail 783,43,11,230;
EXEC InsertOrderDetail 784,19,27,465;
EXEC InsertOrderDetail 785,27,9,383;
EXEC InsertOrderDetail 786,49,10,454;
EXEC InsertOrderDetail 787,45,78,319;
EXEC InsertOrderDetail 788,3,70,3;
EXEC InsertOrderDetail 789,47,8,28;
EXEC InsertOrderDetail 790,10,98,465;
EXEC InsertOrderDetail 791,22,23,154;
EXEC InsertOrderDetail 792,53,15,276;
EXEC InsertOrderDetail 793,32,80,298;
EXEC InsertOrderDetail 794,42,10,335;
EXEC InsertOrderDetail 795,6,63,395;
EXEC InsertOrderDetail 796,30,64,342;
EXEC InsertOrderDetail 797,42,43,81;
EXEC InsertOrderDetail 798,28,2,6;
EXEC InsertOrderDetail 799,30,29,36;
EXEC InsertOrderDetail 800,52,99,474;
EXEC InsertOrderDetail 801,31,36,272;
EXEC InsertOrderDetail 802,47,42,270;
EXEC InsertOrderDetail 803,22,42,258;
EXEC InsertOrderDetail 804,39,70,186;
EXEC InsertOrderDetail 805,31,30,291;
EXEC InsertOrderDetail 806,6,87,261;
EXEC InsertOrderDetail 807,30,98,419;
EXEC InsertOrderDetail 808,47,44,448;
EXEC InsertOrderDetail 809,47,89,566;
EXEC InsertOrderDetail 810,20,49,73;
EXEC InsertOrderDetail 811,20,61,378;
EXEC InsertOrderDetail 812,11,8,150;
EXEC InsertOrderDetail 813,1,14,295;
EXEC InsertOrderDetail 814,29,83,565;
EXEC InsertOrderDetail 815,2,14,86;
EXEC InsertOrderDetail 816,35,88,260;
EXEC InsertOrderDetail 817,33,33,198;
EXEC InsertOrderDetail 818,32,46,129;
EXEC InsertOrderDetail 819,12,21,54;
EXEC InsertOrderDetail 820,1,83,390;
EXEC InsertOrderDetail 821,29,78,488;
EXEC InsertOrderDetail 822,30,13,17;
EXEC InsertOrderDetail 823,12,52,241;
EXEC InsertOrderDetail 824,15,35,524;
EXEC InsertOrderDetail 825,50,2,440;
EXEC InsertOrderDetail 826,3,3,300;
EXEC InsertOrderDetail 827,13,96,547;
EXEC InsertOrderDetail 828,2,88,600;
EXEC InsertOrderDetail 829,13,80,476;
EXEC InsertOrderDetail 830,3,84,426;
EXEC InsertOrderDetail 831,13,6,330;
EXEC InsertOrderDetail 832,50,89,151;
EXEC InsertOrderDetail 833,48,48,224;
EXEC InsertOrderDetail 834,19,56,226;
EXEC InsertOrderDetail 835,9,35,516;
EXEC InsertOrderDetail 836,9,56,283;
EXEC InsertOrderDetail 837,55,30,67;
EXEC InsertOrderDetail 838,34,70,538;
EXEC InsertOrderDetail 839,41,96,271;
EXEC InsertOrderDetail 840,44,79,490;
EXEC InsertOrderDetail 841,14,17,480;
EXEC InsertOrderDetail 842,23,25,544;
EXEC InsertOrderDetail 843,2,69,70;
EXEC InsertOrderDetail 844,3,12,347;
EXEC InsertOrderDetail 845,21,54,239;
EXEC InsertOrderDetail 846,35,4,37;
EXEC InsertOrderDetail 847,41,30,25;
EXEC InsertOrderDetail 848,49,41,100;
EXEC InsertOrderDetail 849,41,19,318;
EXEC InsertOrderDetail 850,19,71,147;
EXEC InsertOrderDetail 851,14,35,354;
EXEC InsertOrderDetail 852,28,26,193;
EXEC InsertOrderDetail 853,3,69,584;
EXEC InsertOrderDetail 854,46,94,400;
EXEC InsertOrderDetail 855,19,14,429;
EXEC InsertOrderDetail 856,52,71,218;
EXEC InsertOrderDetail 857,9,20,37;
EXEC InsertOrderDetail 858,18,68,337;
EXEC InsertOrderDetail 859,32,70,299;
EXEC InsertOrderDetail 860,46,37,458;
EXEC InsertOrderDetail 861,6,8,167;
EXEC InsertOrderDetail 862,3,66,61;
EXEC InsertOrderDetail 863,44,22,292;
EXEC InsertOrderDetail 864,3,19,69;
EXEC InsertOrderDetail 865,28,75,382;
EXEC InsertOrderDetail 866,41,17,568;
EXEC InsertOrderDetail 867,55,30,173;
EXEC InsertOrderDetail 868,1,18,282;
EXEC InsertOrderDetail 869,42,5,590;
EXEC InsertOrderDetail 870,14,3,592;
EXEC InsertOrderDetail 871,30,46,282;
EXEC InsertOrderDetail 872,45,48,383;
EXEC InsertOrderDetail 873,31,10,130;
EXEC InsertOrderDetail 874,38,33,511;
EXEC InsertOrderDetail 875,23,91,15;
EXEC InsertOrderDetail 876,47,22,372;
EXEC InsertOrderDetail 877,28,70,348;
EXEC InsertOrderDetail 878,54,71,222;
EXEC InsertOrderDetail 879,7,29,5;
EXEC InsertOrderDetail 880,35,29,34;
EXEC InsertOrderDetail 881,12,28,475;
EXEC InsertOrderDetail 882,22,50,462;
EXEC InsertOrderDetail 883,51,51,148;
EXEC InsertOrderDetail 884,37,93,293;
EXEC InsertOrderDetail 885,2,61,482;
EXEC InsertOrderDetail 886,52,26,477;
EXEC InsertOrderDetail 887,37,72,305;
EXEC InsertOrderDetail 888,10,36,3;
EXEC InsertOrderDetail 889,33,66,418;
EXEC InsertOrderDetail 890,42,81,556;
EXEC InsertOrderDetail 891,39,55,102;
EXEC InsertOrderDetail 892,48,42,192;
EXEC InsertOrderDetail 893,23,93,308;
EXEC InsertOrderDetail 894,54,8,259;
EXEC InsertOrderDetail 895,11,80,554;
EXEC InsertOrderDetail 896,33,91,320;
EXEC InsertOrderDetail 897,41,73,431;
EXEC InsertOrderDetail 898,9,14,187;
EXEC InsertOrderDetail 899,12,4,180;
EXEC InsertOrderDetail 900,34,99,591;
EXEC InsertOrderDetail 901,24,31,129;
EXEC InsertOrderDetail 902,14,85,184;
EXEC InsertOrderDetail 903,15,42,578;
EXEC InsertOrderDetail 904,21,36,189;
EXEC InsertOrderDetail 905,4,36,252;
EXEC InsertOrderDetail 906,53,97,86;
EXEC InsertOrderDetail 907,18,68,510;
EXEC InsertOrderDetail 908,22,100,85;
EXEC InsertOrderDetail 909,43,13,323;
EXEC InsertOrderDetail 910,22,70,329;
EXEC InsertOrderDetail 911,52,75,403;
EXEC InsertOrderDetail 912,14,37,68;
EXEC InsertOrderDetail 913,19,32,142;
EXEC InsertOrderDetail 914,21,70,338;
EXEC InsertOrderDetail 915,47,34,296;
EXEC InsertOrderDetail 916,40,51,310;
EXEC InsertOrderDetail 917,45,37,398;
EXEC InsertOrderDetail 918,42,2,463;
EXEC InsertOrderDetail 919,39,11,473;
EXEC InsertOrderDetail 920,33,31,476;
EXEC InsertOrderDetail 921,53,59,499;
EXEC InsertOrderDetail 922,48,79,350;
EXEC InsertOrderDetail 923,55,31,248;
EXEC InsertOrderDetail 924,8,76,161;
EXEC InsertOrderDetail 925,19,31,351;
EXEC InsertOrderDetail 926,37,44,242;
EXEC InsertOrderDetail 927,11,60,85;
EXEC InsertOrderDetail 928,36,7,428;
EXEC InsertOrderDetail 929,35,94,120;
EXEC InsertOrderDetail 930,37,26,469;
EXEC InsertOrderDetail 931,16,43,171;
EXEC InsertOrderDetail 932,18,4,373;
EXEC InsertOrderDetail 933,14,63,165;
EXEC InsertOrderDetail 934,28,3,306;
EXEC InsertOrderDetail 935,20,93,303;
EXEC InsertOrderDetail 936,35,33,325;
EXEC InsertOrderDetail 937,28,17,59;
EXEC InsertOrderDetail 938,12,61,92;
EXEC InsertOrderDetail 939,42,25,139;
EXEC InsertOrderDetail 940,25,32,44;
EXEC InsertOrderDetail 941,8,77,144;
EXEC InsertOrderDetail 942,39,92,138;
EXEC InsertOrderDetail 943,10,77,384;
EXEC InsertOrderDetail 944,40,12,105;
EXEC InsertOrderDetail 945,36,93,243;
EXEC InsertOrderDetail 946,53,49,597;
EXEC InsertOrderDetail 947,54,54,191;
EXEC InsertOrderDetail 948,50,52,564;
EXEC InsertOrderDetail 949,52,88,324;
EXEC InsertOrderDetail 950,48,88,23;
EXEC InsertOrderDetail 951,7,92,133;
EXEC InsertOrderDetail 952,1,67,256;
EXEC InsertOrderDetail 953,50,78,548;
EXEC InsertOrderDetail 954,15,86,203;
EXEC InsertOrderDetail 955,26,3,509;
EXEC InsertOrderDetail 956,33,94,160;
EXEC InsertOrderDetail 957,45,4,345;
EXEC InsertOrderDetail 958,55,2,41;
EXEC InsertOrderDetail 959,13,91,310;
EXEC InsertOrderDetail 960,48,46,137;
EXEC InsertOrderDetail 961,21,7,587;
EXEC InsertOrderDetail 962,55,34,63;
EXEC InsertOrderDetail 963,12,30,464;
EXEC InsertOrderDetail 964,41,54,420;
EXEC InsertOrderDetail 965,4,92,194;
EXEC InsertOrderDetail 966,44,24,272;
EXEC InsertOrderDetail 967,42,11,349;
EXEC InsertOrderDetail 968,39,58,437;
EXEC InsertOrderDetail 969,24,35,573;
EXEC InsertOrderDetail 970,26,87,448;
EXEC InsertOrderDetail 971,25,75,561;
EXEC InsertOrderDetail 972,14,93,22;
EXEC InsertOrderDetail 973,44,74,165;
EXEC InsertOrderDetail 974,30,91,327;
EXEC InsertOrderDetail 975,29,6,550;
EXEC InsertOrderDetail 976,18,41,574;
EXEC InsertOrderDetail 977,55,1,440;
EXEC InsertOrderDetail 978,42,69,251;
EXEC InsertOrderDetail 979,40,86,149;
EXEC InsertOrderDetail 980,42,17,29;
EXEC InsertOrderDetail 981,35,71,470;
EXEC InsertOrderDetail 982,55,60,331;
EXEC InsertOrderDetail 983,16,15,183;
EXEC InsertOrderDetail 984,37,45,593;
EXEC InsertOrderDetail 985,6,68,404;
EXEC InsertOrderDetail 986,20,75,334;
EXEC InsertOrderDetail 987,46,71,435;
EXEC InsertOrderDetail 988,2,44,532;
EXEC InsertOrderDetail 989,34,76,363;
EXEC InsertOrderDetail 990,14,57,211;
EXEC InsertOrderDetail 991,41,40,190;
EXEC InsertOrderDetail 992,35,22,87;
EXEC InsertOrderDetail 993,29,29,7;
EXEC InsertOrderDetail 994,18,56,83;
EXEC InsertOrderDetail 995,18,52,527;
EXEC InsertOrderDetail 996,39,98,256;
EXEC InsertOrderDetail 997,2,69,541;
EXEC InsertOrderDetail 998,14,82,107;
EXEC InsertOrderDetail 999,44,96,130;
EXEC InsertOrderDetail 1000,27,20,21;

--Insertion in VehicleCharges:
EXEC InsertVehicleCharge 'mazda',5000;
EXEC InsertVehicleCharge 'rikshaw loader',2000
--Insertion in Carriage:
EXEC InsertCarriage 1, 'Sahil Qureshi', 'rikshaw loader';
EXEC InsertCarriage 2, 'Omar Aslam', 'rikshaw loader';
EXEC InsertCarriage 3, 'Omar Aslam', 'rikshaw loader';
EXEC InsertCarriage 4, 'Danish Shah', 'rikshaw loader';
EXEC InsertCarriage 5, 'Muhammad Usman', 'mazda';
EXEC InsertCarriage 6, 'Ibrahim Khan', 'rikshaw loader';
EXEC InsertCarriage 7, 'Amanullah Chaudhry', 'mazda';
EXEC InsertCarriage 8, 'Hassan Javed', 'mazda';
EXEC InsertCarriage 9, 'Saqib Iqbal', 'mazda';
EXEC InsertCarriage 10, 'Amanullah Chaudhry', 'rikshaw loader';
EXEC InsertCarriage 11, 'Hassan Javed', 'mazda';
EXEC InsertCarriage 12, 'Zain Ali', 'mazda';
EXEC InsertCarriage 13, 'Afzal Khan', 'mazda';
EXEC InsertCarriage 14, 'Zain Ali', 'mazda';
EXEC InsertCarriage 15, 'Maaz Siddiqui', 'rikshaw loader';
EXEC InsertCarriage 16, 'Hassan Javed', 'mazda';
EXEC InsertCarriage 17, 'Maaz Siddiqui', 'rikshaw loader';
EXEC InsertCarriage 18, 'Khan Aziz', 'rikshaw loader';
EXEC InsertCarriage 19, 'Danish Shah', 'rikshaw loader';
EXEC InsertCarriage 20, 'Zain Ali', 'mazda';
EXEC InsertCarriage 21, 'Zain Ali', 'rikshaw loader';
EXEC InsertCarriage 22, 'Maaz Siddiqui', 'mazda';
EXEC InsertCarriage 23, 'Danish Shah', 'rikshaw loader';
EXEC InsertCarriage 24, 'Bilal Ahmed', 'rikshaw loader';
EXEC InsertCarriage 25, 'Nadir Zahid', 'mazda';
EXEC InsertCarriage 26, 'Tahir Tariq', 'rikshaw loader';
EXEC InsertCarriage 27, 'Hamza Iqbal', 'rikshaw loader';
EXEC InsertCarriage 28, 'Ali Haider', 'mazda';
EXEC InsertCarriage 29, 'Danish Shah', 'rikshaw loader';
EXEC InsertCarriage 30, 'Hamza Iqbal', 'mazda';
EXEC InsertCarriage 31, 'Sahil Qureshi', 'mazda';
EXEC InsertCarriage 32, 'Sahil Qureshi', 'mazda';
EXEC InsertCarriage 33, 'Ibrahim Khan', 'mazda';
EXEC InsertCarriage 34, 'Ali Haider', 'mazda';
EXEC InsertCarriage 35, 'Saqib Iqbal', 'mazda';
EXEC InsertCarriage 36, 'Maaz Siddiqui', 'rikshaw loader';
EXEC InsertCarriage 37, 'Saqib Iqbal', 'mazda';
EXEC InsertCarriage 38, 'Zain Raza', 'rikshaw loader';
EXEC InsertCarriage 39, 'Muhammad Usman', 'rikshaw loader';
EXEC InsertCarriage 40, 'Rashid Noor', 'rikshaw loader';
EXEC InsertCarriage 41, 'Ali Khan', 'mazda';
EXEC InsertCarriage 42, 'Bilal Ahmed', 'rikshaw loader';
EXEC InsertCarriage 43, 'Abdullah Malik', 'rikshaw loader';
EXEC InsertCarriage 44, 'Rizwan Ahmed', 'rikshaw loader';
EXEC InsertCarriage 45, 'Tayyab Ali', 'mazda';
EXEC InsertCarriage 46, 'Saqib Iqbal', 'rikshaw loader';
EXEC InsertCarriage 47, 'Tayyab Ali', 'mazda';
EXEC InsertCarriage 48, 'Khan Aziz', 'mazda';
EXEC InsertCarriage 49, 'Zain Raza', 'mazda';
EXEC InsertCarriage 50, 'Rizwan Ahmed', 'rikshaw loader';
EXEC InsertCarriage 51, 'Saqib Iqbal', 'mazda';
EXEC InsertCarriage 52, 'Tayyab Ali', 'mazda';
EXEC InsertCarriage 53, 'Danish Shah', 'mazda';
EXEC InsertCarriage 54, 'Tahir Tariq', 'rikshaw loader';
EXEC InsertCarriage 55, 'Hassan Javed', 'mazda';
EXEC InsertCarriage 56, 'Rashid Noor', 'mazda';
EXEC InsertCarriage 57, 'Ahmed Ali', 'rikshaw loader';
EXEC InsertCarriage 58, 'Hamza Iqbal', 'mazda';
EXEC InsertCarriage 59, 'Zain Raza', 'rikshaw loader';
EXEC InsertCarriage 60, 'Ahmed Ali', 'rikshaw loader';
EXEC InsertCarriage 61, 'Ibrahim Khan', 'mazda';
EXEC InsertCarriage 62, 'Afzal Khan', 'mazda';
EXEC InsertCarriage 63, 'Ahmed Ali', 'rikshaw loader';
EXEC InsertCarriage 64, 'Shehryar Faisal', 'mazda';
EXEC InsertCarriage 65, 'Maaz Siddiqui', 'rikshaw loader';
EXEC InsertCarriage 66, 'Danish Shah', 'mazda';
EXEC InsertCarriage 67, 'Ali Haider', 'mazda';
EXEC InsertCarriage 68, 'Saqib Iqbal', 'rikshaw loader';
EXEC InsertCarriage 69, 'Omar Aslam', 'mazda';
EXEC InsertCarriage 70, 'Saqib Iqbal', 'rikshaw loader';
EXEC InsertCarriage 71, 'Saqib Iqbal', 'mazda';
EXEC InsertCarriage 72, 'Omar Aslam', 'rikshaw loader';
EXEC InsertCarriage 73, 'Abdullah Malik', 'mazda';
EXEC InsertCarriage 74, 'Rizwan Ahmed', 'mazda';
EXEC InsertCarriage 75, 'Hassan Javed', 'rikshaw loader';
EXEC InsertCarriage 76, 'Ali Khan', 'mazda';
EXEC InsertCarriage 77, 'Amanullah Chaudhry', 'mazda';
EXEC InsertCarriage 78, 'Muhammad Usman', 'mazda';
EXEC InsertCarriage 79, 'Omar Aslam', 'mazda';
EXEC InsertCarriage 80, 'Muhammad Usman', 'rikshaw loader';
EXEC InsertCarriage 81, 'Tayyab Ali', 'mazda';
EXEC InsertCarriage 82, 'Amanullah Chaudhry', 'mazda';
EXEC InsertCarriage 83, 'Bilal Ahmed', 'rikshaw loader';
EXEC InsertCarriage 84, 'Shehryar Faisal', 'rikshaw loader';
EXEC InsertCarriage 85, 'Muhammad Usman', 'rikshaw loader';
EXEC InsertCarriage 86, 'Khan Aziz', 'mazda';
EXEC InsertCarriage 87, 'Rashid Noor', 'mazda';
EXEC InsertCarriage 88, 'Afzal Khan', 'mazda';
EXEC InsertCarriage 89, 'Nadir Zahid', 'rikshaw loader';
EXEC InsertCarriage 90, 'Bilal Ahmed', 'mazda';
EXEC InsertCarriage 91, 'Saqib Iqbal', 'mazda';
EXEC InsertCarriage 92, 'Tayyab Ali', 'rikshaw loader';
EXEC InsertCarriage 93, 'Omar Aslam', 'rikshaw loader';
EXEC InsertCarriage 94, 'Hamza Iqbal', 'mazda';
EXEC InsertCarriage 95, 'Abdullah Malik', 'rikshaw loader';
EXEC InsertCarriage 96, 'Omar Aslam', 'mazda';
EXEC InsertCarriage 97, 'Sahil Qureshi', 'mazda';
EXEC InsertCarriage 98, 'Bilal Ahmed', 'rikshaw loader';
EXEC InsertCarriage 99, 'Omar Aslam', 'mazda';
EXEC InsertCarriage 100, 'Amanullah Chaudhry', 'mazda';
EXEC InsertCarriage 101, 'Bilal Ahmed', 'mazda';
EXEC InsertCarriage 102, 'Abdullah Malik', 'rikshaw loader';
EXEC InsertCarriage 103, 'Hamza Iqbal', 'rikshaw loader';
EXEC InsertCarriage 104, 'Amanullah Chaudhry', 'mazda';
EXEC InsertCarriage 105, 'Omar Aslam', 'rikshaw loader';
EXEC InsertCarriage 106, 'Hamza Iqbal', 'mazda';
EXEC InsertCarriage 107, 'Shehryar Faisal', 'mazda';
EXEC InsertCarriage 108, 'Bilal Ahmed', 'rikshaw loader';
EXEC InsertCarriage 109, 'Ibrahim Khan', 'rikshaw loader';
EXEC InsertCarriage 110, 'Saqib Iqbal', 'rikshaw loader';
EXEC InsertCarriage 111, 'Tahir Tariq', 'rikshaw loader';
EXEC InsertCarriage 112, 'Abdullah Malik', 'mazda';
EXEC InsertCarriage 113, 'Sahil Qureshi', 'mazda';
EXEC InsertCarriage 114, 'Abdullah Malik', 'rikshaw loader';
EXEC InsertCarriage 115, 'Danish Shah', 'mazda';
EXEC InsertCarriage 116, 'Nadir Zahid', 'mazda';
EXEC InsertCarriage 117, 'Maaz Siddiqui', 'rikshaw loader';
EXEC InsertCarriage 118, 'Ali Haider', 'rikshaw loader';
EXEC InsertCarriage 119, 'Rizwan Ahmed', 'rikshaw loader';
EXEC InsertCarriage 120, 'Danish Shah', 'mazda';
EXEC InsertCarriage 121, 'Khan Aziz', 'rikshaw loader';
EXEC InsertCarriage 122, 'Abdullah Malik', 'rikshaw loader';
EXEC InsertCarriage 123, 'Abdullah Malik', 'mazda';
EXEC InsertCarriage 124, 'Amanullah Chaudhry', 'mazda';
EXEC InsertCarriage 125, 'Zain Ali', 'mazda';
EXEC InsertCarriage 126, 'Ahmed Ali', 'rikshaw loader';
EXEC InsertCarriage 127, 'Omar Aslam', 'mazda';
EXEC InsertCarriage 128, 'Muhammad Usman', 'rikshaw loader';
EXEC InsertCarriage 129, 'Zain Ali', 'rikshaw loader';
EXEC InsertCarriage 130, 'Rashid Noor', 'mazda';
EXEC InsertCarriage 131, 'Ali Haider', 'rikshaw loader';
EXEC InsertCarriage 132, 'Danish Shah', 'mazda';
EXEC InsertCarriage 133, 'Ali Haider', 'rikshaw loader';
EXEC InsertCarriage 134, 'Ahmed Ali', 'rikshaw loader';
EXEC InsertCarriage 135, 'Ali Haider', 'rikshaw loader';
EXEC InsertCarriage 136, 'Omar Aslam', 'rikshaw loader';
EXEC InsertCarriage 137, 'Ahmed Ali', 'mazda';
EXEC InsertCarriage 138, 'Abdullah Malik', 'mazda';
EXEC InsertCarriage 139, 'Zain Raza', 'rikshaw loader';
EXEC InsertCarriage 140, 'Rashid Noor', 'mazda';
EXEC InsertCarriage 141, 'Bilal Ahmed', 'rikshaw loader';
EXEC InsertCarriage 142, 'Rizwan Ahmed', 'rikshaw loader';
EXEC InsertCarriage 143, 'Zain Ali', 'rikshaw loader';
EXEC InsertCarriage 144, 'Khan Aziz', 'rikshaw loader';
EXEC InsertCarriage 145, 'Hassan Javed', 'rikshaw loader';
EXEC InsertCarriage 146, 'Tayyab Ali', 'mazda';
EXEC InsertCarriage 147, 'Ibrahim Khan', 'mazda';
EXEC InsertCarriage 148, 'Bilal Ahmed', 'rikshaw loader';
EXEC InsertCarriage 149, 'Ali Khan', 'rikshaw loader';
EXEC InsertCarriage 150, 'Ali Haider', 'rikshaw loader';
Select * from ProductPurchase
EXEC InsertProductPurchase 22, '2024-04-17 14:23:27', 27;
EXEC InsertProductPurchase 48, '2023-09-08 15:17:00', 4;
EXEC InsertProductPurchase 37, '2024-01-19 15:05:48', 16;
EXEC InsertProductPurchase 43, '2024-01-20 14:57:03', 64;
EXEC InsertProductPurchase 11, '2024-03-05 16:12:34', 25;
EXEC InsertProductPurchase 22, '2024-02-12 03:01:35', 3;
EXEC InsertProductPurchase 25, '2023-11-09 02:27:37', 83;
EXEC InsertProductPurchase 35, '2024-02-21 14:56:59', 39;
EXEC InsertProductPurchase 2, '2023-12-19 22:50:07', 75;
EXEC InsertProductPurchase 15, '2023-07-10 22:15:03', 11;
EXEC InsertProductPurchase 7, '2024-01-29 17:42:28', 68;
EXEC InsertProductPurchase 41, '2023-07-12 23:52:31', 58;
EXEC InsertProductPurchase 19, '2023-07-28 10:02:24', 4;
EXEC InsertProductPurchase 26, '2023-11-15 13:08:38', 37;
EXEC InsertProductPurchase 55, '2023-08-09 13:26:42', 64;
EXEC InsertProductPurchase 29, '2023-10-17 01:14:31', 57;
EXEC InsertProductPurchase 43, '2024-03-22 11:56:32', 99;
EXEC InsertProductPurchase 36, '2024-01-26 07:38:11', 94;
EXEC InsertProductPurchase 25, '2023-08-05 03:36:42', 7;
EXEC InsertProductPurchase 19, '2023-12-10 14:53:34', 44;
EXEC InsertProductPurchase 1, '2024-05-27 11:05:32', 67;
EXEC InsertProductPurchase 54, '2024-01-12 07:48:00', 68;
EXEC InsertProductPurchase 54, '2023-10-06 12:28:10', 74;
EXEC InsertProductPurchase 45, '2023-11-29 00:28:39', 11;
EXEC InsertProductPurchase 54, '2024-02-02 04:13:24', 4;
EXEC InsertProductPurchase 44, '2023-10-20 15:45:25', 14;
EXEC InsertProductPurchase 43, '2024-05-20 01:59:00', 34;
EXEC InsertProductPurchase 22, '2023-09-15 07:50:11', 22;
EXEC InsertProductPurchase 18, '2024-01-04 20:33:57', 44;
EXEC InsertProductPurchase 46, '2023-11-18 06:49:40', 25;
EXEC InsertProductPurchase 5, '2023-09-21 09:21:04', 95;
EXEC InsertProductPurchase 45, '2023-08-09 10:00:22', 90;
EXEC InsertProductPurchase 27, '2023-07-19 14:23:29', 76;
EXEC InsertProductPurchase 38, '2023-09-06 18:56:57', 24;
EXEC InsertProductPurchase 27, '2024-01-23 21:04:40', 21;
EXEC InsertProductPurchase 24, '2024-01-14 15:51:11', 81;
EXEC InsertProductPurchase 20, '2023-07-12 21:10:21', 64;
EXEC InsertProductPurchase 33, '2023-06-01 08:58:46', 34;
EXEC InsertProductPurchase 17, '2023-06-10 04:07:59', 7;
EXEC InsertProductPurchase 36, '2023-12-15 06:20:15', 59;
EXEC InsertProductPurchase 14, '2024-04-28 10:17:09', 8;
EXEC InsertProductPurchase 49, '2024-03-18 03:42:23', 58;
EXEC InsertProductPurchase 27, '2024-03-22 04:41:16', 71;
EXEC InsertProductPurchase 10, '2023-08-21 18:26:16', 35;
EXEC InsertProductPurchase 3, '2023-08-14 14:37:54', 60;
EXEC InsertProductPurchase 28, '2023-09-17 00:00:20', 87;
EXEC InsertProductPurchase 10, '2023-08-19 01:40:39', 61;
EXEC InsertProductPurchase 2, '2024-04-06 02:31:31', 86;
EXEC InsertProductPurchase 2, '2023-06-29 23:25:13', 19;
EXEC InsertProductPurchase 4, '2023-11-02 13:48:45', 6;
EXEC InsertProductPurchase 42, '2023-08-23 06:22:25', 53;
EXEC InsertProductPurchase 19, '2023-08-06 12:58:25', 13;
EXEC InsertProductPurchase 27, '2023-08-20 12:20:47', 54;
EXEC InsertProductPurchase 40, '2024-02-25 04:36:01', 41;
EXEC InsertProductPurchase 37, '2023-08-24 09:16:59', 11;
EXEC InsertProductPurchase 55, '2023-12-02 11:19:30', 76;
EXEC InsertProductPurchase 2, '2024-05-05 12:08:39', 42;
EXEC InsertProductPurchase 44, '2024-05-10 07:58:32', 49;
EXEC InsertProductPurchase 13, '2023-12-10 01:37:43', 82;
EXEC InsertProductPurchase 18, '2024-01-17 01:55:32', 44;
EXEC InsertProductPurchase 6, '2024-05-02 14:23:43', 17;
EXEC InsertProductPurchase 15, '2024-05-23 06:47:19', 76;
EXEC InsertProductPurchase 22, '2023-12-14 11:31:31', 12;
EXEC InsertProductPurchase 13, '2024-05-02 10:34:35', 30;
EXEC InsertProductPurchase 50, '2023-08-09 09:47:01', 81;
EXEC InsertProductPurchase 2, '2024-05-20 04:03:56', 95;
EXEC InsertProductPurchase 50, '2023-11-01 07:44:40', 42;
EXEC InsertProductPurchase 36, '2023-07-26 16:52:21', 15;
EXEC InsertProductPurchase 53, '2024-02-21 10:36:27', 74;
EXEC InsertProductPurchase 43, '2023-12-20 18:06:58', 39;
EXEC InsertProductPurchase 44, '2024-01-15 16:56:09', 89;
EXEC InsertProductPurchase 39, '2024-05-14 22:02:32', 94;
EXEC InsertProductPurchase 29, '2024-03-12 20:39:43', 49;
EXEC InsertProductPurchase 41, '2024-02-28 06:51:03', 9;
EXEC InsertProductPurchase 11, '2024-01-15 14:21:48', 92;
EXEC InsertProductPurchase 7, '2023-06-29 22:59:15', 20;
EXEC InsertProductPurchase 21, '2023-06-09 07:29:25', 41;
EXEC InsertProductPurchase 5, '2024-01-04 06:43:58', 9;
EXEC InsertProductPurchase 24, '2023-09-17 18:45:44', 2;
EXEC InsertProductPurchase 5, '2023-09-30 20:47:00', 44;
EXEC InsertProductPurchase 55, '2023-12-31 09:51:08', 81;
EXEC InsertProductPurchase 54, '2024-02-26 21:21:05', 85;
EXEC InsertProductPurchase 18, '2023-11-16 07:19:23', 79;
EXEC InsertProductPurchase 26, '2023-12-26 18:09:45', 18;
EXEC InsertProductPurchase 8, '2024-05-13 18:26:25', 62;
EXEC InsertProductPurchase 41, '2023-10-01 02:51:18', 51;
EXEC InsertProductPurchase 36, '2024-02-09 21:08:32', 13;
EXEC InsertProductPurchase 13, '2023-06-18 11:49:02', 2;
EXEC InsertProductPurchase 24, '2024-02-18 09:59:23', 69;
EXEC InsertProductPurchase 47, '2023-09-21 16:54:07', 91;
EXEC InsertProductPurchase 1, '2023-11-01 22:27:19', 96;
EXEC InsertProductPurchase 14, '2024-03-26 05:48:30', 33;
EXEC InsertProductPurchase 4, '2023-11-08 20:04:15', 98;
EXEC InsertProductPurchase 31, '2023-07-15 23:37:01', 65;
EXEC InsertProductPurchase 20, '2023-09-05 23:35:58', 80;
EXEC InsertProductPurchase 47, '2023-11-04 17:21:05', 91;
EXEC InsertProductPurchase 38, '2023-12-31 19:53:43', 11;
EXEC InsertProductPurchase 10, '2023-07-02 16:16:00', 94;
EXEC InsertProductPurchase 2, '2023-07-04 02:17:58', 3;
EXEC InsertProductPurchase 44, '2024-03-27 05:17:17', 42;
EXEC InsertProductPurchase 40, '2023-11-18 09:54:25', 93;
EXEC InsertProductPurchase 7, '2023-11-23 18:11:32', 81;
EXEC InsertProductPurchase 17, '2024-03-27 02:19:01', 39;
EXEC InsertProductPurchase 27, '2023-12-15 11:49:24', 91;
EXEC InsertProductPurchase 33, '2024-05-20 22:23:01', 74;
EXEC InsertProductPurchase 10, '2024-04-28 09:14:07', 19;
EXEC InsertProductPurchase 36, '2023-07-01 11:01:40', 57;
EXEC InsertProductPurchase 46, '2023-10-10 18:51:18', 48;
EXEC InsertProductPurchase 7, '2023-09-24 09:58:40', 7;
EXEC InsertProductPurchase 27, '2024-01-27 17:26:27', 58;
EXEC InsertProductPurchase 26, '2023-12-26 12:26:16', 39;
EXEC InsertProductPurchase 43, '2023-08-18 09:43:12', 17;
EXEC InsertProductPurchase 27, '2024-05-08 11:44:25', 62;
EXEC InsertProductPurchase 48, '2024-01-08 00:39:07', 80;
EXEC InsertProductPurchase 53, '2023-11-06 16:03:40', 79;
EXEC InsertProductPurchase 11, '2023-09-12 09:00:54', 66;
EXEC InsertProductPurchase 53, '2023-10-03 07:06:34', 57;
EXEC InsertProductPurchase 44, '2024-04-07 06:31:51', 88;
EXEC InsertProductPurchase 23, '2023-06-21 06:36:35', 30;
EXEC InsertProductPurchase 40, '2024-02-23 09:28:06', 67;
EXEC InsertProductPurchase 24, '2023-06-05 23:32:11', 80;
EXEC InsertProductPurchase 20, '2023-10-22 17:16:08', 24;
EXEC InsertProductPurchase 33, '2023-12-12 21:18:40', 88;
EXEC InsertProductPurchase 15, '2023-06-20 13:24:13', 45;
EXEC InsertProductPurchase 49, '2023-06-14 11:07:14', 40;
EXEC InsertProductPurchase 8, '2023-08-27 03:18:04', 59;
EXEC InsertProductPurchase 20, '2024-05-19 02:36:10', 91;
EXEC InsertProductPurchase 23, '2024-05-07 13:15:10', 45;
EXEC InsertProductPurchase 8, '2024-04-04 06:45:11', 100;
EXEC InsertProductPurchase 49, '2023-09-21 17:06:34', 19;
EXEC InsertProductPurchase 23, '2023-11-07 04:10:53', 72;
EXEC InsertProductPurchase 10, '2023-10-04 01:40:33', 87;
EXEC InsertProductPurchase 48, '2024-02-19 11:29:30', 73;
EXEC InsertProductPurchase 28, '2024-01-13 15:24:00', 31;
EXEC InsertProductPurchase 6, '2023-07-20 01:12:59', 84;
EXEC InsertProductPurchase 46, '2024-03-15 08:41:17', 13;
EXEC InsertProductPurchase 18, '2024-01-18 19:43:18', 43;
EXEC InsertProductPurchase 48, '2023-11-12 08:35:30', 65;
EXEC InsertProductPurchase 52, '2024-05-10 20:23:51', 67;
EXEC InsertProductPurchase 33, '2023-09-05 16:06:06', 35;
EXEC InsertProductPurchase 12, '2023-08-12 16:33:45', 68;
EXEC InsertProductPurchase 4, '2024-01-05 13:38:43', 27;
EXEC InsertProductPurchase 19, '2024-02-20 13:39:17', 30;
EXEC InsertProductPurchase 11, '2023-10-17 17:13:16', 81;
EXEC InsertProductPurchase 47, '2023-06-24 17:11:44', 2;
EXEC InsertProductPurchase 46, '2023-07-07 03:35:00', 52;
EXEC InsertProductPurchase 50, '2023-09-13 18:20:34', 58;
EXEC InsertProductPurchase 53, '2023-12-03 03:00:54', 20;
EXEC InsertProductPurchase 40, '2023-11-23 06:19:09', 15;
EXEC InsertProductPurchase 15, '2023-06-06 14:11:41', 46;
EXEC InsertProductPurchase 7, '2023-11-08 16:27:03', 18;
EXEC InsertProductPurchase 51, '2023-06-18 09:41:51', 74;
EXEC InsertProductPurchase 29, '2024-04-26 03:01:49', 34;
EXEC InsertProductPurchase 49, '2023-07-19 09:02:30', 33;
EXEC InsertProductPurchase 41, '2023-12-08 18:15:24', 85;
EXEC InsertProductPurchase 26, '2024-01-03 06:32:51', 94;
EXEC InsertProductPurchase 45, '2023-07-26 14:30:12', 36;
EXEC InsertProductPurchase 44, '2023-11-21 12:14:13', 22;
EXEC InsertProductPurchase 9, '2024-05-03 07:11:29', 37;
EXEC InsertProductPurchase 33, '2024-02-01 22:01:12', 8;
EXEC InsertProductPurchase 14, '2023-12-21 04:19:12', 35;
EXEC InsertProductPurchase 28, '2023-11-26 08:15:11', 54;
EXEC InsertProductPurchase 30, '2023-10-19 20:32:37', 60;
EXEC InsertProductPurchase 30, '2023-11-14 16:59:04', 66;
EXEC InsertProductPurchase 41, '2023-09-09 14:45:30', 73;
EXEC InsertProductPurchase 2, '2023-12-13 03:17:43', 48;
EXEC InsertProductPurchase 50, '2024-05-16 07:38:31', 99;
EXEC InsertProductPurchase 28, '2023-09-03 05:04:24', 9;
EXEC InsertProductPurchase 1, '2024-03-12 22:58:51', 36;
EXEC InsertProductPurchase 15, '2023-08-17 15:32:47', 1;
EXEC InsertProductPurchase 27, '2023-07-29 02:41:29', 91;
EXEC InsertProductPurchase 52, '2024-04-08 13:32:30', 5;
EXEC InsertProductPurchase 19, '2024-04-06 08:39:45', 35;
EXEC InsertProductPurchase 51, '2024-03-14 14:42:59', 51;
EXEC InsertProductPurchase 34, '2024-01-08 17:03:31', 21;
EXEC InsertProductPurchase 40, '2023-06-20 00:57:48', 3;
EXEC InsertProductPurchase 6, '2023-08-01 07:15:06', 40;
EXEC InsertProductPurchase 26, '2023-12-02 23:14:02', 59;
EXEC InsertProductPurchase 53, '2024-03-04 08:42:26', 94;
EXEC InsertProductPurchase 46, '2024-02-17 07:57:52', 63;
EXEC InsertProductPurchase 20, '2024-03-18 21:10:38', 3;
EXEC InsertProductPurchase 7, '2024-05-15 09:56:25', 49;
EXEC InsertProductPurchase 37, '2023-12-16 23:13:40', 56;
EXEC InsertProductPurchase 8, '2023-08-09 15:41:26', 3;
EXEC InsertProductPurchase 29, '2023-11-18 07:29:36', 96;
EXEC InsertProductPurchase 26, '2024-01-19 14:40:07', 59;
EXEC InsertProductPurchase 37, '2023-09-03 12:33:57', 42;
EXEC InsertProductPurchase 36, '2024-03-21 14:52:37', 46;
EXEC InsertProductPurchase 29, '2023-12-08 07:00:35', 56;
EXEC InsertProductPurchase 42, '2024-02-09 20:34:25', 4;
EXEC InsertProductPurchase 7, '2023-06-27 22:38:08', 38;
EXEC InsertProductPurchase 7, '2024-01-22 05:01:54', 67;
EXEC InsertProductPurchase 10, '2023-07-27 04:41:51', 51;
EXEC InsertProductPurchase 17, '2024-05-22 05:17:42', 11;
EXEC InsertProductPurchase 6, '2024-03-18 22:11:33', 94;
EXEC InsertProductPurchase 31, '2024-01-02 13:55:02', 10;
EXEC InsertProductPurchase 6, '2023-12-28 17:48:05', 27;
EXEC InsertProductPurchase 29, '2023-09-07 22:06:57', 28;
EXEC InsertProductPurchase 26, '2023-11-21 21:45:27', 85;
EXEC InsertProductPurchase 22, '2023-11-14 04:20:45', 86;
EXEC InsertProductPurchase 38, '2023-09-13 12:48:26', 34;
EXEC InsertProductPurchase 33, '2024-05-12 04:26:48', 69;
EXEC InsertProductPurchase 10, '2024-03-18 00:01:45', 87;
EXEC InsertProductPurchase 17, '2023-08-09 09:34:02', 79;
EXEC InsertProductPurchase 53, '2023-07-31 13:30:05', 5;
EXEC InsertProductPurchase 50, '2023-10-16 08:02:10', 21;
EXEC InsertProductPurchase 51, '2024-05-08 08:12:41', 96;
EXEC InsertProductPurchase 12, '2023-11-04 02:49:22', 88;
EXEC InsertProductPurchase 41, '2023-06-05 23:28:48', 87;
EXEC InsertProductPurchase 21, '2023-12-08 23:19:22', 2;
EXEC InsertProductPurchase 4, '2023-12-28 16:02:59', 36;
EXEC InsertProductPurchase 14, '2023-10-07 08:19:53', 56;
EXEC InsertProductPurchase 28, '2023-09-20 15:33:03', 65;
EXEC InsertProductPurchase 28, '2024-03-06 15:19:54', 36;
EXEC InsertProductPurchase 26, '2023-10-26 20:39:42', 19;
EXEC InsertProductPurchase 33, '2024-03-06 07:08:40', 54;
EXEC InsertProductPurchase 35, '2024-03-11 22:46:29', 12;
EXEC InsertProductPurchase 26, '2023-09-11 20:26:21', 18;
EXEC InsertProductPurchase 46, '2023-10-23 11:46:08', 67;
EXEC InsertProductPurchase 19, '2023-06-25 12:32:03', 46;
EXEC InsertProductPurchase 9, '2024-04-26 05:34:20', 90;
EXEC InsertProductPurchase 24, '2023-06-29 22:45:56', 22;
EXEC InsertProductPurchase 45, '2023-12-21 16:29:13', 44;
EXEC InsertProductPurchase 33, '2023-12-31 15:07:04', 32;
EXEC InsertProductPurchase 12, '2023-10-12 15:38:51', 82;
EXEC InsertProductPurchase 21, '2023-08-11 19:51:04', 87;
EXEC InsertProductPurchase 5, '2023-07-09 20:08:20', 15;
EXEC InsertProductPurchase 11, '2023-11-20 12:08:38', 63;
EXEC InsertProductPurchase 2, '2024-05-05 20:18:23', 25;
EXEC InsertProductPurchase 19, '2023-12-31 00:21:19', 21;
EXEC InsertProductPurchase 15, '2024-05-16 14:00:06', 49;
EXEC InsertProductPurchase 4, '2023-10-05 00:21:54', 98;
EXEC InsertProductPurchase 47, '2024-02-25 14:31:36', 87;
EXEC InsertProductPurchase 34, '2024-03-07 14:23:35', 30;
EXEC InsertProductPurchase 55, '2023-08-17 07:55:30', 38;
EXEC InsertProductPurchase 32, '2023-09-09 08:02:27', 44;
EXEC InsertProductPurchase 47, '2024-01-26 04:38:54', 33;
EXEC InsertProductPurchase 49, '2023-06-01 00:15:41', 92;
EXEC InsertProductPurchase 23, '2023-07-09 15:17:42', 86;
EXEC InsertProductPurchase 51, '2023-06-09 13:00:58', 85;
EXEC InsertProductPurchase 21, '2023-10-31 12:56:11', 60;
EXEC InsertProductPurchase 40, '2023-07-11 01:41:48', 95;
EXEC InsertProductPurchase 38, '2023-10-12 16:23:38', 94;
EXEC InsertProductPurchase 4, '2023-06-11 08:21:39', 18;
EXEC InsertProductPurchase 37, '2023-12-27 21:47:56', 77;
EXEC InsertProductPurchase 46, '2024-03-12 16:02:49', 58;
EXEC InsertProductPurchase 52, '2023-06-14 21:51:12', 12;
EXEC InsertProductPurchase 32, '2024-01-26 21:38:27', 13;
EXEC InsertProductPurchase 18, '2023-11-01 14:44:12', 3;
EXEC InsertProductPurchase 2, '2024-02-06 20:44:03', 36;
EXEC InsertProductPurchase 51, '2023-08-29 12:23:49', 36;
EXEC InsertProductPurchase 16, '2024-01-31 05:25:17', 32;
EXEC InsertProductPurchase 10, '2023-09-23 17:35:03', 38;
EXEC InsertProductPurchase 23, '2023-10-26 22:15:24', 16;
EXEC InsertProductPurchase 7, '2023-12-07 06:10:36', 76;
EXEC InsertProductPurchase 45, '2023-09-08 23:29:18', 81;
EXEC InsertProductPurchase 53, '2023-08-10 19:33:42', 31;
EXEC InsertProductPurchase 17, '2023-06-09 08:00:17', 3;
EXEC InsertProductPurchase 26, '2023-10-13 16:01:03', 58;
EXEC InsertProductPurchase 19, '2023-08-19 17:37:48', 3;
EXEC InsertProductPurchase 18, '2024-01-15 01:22:49', 52;
EXEC InsertProductPurchase 28, '2023-12-16 11:55:20', 60;
EXEC InsertProductPurchase 7, '2023-11-21 04:44:06', 82;
EXEC InsertProductPurchase 4, '2024-03-24 10:05:11', 65;
EXEC InsertProductPurchase 16, '2023-07-04 11:51:39', 76;
EXEC InsertProductPurchase 33, '2023-07-19 18:58:38', 25;
EXEC InsertProductPurchase 36, '2024-01-16 06:38:49', 7;
EXEC InsertProductPurchase 44, '2023-10-01 08:21:47', 91;
EXEC InsertProductPurchase 10, '2023-08-09 22:32:36', 45;
EXEC InsertProductPurchase 25, '2023-12-26 12:26:23', 32;
EXEC InsertProductPurchase 17, '2023-08-13 09:51:25', 68;
EXEC InsertProductPurchase 36, '2024-01-25 05:13:24', 15;
EXEC InsertProductPurchase 42, '2023-12-04 15:55:49', 67;
EXEC InsertProductPurchase 2, '2023-10-13 07:09:03', 85;
EXEC InsertProductPurchase 19, '2023-06-20 02:01:41', 98;
EXEC InsertProductPurchase 54, '2024-03-09 01:08:39', 88;
EXEC InsertProductPurchase 25, '2024-04-16 15:30:44', 49;
EXEC InsertProductPurchase 50, '2024-05-08 04:06:26', 46;
EXEC InsertProductPurchase 42, '2024-03-02 17:29:14', 30;
EXEC InsertProductPurchase 17, '2023-11-03 09:13:03', 9;
EXEC InsertProductPurchase 42, '2023-08-07 02:17:15', 67;
EXEC InsertProductPurchase 41, '2024-05-06 05:37:45', 83;
EXEC InsertProductPurchase 49, '2024-05-24 18:46:27', 19;
EXEC InsertProductPurchase 35, '2023-09-30 10:10:03', 54;
EXEC InsertProductPurchase 9, '2024-03-31 19:41:58', 70;
EXEC InsertProductPurchase 5, '2023-12-09 10:46:59', 43;
EXEC InsertProductPurchase 3, '2023-08-21 13:29:29', 41;
EXEC InsertProductPurchase 42, '2023-08-08 02:58:46', 25;
EXEC InsertProductPurchase 35, '2024-02-21 06:49:27', 88;
EXEC InsertProductPurchase 18, '2024-04-24 18:06:14', 21;
EXEC InsertProductPurchase 9, '2023-07-11 15:22:47', 39;
EXEC InsertProductPurchase 11, '2023-12-19 16:14:51', 24;
EXEC InsertProductPurchase 32, '2023-08-16 23:04:43', 81;
EXEC InsertProductPurchase 35, '2024-04-17 10:35:20', 41;
EXEC InsertProductPurchase 43, '2023-06-11 05:15:45', 56;
EXEC InsertProductPurchase 38, '2023-06-28 00:04:27', 82;
EXEC InsertProductPurchase 4, '2023-07-31 20:50:44', 98;
EXEC InsertProductPurchase 28, '2023-11-01 03:26:30', 67;
EXEC InsertProductPurchase 51, '2024-04-09 13:33:40', 33;
EXEC InsertProductPurchase 11, '2023-07-16 17:05:42', 80;
EXEC InsertProductPurchase 40, '2023-07-28 19:51:59', 86;
EXEC InsertProductPurchase 40, '2024-01-16 22:15:36', 69;
EXEC InsertProductPurchase 48, '2023-07-03 03:26:12', 78;
EXEC InsertProductPurchase 50, '2024-05-13 14:53:38', 35;
EXEC InsertProductPurchase 52, '2024-02-28 10:18:51', 22;
EXEC InsertProductPurchase 41, '2023-10-10 18:27:24', 100;
EXEC InsertProductPurchase 11, '2024-02-07 02:01:07', 33;
EXEC InsertProductPurchase 35, '2023-12-15 11:48:52', 3;
EXEC InsertProductPurchase 27, '2024-02-21 22:03:56', 84;
EXEC InsertProductPurchase 3, '2024-04-27 00:03:16', 17;
EXEC InsertProductPurchase 34, '2023-06-21 21:16:50', 58;
EXEC InsertProductPurchase 41, '2023-08-20 17:53:44', 26;
EXEC InsertProductPurchase 18, '2024-04-06 14:29:51', 36;
EXEC InsertProductPurchase 41, '2024-01-23 22:27:06', 86;
EXEC InsertProductPurchase 20, '2024-02-09 18:27:58', 17;
EXEC InsertProductPurchase 4, '2023-08-17 11:14:26', 46;
EXEC InsertProductPurchase 37, '2023-08-05 08:05:03', 40;
EXEC InsertProductPurchase 44, '2024-04-12 13:42:41', 86;
EXEC InsertProductPurchase 35, '2023-11-01 11:04:28', 64;
EXEC InsertProductPurchase 38, '2023-06-17 14:36:31', 74;
EXEC InsertProductPurchase 45, '2024-05-12 16:08:30', 53;
EXEC InsertProductPurchase 41, '2023-09-11 06:20:49', 44;
EXEC InsertProductPurchase 9, '2024-01-06 06:51:34', 39;
EXEC InsertProductPurchase 6, '2024-04-15 22:07:24', 35;
EXEC InsertProductPurchase 45, '2023-12-09 16:57:37', 96;
EXEC InsertProductPurchase 1, '2023-12-12 18:48:08', 59;
EXEC InsertProductPurchase 4, '2023-12-19 02:45:41', 27;
EXEC InsertProductPurchase 43, '2023-12-02 03:03:28', 47;
EXEC InsertProductPurchase 36, '2023-08-22 16:11:37', 29;
EXEC InsertProductPurchase 26, '2023-11-17 01:14:24', 27;
EXEC InsertProductPurchase 15, '2023-09-04 00:30:08', 12;
EXEC InsertProductPurchase 8, '2023-08-28 17:09:27', 10;
EXEC InsertProductPurchase 7, '2023-08-06 23:25:34', 11;
EXEC InsertProductPurchase 20, '2023-06-13 23:08:34', 99;
EXEC InsertProductPurchase 26, '2023-06-19 10:41:41', 74;
EXEC InsertProductPurchase 13, '2023-08-25 10:05:20', 65;
EXEC InsertProductPurchase 40, '2024-05-07 00:15:59', 32;
EXEC InsertProductPurchase 47, '2023-10-05 01:08:45', 96;
EXEC InsertProductPurchase 23, '2023-11-10 15:06:02', 87;
EXEC InsertProductPurchase 45, '2023-06-12 17:58:40', 38;
EXEC InsertProductPurchase 40, '2023-12-03 02:52:39', 65;
EXEC InsertProductPurchase 23, '2023-07-04 09:23:44', 71;
EXEC InsertProductPurchase 19, '2024-04-15 15:56:20', 92;
EXEC InsertProductPurchase 28, '2023-12-21 18:51:56', 78;
EXEC InsertProductPurchase 30, '2023-07-17 02:21:44', 15;
EXEC InsertProductPurchase 34, '2024-02-26 19:09:08', 54;
EXEC InsertProductPurchase 35, '2024-04-01 01:53:48', 7;
EXEC InsertProductPurchase 12, '2023-07-24 18:38:42', 98;
EXEC InsertProductPurchase 50, '2024-03-26 05:08:40', 14;
EXEC InsertProductPurchase 15, '2023-12-20 14:05:40', 88;
EXEC InsertProductPurchase 30, '2024-02-26 02:37:56', 13;
EXEC InsertProductPurchase 17, '2024-03-04 08:56:53', 67;
EXEC InsertProductPurchase 15, '2024-04-04 17:32:10', 26;
EXEC InsertProductPurchase 23, '2024-04-13 16:41:16', 48;
EXEC InsertProductPurchase 54, '2023-12-06 11:26:53', 28;
EXEC InsertProductPurchase 4, '2023-10-31 17:20:28', 67;
EXEC InsertProductPurchase 51, '2024-05-03 06:21:41', 49;
EXEC InsertProductPurchase 29, '2024-05-14 06:08:46', 52;
EXEC InsertProductPurchase 27, '2023-12-04 05:29:36', 51;
EXEC InsertProductPurchase 35, '2023-10-06 01:50:49', 91;
EXEC InsertProductPurchase 8, '2024-04-27 14:12:59', 76;
EXEC InsertProductPurchase 47, '2024-02-12 06:42:59', 53;
EXEC InsertProductPurchase 49, '2024-03-02 11:34:12', 3;
EXEC InsertProductPurchase 16, '2024-02-12 22:08:04', 72;
EXEC InsertProductPurchase 23, '2024-01-06 07:21:38', 88;
EXEC InsertProductPurchase 39, '2024-01-05 16:44:38', 79;
EXEC InsertProductPurchase 9, '2023-11-06 19:19:43', 68;
EXEC InsertProductPurchase 15, '2023-08-18 08:22:10', 78;
EXEC InsertProductPurchase 51, '2023-08-03 03:54:14', 98;
EXEC InsertProductPurchase 36, '2023-10-16 20:24:31', 49;
EXEC InsertProductPurchase 18, '2024-03-30 19:56:09', 88;
EXEC InsertProductPurchase 41, '2023-12-19 23:48:54', 28;
EXEC InsertProductPurchase 30, '2023-11-29 00:53:18', 47;
EXEC InsertProductPurchase 6, '2023-12-23 20:17:23', 70;
EXEC InsertProductPurchase 46, '2024-05-24 03:17:08', 67;
EXEC InsertProductPurchase 50, '2023-11-30 15:31:05', 87;
EXEC InsertProductPurchase 47, '2024-01-22 19:16:02', 47;
EXEC InsertProductPurchase 49, '2023-08-19 18:23:41', 98;
EXEC InsertProductPurchase 31, '2024-04-27 08:09:30', 26;
EXEC InsertProductPurchase 45, '2024-03-17 11:17:37', 88;
EXEC InsertProductPurchase 1, '2023-08-30 00:43:32', 37;
EXEC InsertProductPurchase 2, '2023-11-07 14:08:58', 84;
EXEC InsertProductPurchase 10, '2023-08-25 02:16:43', 72;
EXEC InsertProductPurchase 40, '2023-11-19 09:48:43', 29;
EXEC InsertProductPurchase 5, '2024-04-11 14:45:15', 18;
EXEC InsertProductPurchase 11, '2024-03-14 03:14:38', 36;
EXEC InsertProductPurchase 25, '2024-02-07 12:57:25', 10;
EXEC InsertProductPurchase 46, '2023-08-10 12:41:30', 66;
EXEC InsertProductPurchase 19, '2023-06-26 08:28:31', 28;
EXEC InsertProductPurchase 31, '2024-05-08 08:55:33', 98;
EXEC InsertProductPurchase 4, '2024-04-03 08:22:27', 87;
EXEC InsertProductPurchase 48, '2024-05-11 04:07:49', 44;
EXEC InsertProductPurchase 36, '2024-05-18 02:59:05', 28;
EXEC InsertProductPurchase 7, '2023-12-06 12:19:03', 93;
EXEC InsertProductPurchase 48, '2023-08-10 12:24:28', 30;
EXEC InsertProductPurchase 2, '2023-09-29 03:37:16', 3;
EXEC InsertProductPurchase 42, '2024-03-14 22:02:23', 97;
EXEC InsertProductPurchase 26, '2024-03-20 07:48:49', 56;
EXEC InsertProductPurchase 10, '2023-09-04 19:23:17', 97;
EXEC InsertProductPurchase 50, '2023-12-23 08:16:03', 8;
EXEC InsertProductPurchase 25, '2024-03-20 12:20:05', 41;
EXEC InsertProductPurchase 54, '2023-11-24 02:41:24', 83;
EXEC InsertProductPurchase 49, '2024-05-29 18:54:52', 13;
EXEC InsertProductPurchase 51, '2024-04-20 23:04:56', 16;
EXEC InsertProductPurchase 39, '2024-05-22 11:20:14', 82;
EXEC InsertProductPurchase 44, '2024-05-13 03:36:42', 12;
EXEC InsertProductPurchase 22, '2024-02-01 21:24:33', 53;
EXEC InsertProductPurchase 28, '2024-05-07 13:31:15', 42;
EXEC InsertProductPurchase 53, '2024-03-11 13:09:21', 5;
EXEC InsertProductPurchase 47, '2023-10-18 19:56:18', 56;
EXEC InsertProductPurchase 7, '2023-11-14 21:26:40', 4;
EXEC InsertProductPurchase 53, '2024-04-23 14:18:05', 72;
EXEC InsertProductPurchase 51, '2024-04-21 03:45:33', 3;
EXEC InsertProductPurchase 49, '2023-06-22 03:06:52', 53;
EXEC InsertProductPurchase 32, '2023-08-01 04:32:00', 100;
EXEC InsertProductPurchase 15, '2023-06-27 16:34:28', 33;
EXEC InsertProductPurchase 36, '2024-03-08 01:08:29', 90;
EXEC InsertProductPurchase 26, '2023-12-17 09:32:54', 63;
EXEC InsertProductPurchase 47, '2024-04-20 18:59:12', 62;
EXEC InsertProductPurchase 45, '2023-08-07 18:14:32', 14;
EXEC InsertProductPurchase 10, '2023-10-04 18:35:14', 44;
EXEC InsertProductPurchase 14, '2024-03-24 17:26:41', 75;
EXEC InsertProductPurchase 53, '2023-09-25 11:51:00', 93;
EXEC InsertProductPurchase 34, '2023-10-24 08:37:07', 15;
EXEC InsertProductPurchase 25, '2024-04-27 09:56:09', 75;
EXEC InsertProductPurchase 34, '2024-05-21 11:56:02', 96;
EXEC InsertProductPurchase 38, '2023-06-02 11:31:53', 42;
EXEC InsertProductPurchase 42, '2024-03-16 04:44:50', 14;
EXEC InsertProductPurchase 21, '2023-12-21 18:30:05', 10;
EXEC InsertProductPurchase 49, '2023-07-14 05:27:30', 78;
EXEC InsertProductPurchase 39, '2024-05-09 23:12:43', 52;
EXEC InsertProductPurchase 31, '2024-03-20 10:43:38', 20;
EXEC InsertProductPurchase 45, '2023-07-15 23:22:10', 96;
EXEC InsertProductPurchase 46, '2024-04-24 02:25:33', 24;
EXEC InsertProductPurchase 55, '2023-07-16 00:29:23', 61;
EXEC InsertProductPurchase 26, '2023-11-14 00:00:10', 97;
EXEC InsertProductPurchase 42, '2024-05-19 09:43:52', 24;
EXEC InsertProductPurchase 39, '2024-05-04 17:42:38', 48;
EXEC InsertProductPurchase 40, '2023-07-29 04:27:17', 9;
EXEC InsertProductPurchase 6, '2023-11-05 23:40:08', 51;
EXEC InsertProductPurchase 31, '2023-11-11 14:53:41', 39;
EXEC InsertProductPurchase 49, '2023-07-04 23:04:51', 91;
EXEC InsertProductPurchase 32, '2023-11-03 21:04:29', 82;
EXEC InsertProductPurchase 23, '2023-08-20 00:41:48', 83;
EXEC InsertProductPurchase 30, '2023-08-03 03:46:12', 91;
EXEC InsertProductPurchase 22, '2023-08-07 04:24:45', 68;
EXEC InsertProductPurchase 9, '2023-08-31 13:43:23', 57;
EXEC InsertProductPurchase 6, '2023-08-30 07:02:56', 40;
EXEC InsertProductPurchase 21, '2024-01-23 02:37:21', 83;
EXEC InsertProductPurchase 12, '2023-11-30 20:18:17', 83;
EXEC InsertProductPurchase 23, '2024-02-26 11:51:15', 27;
EXEC InsertProductPurchase 20, '2024-03-14 06:59:19', 89;
EXEC InsertProductPurchase 20, '2024-04-24 03:40:38', 53;
EXEC InsertProductPurchase 44, '2023-07-21 19:48:51', 46;
EXEC InsertProductPurchase 13, '2024-01-01 05:07:20', 9;
EXEC InsertProductPurchase 38, '2023-07-19 06:13:14', 92;
EXEC InsertProductPurchase 35, '2023-12-27 09:33:32', 92;
EXEC InsertProductPurchase 7, '2023-10-31 15:06:41', 30;
EXEC InsertProductPurchase 2, '2023-08-18 02:02:26', 87;
EXEC InsertProductPurchase 23, '2023-10-02 04:02:55', 3;
EXEC InsertProductPurchase 41, '2024-02-05 19:08:36', 54;
EXEC InsertProductPurchase 34, '2024-04-16 02:06:48', 2;
EXEC InsertProductPurchase 52, '2023-11-10 17:58:15', 50;
EXEC InsertProductPurchase 22, '2023-06-06 13:15:21', 51;
EXEC InsertProductPurchase 14, '2023-08-26 03:33:39', 76;
EXEC InsertProductPurchase 27, '2023-08-12 01:30:06', 95;
EXEC InsertProductPurchase 14, '2024-04-19 18:51:15', 65;
EXEC InsertProductPurchase 3, '2023-11-15 15:46:30', 74;
EXEC InsertProductPurchase 12, '2023-08-17 17:35:14', 69;
EXEC InsertProductPurchase 14, '2023-12-11 01:55:57', 13;
EXEC InsertProductPurchase 55, '2024-01-15 14:42:56', 37;
EXEC InsertProductPurchase 35, '2023-08-03 00:59:35', 46;
EXEC InsertProductPurchase 14, '2024-03-12 03:16:16', 11;
EXEC InsertProductPurchase 52, '2023-09-18 11:19:31', 66;
EXEC InsertProductPurchase 13, '2023-06-02 01:00:43', 35;
EXEC InsertProductPurchase 54, '2024-05-20 20:26:08', 76;
EXEC InsertProductPurchase 5, '2023-06-08 13:03:27', 41;
EXEC InsertProductPurchase 2, '2024-04-18 23:26:26', 47;
EXEC InsertProductPurchase 47, '2023-06-22 11:52:45', 15;
EXEC InsertProductPurchase 22, '2023-10-25 16:28:58', 56;
EXEC InsertProductPurchase 54, '2023-11-22 16:07:44', 55;
EXEC InsertProductPurchase 42, '2024-01-30 18:24:27', 27;
EXEC InsertProductPurchase 36, '2024-02-07 20:33:35', 75;
EXEC InsertProductPurchase 7, '2023-12-21 21:30:51', 78;
EXEC InsertProductPurchase 45, '2024-04-27 08:43:06', 66;
EXEC InsertProductPurchase 48, '2024-02-20 03:26:42', 65;
EXEC InsertProductPurchase 45, '2024-04-16 02:38:42', 29;
EXEC InsertProductPurchase 51, '2023-06-29 17:53:40', 91;
EXEC InsertProductPurchase 5, '2024-03-10 10:44:15', 3;
EXEC InsertProductPurchase 15, '2024-03-17 15:43:41', 10;
EXEC InsertProductPurchase 39, '2023-07-04 17:47:05', 23;
EXEC InsertProductPurchase 46, '2024-04-07 13:00:26', 96;
EXEC InsertProductPurchase 18, '2024-04-10 16:25:50', 97;
EXEC InsertProductPurchase 22, '2023-06-14 07:27:24', 20;
EXEC InsertProductPurchase 19, '2023-11-07 19:57:47', 34;
EXEC InsertProductPurchase 42, '2023-06-01 22:37:32', 99;
EXEC InsertProductPurchase 36, '2023-06-27 04:32:46', 48;
EXEC InsertProductPurchase 1, '2024-04-10 14:12:21', 32;
EXEC InsertProductPurchase 28, '2023-12-02 21:15:52', 75;
EXEC InsertProductPurchase 31, '2024-01-14 16:53:27', 56;




EXEC DeleteO