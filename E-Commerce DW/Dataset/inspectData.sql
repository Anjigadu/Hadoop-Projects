show schemas;

use adventureworks;
show tables;

desc salesorderheader;
select territoryID, count(1) from salesorderheader group by territoryID;

desc store;
select count(1) from store;

select Demographics from store limit 20;
# <StoreSurvey xmlns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey">
  <AnnualSales>1000000</AnnualSales><AnnualRevenue>100000</AnnualRevenue><BankName>Guardian Bank</BankName>
  <BusinessType>BS</BusinessType><YearOpened>1971</YearOpened><Specialty>Mountain</Specialty><SquareFeet>25000</SquareFeet>
  <Brands>4+</Brands><Internet>T1</Internet><NumberEmployees>28</NumberEmployees></StoreSurvey>  

desc salesterritory;

select distinct customertype from customer limit 10;

select distinct currencyrateid from salesorderheader;

select * from currencyrate where currencyrateid = 12151;

select count(*) from salesorderheader;
select count(*) from salesorderdetail;







