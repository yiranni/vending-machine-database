-- CREATE VENDING_MACHINE

USE VENDING_MACHINE

CREATE TABLE tblPRODUCT_TYPE
(ProductTypeID INT IDENTITY(1,1) primary key not null,
ProductTypeName varchar(50) not null,
ProductTypeDecsr varchar(500) NULL)
GO

INSERT INTO tblPRODUCT_TYPE(ProductTypeName, ProductTypeDecsr)
VALUES ('Tea', 'No leaf tea')

INSERT INTO tblProduct(ProductName, ProductDescr, ProductTypeID, SalePrice)
VALUES ('Starbucks New Product', 'Not coffee, sweet tea', 6, 3)

CREATE TABLE tblPRODUCT
(ProductID INT IDENTITY(1,1) primary key not null,
ProductName varchar(100) not null,
ProductTypeID INT FOREIGN KEY REFERENCES tblPRODUCT_TYPE (ProductTypeID) not null,
ProductDescr varchar(500) NULL,
SalePrice numeric(6,2))
GO

ALTER TABLE tblPRODUCT
ALTER COLUMN SalePrice numeric(6,2)

CREATE TABLE tblEVENT (
EventID INT IDENTITY(1,1) primary key not null,
EventTypeID INT FOREIGN KEY REFERENCES tblEVENT_TYPE (EventTypeID) not null,
ProductID INT FOREIGN KEY REFERENCES tblPRODUCT (ProductID) not null,
EventDescr varchar(500) NULL,
Qty INT,
EventDate date
)
GO
ALTER TABLE tblEVENT
ADD EventName varchar(500)

CREATE TABLE tblEVENT_TYPE (
EventTypeID INT IDENTITY(1,1) primary key not null,
EventName varchar(100) not null,
EventTypeDescr varchar(500) NULL,
)
GO
CREATE TABLE tblMANUFACTURER
(ManfacturerID INT IDENTITY(1,1) primary key not null,
ManfacturerName varchar(50) not null,
ManfacturerDecsr varchar(500) NULL)
GO

