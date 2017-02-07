CREATE DATABASE store;

USE store;

-- (1)
CREATE EXTERNAL TABLE product(
        productId int,
	name string,
	productnumber string,
	makeflag boolean,
	finishedgoodsflag boolean,
	color string,
	safetystocklevel int,
	reorderpoint int,
	standardcost double,
	listprice double,
	size string,
	sizeunitmeasurecode string,
	weightunitmeasurecode string,
	weight string,
	daystomanufacture int,
	productline string,
	class string,
	style string,
	sellstartdate bigint,
	sellenddate bigint,
	discontinueddate bigint,
	productsubcategory string,
	productcategory string,
	producemodel string,
	catalogdescription string,
	instructions string,
	modifieddate bigint
)
STORED AS parquet
location '/user/cloudera/bigretail/output/stores/sqoop/products';

--(2)
CREATE EXTERNAL TABLE customer (
	                         CustomerID int,
				 AccountNumber string,
				 CustomerType varchar(1),
                                 Demographics string, 
	                         NameStyle boolean,
                                 Title string,
                                 FirstName string ,	                         
	                         MiddleName  string,
                                 LastName string ,
                                 Suffix string ,	                         
	                         EmailAddress  string,
				 EmailPromotion int,
				 Phone  string,
				 AdditionalContactInfo  string,
	                         TerritoryID int,
				 territoryName  string,
				 countryregioncode  string,
				 group  string,
	                         ModifiedDate bigint)
stored as parquet
location '/user/cloudera/bigretail/output/stores/sqoop/customers';

--(3)
CREATE EXTERNAL TABLE salesorderheader(
                                        salesorderid int,
                                        revisionnumber smallint,
                                        orderdate bigint,
                                        duedate bigint,
                                        shipdate bigint,
                                        status smallint,
                                        onlineorderflag boolean,       
                                        salesordernumber string,
                                        purchaseordernumber string,
                                        accountnumber string,
                                        customerid int,
                                        contactid int,
                                        billtoaddressid int,     
                                        shiptoaddressid int,
                                        shipmethodid int,
                                        creditcardid int,
                                        creditcardapprovalcode string,
                                        currencyrateid int,
                                        subtotal double,              
                                        taxamt double,
                                        freight double,
                                        totaldue double,
                                        comment string,
                                        salespersonid int,
                                        territoryid int,
                                        territory string,
                                        countryregioncode string,
                                        group string,
                                        fromcurrencycode string,
                                        tocurrencycode string,
                                        averagerate double,
                                        endofdayrate double,
                                        store string,
                                        modifieddate bigint     
)
stored as parquet
location '/user/cloudera/bigretail/output/stores/sqoop/salesorderheader';   

--(4)
CREATE EXTERNAL TABLE salesorderdetails( 
                                         salesorderdetailid int,
                                         salesorderid int,
                                         carriertrackingnumber string,
                                         orderqty int,
                                         productid int,
                                         unitprice double,             
                                         unitpricediscount double,
                                         linetotal double,
                                         specialofferid tinyint,
                                         description string,
                                         discountpct double,
                                         type string,
                                         modifieddate string 
)
stored as parquet
location '/user/cloudera/bigretail/output/stores/sqoop/salesorderdetails';

