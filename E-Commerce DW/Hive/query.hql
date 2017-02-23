# 1. Hive
SELECT store,territory, count(1)
FROM salesorderheader
GROUP BY store,territory WITH ROLLUP;

# 2.
SELECT productid,discountpct,minimum,maximum
FROM (
      SELECT productid, discountpct, min(unitprice) minimum, max(unitprice) maximum
      FROM salesorderdetails sod
      JOIN salesorderheader  soh
      ON sod.salesorderid = soh.salesorderid
      GROUP BY productid,discountpct
      ) v
WHERE minimum <> maximum
ORDER BY 1;
      


