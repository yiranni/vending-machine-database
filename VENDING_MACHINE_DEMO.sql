--DEMO CODE---
/*STORE PROC
	1. Add a new product
	2. Add a new event */

USE VENDING_MACHINE
-- To add a new product
EXEC uspNewProduct
@ProdN = 'M&M mini heart chocolate',
@ProdD = 'Sweet',
@ProdTypeN = 'Snack',
@ProdTypeD = 'Grab & GO',
@Price = 0.99

SELECT * FROM tblPRODUCT

EXEC usbNewProductStock
@ProdN = 'M&M mini heart chocolate',
@ProdD = 'Sweet',
@EventN = 'Stock',
@EventTypeD = 'Stock for current products',
@EventDescr = 'For future purchasing',
@AddDate = '12/05/2017',
@Qty = 100

--Store Proc for new product stock
EXEC usbNewProductStock
@ProdN = 'Starbucks New Product',
@ProdDescr = 'Not coffee, sweet tea',
@EventN = 'Stock',
@EventTypeD = 'Stock for current productss',
@EventDescr = 'For current products',
@AddDate = '12/05/2017',
@Qty = 100

--Business Rule: purchase limited, no more 20! It should be failed!
EXEC usbNewProductStock
@ProdN = 'Coca-cola',
@ProdDescr = 'Comfortable drink',
@EventN = 'Purchase',
@EventTypeD = 'Purchase for products',
@EventDescr = 'Stock for current products',
@AddDate = '12/05/2017',
@Qty = 25

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