INSERT tblMANUFACTURER (ManfacturerName, ManfacturerDecsr)
VALUES ('eVending', 'For over the 85 years, 
eVending has provided customers with quality, reliable combo vending machines'),
('American Vending Machines', 'Great place for vending machine parts'),
('Fresh Brew Group USA', 'Coffee machine')

CREATE TABLE tblMACHINE
(MachineID INT IDENTITY(1,1) primary key not null,
MachineTypeID INT FOREIGN KEY REFERENCES tblMACHINE_TYPE (MachineTypeID) not null,
ManfacturerID INT FOREIGN KEY REFERENCES tblMANUFACTURER (ManfacturerID) not null,
EventID INT IDENTITY(1,1) FOREIGN KEY REFERENCES tblEVENT (EventID) not null,
MachineName varchar(100) not null,
MachineDescr varchar(500) NULL)
GO
INSERT INTO tblMACHINE (MachineTypeID, ManfacturerID, EventID, MachineName, MachineDescr)
VALUES(1, 1, 20, '#3', 'Machine number 3'), (2, 1, 21, '#4', 'Machine number 4'),
(3, 1, 19, '#5', 'Machine number 5')

CREATE TABLE tblMACHINE_TYPE
(MachineTypeID INT IDENTITY(1,1) primary key not null,
MachineTypeName varchar(50) not null,
MachineTypeDecsr varchar(500) NULL)
GO
INSERT INTO tblMACHINE_TYPE (MachineTypeName, MachineTypeDecsr)
VALUES('Snack Machine','Grab & Go machine, provide only packed product'), 
('Coffee Mahine', 'Best Seattle Coffee machine'), ('Bottle Water Mahine', 'Bottle water'), 
('Hot food machine', 'warm food')

CREATE TABLE tblLOCATION
(LocationID INT IDENTITY(1,1) primary key not null,
LocationName varchar(50) not null,
LocationDecsr varchar(500) NULL)
GO

CREATE TABLE tblMACHINE_BUILDING
(MachineID INT IDENTITY(1,1) primary key not null,
MachineTypeID INT IDENTITY(1,1) FOREIGN KEY REFERENCES tblMACHINE_TYPE (MachineTypeID) not null,
ManfacturerID INT IDENTITY(1,1) FOREIGN KEY REFERENCES tblMANUFACTURER (ManfacturerID) not null,
EventID INT IDENTITY(1,1) FOREIGN KEY REFERENCES tblEVENT (EventID) not null,
MachineName varchar(100) not null,
MachineDescr varchar(500) NULL)
GO

ALTER TABLE tblMACHINE_BUILDING
ADD CONSTRAINT FK_tblMachineID
FOREIGN KEY (MachineID)
REFERENCES tblMACHINE (MachineID)

ALTER TABLE tblMACHINE_BUILDING
DROP CONSTRAINT FK_tblBuildingID

INSERT INTO tblEVENT_TYPE(EventName, EventTypeDescr)
VALUES ('Purchase', 'Purchase for products'), ('Rent', 'Rent for products')

INSERT INTO tblPRODUCT_TYPE (ProductTypeName, ProductTypeDecsr)
VALUES ('Drinks', 'Pepsi'),
('Chips', 'From Lays')

INSERT INTO tblPRODUCT_TYPE (ProductTypeName, ProductTypeDecsr)
VALUES ('Snack', 'Grab & GO')

INSERT INTO tblBUILDING(BuildingName, BuildingDecsr, Street, City, BuildingState, Zipcode)
VALUES('Suzzallo Library', 'UW Building', '4000 15 Avenue North East', 'Seattle', 'WA', '98105'), 
('The HUB', 'UW Building', ' 4100 E Stevens Way NE', 'Seattle', 'WA', '98105') 

INSERT INTO tblLOCATION(LocationName, LocationDecsr)
VALUES('University of Washington', 'College Campus')

SET IDENTITY_INSERT tblMACHINE_BUILDING ON
INSERT INTO tblMACHINE_BUILDING (MachineID, LocationID, BuildingID, BeginDate, EndDate)
VALUES(7, 1, 2, '12/01/2017', NULL), (6, 1, 2, '12/01/2017', NULL)
SET IDENTITY_INSERT tblMACHINE_BUILDING OFF

--Add a new product
CREATE PROC uspNewProduct
@ProdN varchar(100),
@ProdD varchar(500),
@ProdTypeN varchar(100),
@ProdTypeD varchar(500),
@Price numeric(6,2)

AS
DECLARE @ProdTypeID INT = (SELECT ProductTypeID FROM tblPRODUCT_TYPE WHERE ProductTypeName = @ProdTypeN AND ProductTypeDecsr = @ProdTypeD)

BEGIN TRAN T1
INSERT INTO tblPRODUCT(ProductName, ProductDescr, ProductTypeID, SalePrice)
VALUES (@ProdN, @ProdD, @ProdTypeID, @Price)

IF @@ERROR <> 0
ROLLBACK TRAN T1
ELSE
COMMIT TRAN
GO

EXEC uspNewProduct
@ProdN = 'Cheetos',
@ProdD = 'Chips',
@ProdTypeN = 'Snack',
@ProdTypeD = 'Grab & GO',
@Price = 1.99

EXEC uspNewProduct
@ProdN = 'KIND Bar',
@ProdD = 'Energy bar, Cranberry Almond + Antioxidants, Gluten Free',
@ProdTypeN = 'Snack',
@ProdTypeD = 'Grab & GO',
@Price = 1.99

SELECT * FROM tblPRODUCT

--Add a new event (populate the Product table) for existing products.
ALTER PROC [dbo].[usbNewProductStock]
@EventN varchar(100),
@EventDescr varchar(200),
@EventTypeD varchar(200),
@Qty int,
@AddDate date,
@ProdN varchar(100),
@ProdD varchar(500)

AS
DECLARE @EventTypeID INT
DECLARE @ProdID INT

SET @EventTypeID = (SELECT EventTypeID FROM tblEVENT_TYPE WHERE EventName = @EventN)
SET @ProdID = (SELECT ProductID FROM tblPRODUCT WHERE ProductName = @ProdN AND ProductDescr = @ProdD)

BEGIN TRAN T1

INSERT INTO tblEVENT(EventTypeID, EventDescr, ProductID, Qty, EventDate)
VALUES (@EventTypeID, @EventDescr, @ProdID, @Qty, @AddDate)

IF @@ERROR <> 0
ROLLBACK TRAN T1
ELSE
COMMIT TRAN
GO

--Add a new machine to an existing building at a location
CREATE PROC uspAddMachineToBuildingLocaton
@MachineN VARCHAR(75),
@MachineD VARCHAR(200),
@MachineTN VARCHAR(100),
@MachineTD VARCHAR(200),
@BuildingN VARCHAR(100),
@ZipCode VARCHAR(6),
@ManuN VARCHAR(140),
@LocaN VARCHAR(100),
@LocaD VARCHAR(150),
@EventTN VARCHAR(100),
@EventTD VARCHAR(200),
@EventN VARCHAR(100),
@BeginDate DATE,
@EndDate DATE

AS
DECLARE @MachineTID INT
DECLARE @ManuID INT
DECLARE @EventID INT 
DECLARE @BuildingID INT
DECLARE @LocationID INT

SET @MachineTID = (SELECT MachineTypeID FROM tblMACHINE_TYPE WHERE MachineTypeName = @MachineTN AND MachineTypeDecsr = @MachineTD)
SET @ManuID = (SELECT ManfacturerID FROM tblMANUFACTURER WHERE ManfacturerName = @ManuN)
SET @EventID = (SELECT EventID FROM tblEVENT WHERE EventName = @EventN)
SET @BuildingID = (SELECT BuildingID FROM tblBUILDING WHERE BuildingName = @BuildingN AND Zipcode = @ZipCode)
SET @LocationID = (SELECT LocationID From tblLOCATION WHERE LocationName = @LocaN AND LocationDecsr = @LocaD)

BEGIN TRAN T1
INSERT INTO tblMACHINE (MachineTypeID, ManfacturerID, EventID, MachineName, MachineDescr)
VALUES (@MachineTID, @ManuID, @EventID, @MachineN, @MachineD)

INSERT INTO tblMACHINE_BUILDING (LocationID, BuildingID, BeginDate, EndDate)
VALUES (@LocationID, @BuildingID, @BeginDate, @EndDate)

IF @@ERROR<>0
ROLLBACK TRAN TI
ELSE
COMMIT TRAN
GO

EXEC uspAddMachineToBuildingLocaton
@MachineN = '001',
@MachineD = 'New machine for snack',
@MachineTN = 'Snack Machine',
@MachineTD = 'Grab & Go machine, provide only packed product',
@BuildingN = 'Odegaard',
@ZipCode = '98105',
@ManuN = 'eVending',
@LocaN = 'University of Washington',
@LocaD = 'College Campus',
@EventTN = 'Rent',
@EventTD = 'Rent for products',
@EventN = 'For New Machine',
@BeginDate = '12/12/2017',
@EndDate = '12/11/2027'


EXEC usbNewProductStock
@ProdN = 'Starbucks New Product',
@ProdD = 'Not coffee, sweet tea',
@EventN = 'Stock',
@EventTypeD = 'Stock for current productss',
@EventDescr = 'For current products',
@AddDate = '12/05/2017',
@Qty = 30


EXEC usbNewProductStock
@ProdN = 'KIND Bar',
@ProdDescr = 'Energy bar, Cranberry Almond + Antioxidants, Gluten Free',
@EventN = 'Stock',
@EventTypeD = 'Stock for products',
@EventDescr = 'Stock for current products',
@AddDate = '12/05/2017',
@Qty = 25

select * from tblEVENT_TYPE ET
select * from tblEVENT E join tblEVENT_TYPE ET ON E.EventTypeID = ET.EventTypeID

--Example Query
SELECT ET.EventName, E.Qty, P.ProductName, P.SalePrice, M.MachineName, B.BuildingName
FROM tblEVENT_TYPE ET
	JOIN tblEVENT E ON ET.EventTypeID = E.EventTypeID
	JOIN tblPRODUCT P ON E.ProductID = P.ProductID
	JOIN tblMACHINE M ON E.EventID = M.EventID
	JOIN tblMACHINE_BUILDING MB ON M.MachineID = MB.MachineID
	JOIN tblBUILDING B ON MB.BuildingID = B.BuildingID
WHERE ET.EventName = 'Purchase' AND E.Qty = 3 AND 
P.ProductName = 'Coca-cola' AND M.MachineName = '#3' AND B.BuildingName = 'The Hub'

SELECT P.ProductName
FROM tblEVENT_TYPE ET
	JOIN tblEVENT E ON ET.EventTypeID = E.EventTypeID
	JOIN tblPRODUCT P ON E.ProductID = P.ProductID
	JOIN tblMACHINE M ON E.EventID = M.EventID
	JOIN tblMACHINE_BUILDING MB ON M.MachineID = MB.MachineID
	JOIN tblBUILDING B ON MB.BuildingID = B.BuildingID
WHERE ET.EventName = 'Purchase' AND  
		M.MachineName = '#1' AND
		B.BuildingName = 'Suzzallo Library'
Order by E.EventDate

--Business Rules: the date to set up machine cannot be later than event data.
CREATE FUNCTION fnEvent_Date()
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT = 0
	IF EXISTS(SELECT * FROM tblEVENT E
		JOIN tblMACHINE M ON E.EventID = M.EventID
		JOIN tblMACHINE_BUILDING MB ON M.MachineID = MB.MachineID
		WHERE E.EventDate < MB.BeginDate)
	SET @Ret = 1
	RETURN @Ret
END

ALTER TABLE tblEVENT
ADD CONSTRAINT ck_NoLateEventDate
CHECK (dbo.fnEvent_Date() = 1)

SELECT * FROM tblEVENT E
		JOIN tblMACHINE M ON E.EventID = M.EventID
		JOIN tblMACHINE_BUILDING MB ON M.MachineID = MB.MachineID
		WHERE E.EventDate > MB.BeginDate

--Check Business Rule - No more 20 purchase
EXEC usbNewProductStock
@ProdN = 'Coca-cola',
@ProdDescr = 'Comfortable drink',
@EventN = 'Purchase',
@EventTypeD = 'Purchase for products',
@EventDescr = 'Stock for current products',
@AddDate = '12/05/2017',
@Qty = 25

--Business Rules: No more machine used over 10 years at the same location/building
--HINT: the duration between the beginDate and endDate is less than 10
ALTER FUNCTION fn_NoMoreMachineOver10Y()
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT = 0
	IF EXISTS (SELECT *
			FROM tblMACHINE_BUILDING
			WHERE DATEDIFF(MM, BeginDate, EndDate)/12 >= 10
	)
	SET @Ret = 1
	RETURN @Ret

END

ALTER TABLE tblMACHINE_BUILDING
ADD CONSTRAINT ck_NoMoreMachineOver10Y
CHECK (dbo.fn_NoMoreMachineOver10Y() = 0)