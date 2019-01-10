--CREATE DATABASE STRANGER_THINGS
GO
USE STRANGER_THINGS
GO 
CREATE TABLE tblPRODUCT_TYPE
(ProductTypeID INT IDENTITY(1,1) primary key not null,
ProductTypeName varchar(50) not null,
ProductTypeDecsr varchar(500) NULL)
GO
CREATE TABLE tblPRODUCT
(ProductID INT IDENTITY(1,1) primary key not null,
ProductName varchar(100) not null,
ProductTypeID INT FOREIGN KEY REFERENCES tblPRODUCT_TYPE (ProductTypeID) not null,
ProductDescr varchar(500) NULL)
GO
CREATE TABLE tblCUSTOMER
(CustomerID INT IDENTITY(1,1) primary key not null,
CustFname varchar(25) not null,
CustLname varchar(25) not null,
CustBirth DATE not null)
GO
CREATE TABLE tblORDER
(OrderID INT IDENTITY(1,1) not null,
CustomerID INT not null,
ProductID INT not null,
OrderDate Date DEFAULT GetDate() NOT NULL,
PRIMARY KEY (OrderID))


ALTER TABLE tblORDER
ADD CONSTRAINT FK_tblORDER_ProductID
FOREIGN KEY (ProductID)
REFERENCES tblPRODUCT (ProductID)

ALTER TABLE tblORDER
DROP COLUMN CustomerID


ALTER TABLE tblORDER
ADD CustomerID INT 
FOREIGN KEY REFERENCES tblCUSTOMER (CustomerID)


INSERT INTO tblCUSTOMER (CustLname, CustBirth, CustFname)
VALUES ('Hay', '3/23/1932', 'Greg'),
('Long', '11/4/2001', 'Ken'), ('Huibregtse', '5/14/2000', 'Mary')

INSERT INTO tblPRODUCT_TYPE (ProductTypeName, ProductTypeDecsr)
VALUES ('Drinkware', 'Anything that holds liquid'), ('Beverage', 'Any drinkable liquid')

INSERT INTO tblPRODUCT (ProductName, ProductTypeID, ProductDescr)
VALUES ('Monster Latte', (SELECT ProductTypeID FROM tblPRODUCT_TYPE WHERE ProductTypeName = 'Beverage'), 'Heavy-duty scary drink')
GO

ALTER TABLE tblORDER
ADD Quantity INT
GO


ALTER PROCEDURE uspPopulateOrder
@ProdName varchar(100),
@OrderDate Date,
@Q INT,
@First varchar(25),
@Last varchar(25),
@DOB Date
AS
DECLARE @PID INT
DECLARE @CID INT

SET @PID = (SELECT ProductID 
FROM tblPRODUCT 
WHERE ProductName = @ProdName)

SET @CID = (SELECT CustomerID FROM tblCUSTOMER
WHERE CustFname = @First
AND CustLname = @Last
AND CustBirth = @DOB)

BEGIN TRAN T1
INSERT INTO tblORDER (ProductID, OrderDate, Quantity, CustomerID)
VALUES (@PID, @OrderDate,@Q, @CID)
COMMIT TRAN T1
GO

/*
No one older than 36 may buy 3 Monster lattes in any 2 day period
*/

CREATE FUNCTION fn_NoMonster36()
RETURNS INT
AS
BEGIN
DECLARE @Ret INT = 0
IF EXISTS(SELECT *
FROM tblCUSTOMER C
JOIN tblORDER O ON C.CustomerID = O.CustomerID
JOIN tblPRODUCT P ON O.ProductID = P.ProductID
WHERE C.CustBirth < (SELECT GetDate() - (365.25 * 36))
AND P.ProductName = 'Monster Latte'
AND O.OrderDate > (SELECT GetDate() -2)
GROUP BY O.CustomerID
HAVING SUM(O.Quantity) > 3
)
SET @Ret = 1
RETURN @Ret
END