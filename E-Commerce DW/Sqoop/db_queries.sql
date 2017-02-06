USE adventureworks;

--(1)
CREATE VIEW v_salesorderheader
AS
SELECT SalesOrderID,RevisionNumber,OrderDate,DueDate,ShipDate,Status,OnlineOrderFlag,SalesOrderNumber,PurchaseOrderNumber,   
       AccountNumber,so.CustomerID,ContactID,BillToAddressID,ShipToAddressID,ShipMethodID,CreditCardID,
       CreditCardApprovalCode,so.CurrencyRateID,SubTotal,TaxAmt,Freight,TotalDue,Comment,so.SalesPersonID, 
       sp.TerritoryID,st.name territory,st.CountryRegionCode,st.group,cr.FromCurrencyCode,cr.toCurrencyCode,
       cr.AverageRate,cr.EndOfDayRate,str.name store,so.ModifiedDate         
FROM salesorderheader so 
LEFT JOIN salesperson sp 
ON sp.SalesPersonID = so.SalesPersonID
LEFT JOIN salesterritory st 
ON st.TerritoryID = sp.TerritoryID
LEFT JOIN currencyrate cr 
ON cr.CurrencyRateID = so.CurrencyRateID 
LEFT JOIN store str 
ON str.SalesPersonID = sp.SalesPersonID;


--(2)
CREATE VIEW v_salesorderdetail
AS
SELECT SalesOrderDetailID,SalesOrderID,CarrierTrackingNumber,OrderQty,ProductID,UnitPrice,UnitPriceDiscount,LineTotal,       
       sod.SpecialOfferID,so.Description,so.DiscountPct,so.Type,so.Category,ModifiedDate   
FROM salesorderdetail sod 
JOIN specialoffer so 
on sod.SpecialOfferID = so.SpecialOfferID;


--(3)
CREATE VIEW v_product 
AS
SELECT p.productId, p.name, productnumber, makeflag, finishedgoodsflag, color, safetystocklevel, reorderpoint, standardcost,
       listprice, size, sizeunitmeasurecode, weightunitmeasurecode, weight, daystomanufacture, productline, class, style,
       sellstartdate, sellenddate, discontinueddate, ps.name productsubcategory, pc.name productcategory, 
       pm.name producemodel, pm.catalogdescription, pm.instructions, p.modifieddate
FROM product p 
LEFT JOIN productsubcategory ps 
ON p.productsubcategoryid = ps.productsubcategoryid
LEFT JOIN productcategory pc 
ON ps.productcategoryid = pc.productcategoryid
LEFT JOIN productmodel pm 
ON p.productmodelid = pm.productmodelid;


--(4)
CREATE VIEW v_customer 
AS
SELECT cus.CustomerID, cus.AccountNumber, cus.CustomerType, ind.Demographics, con.NameStyle, con.Title, con.FirstName,             
       con.MiddleName,con.LastName, con.Suffix, con.EmailAddress, con.EmailPromotion, con.Phone, 
       con.AdditionalContactInfo, cus.TerritoryID,t.name territoryName, t.countryregioncode, t.group, 
       con.ModifiedDate 
FROM customer cus
JOIN individual ind 
ON ind.CustomerID = cus.CustomerID 
JOIN contact con 
ON con.ContactID = ind.ContactID 
JOIN salesterritory t 
ON cus.TerritoryID = t.TerritoryID

UNION

SELECT cus.CustomerID, cus.AccountNumber, cus.CustomerType, st.Demographics, con.NameStyle, con.Title, 
       st.Name, con.MiddleName, con.LastName, con.Suffix, con.EmailAddress, con.EmailPromotion, con.Phone, 
       con.AdditionalContactInfo, cus.TerritoryID, t.name territoryName, t.countryregioncode, t.group, 
       cus.ModifiedDate 
FROM store st
JOIN customer cus 
ON  st.CustomerID = cus.CustomerID 
JOIN storecontact sc 
ON  st.CustomerID = sc.CustomerID  
JOIN contact con 
ON sc.ContactID = con.ContactID 
JOIN salesterritory t 
ON cus.TerritoryID = t.TerritoryID;


-- mysql -u root -p < sqoop/db_queries.sql
