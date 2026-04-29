INSERT INTO zepto (
    category, name, mrp, discountPercent, 
    availableQuantity, discountedSellingPrice, 
    weightInGms, outOfStock, quantity
)
SELECT 
    Category, name, mrp, discountPercent, 
    availableQuantity, discountedSellingPrice, 
    weightInGms, outOfStock, quantity
FROM zepto_v2;

---------------------------------------------------------------------------------------------------------
DROP TABLE zepto;

SELECT * INTO zepto
FROM zepto_v2;
----------------------------------------------------------------------------------------------------------------
ALTER TABLE zepto
ADD sku_id INT IDENTITY(1,1);
----------------------------------------------------------------------------------------------------------------
--top 10 rows of the table
SELECT TOP 10 * FROM zepto;
-------------------------------------------------------------------------------------------------------------
--data explaoration
SELECT COUNT(*) FROM zepto;
---------------------------------------------------------------------------------------------------------------
--Produts in stock vs outofstock
select outofstock, count(sku_id) as count
from zepto
group by outofstock;
------------------------------------------------------------------------------------------------------------------
--products names present multiple times

select name, count(sku_id) as Nummber_of_sku
from zepto
group by name
having count(sku_id) >1
order by count(sku_id) desc;
-----------------------------------------------------------------------------------------------------------------
--data cleaning
--let's check the price of the product might be zero

select * from zepto
where mrp =0 or discountedSellingPrice =0;

--delet the above
delete from zepto
where mrp =0;
------------------------------------------------------------------------------------------------------------------
--convert the mrp paise to rupees
UPDATE zepto
SET 
    mrp = mrp / 100.00,
    discountedSellingPrice = discountedSellingPrice / 100.00;

select mrp, discountedsellingprice from zepto
---------------------------------------------------------------------------------------------------------------------
--Find the TOP 10 best value for products based on the discount percentage

select top 10 name, mrp,discountPercent
from zepto
order by discountpercent desc;

(OR)

WITH ranked AS (
    SELECT 
        name,
        mrp,
        discountPercent,
        ROW_NUMBER() OVER (
            PARTITION BY name 
            ORDER BY discountPercent DESC
        ) AS rn
    FROM zepto
)
SELECT TOP 10
    name,
    mrp,
    discountPercent
FROM ranked
WHERE rn = 1
ORDER BY discountPercent DESC;
-----------------------------------------------------------------------------------------------------------------
--what are product with high mrp and out of stock

select distinct name,max(mrp) as mrp
from zepto
where outofstock =1
group by name
order by max(mrp) desc;
---------------------------------------------------------------------------------------------------------------------
--calculate the revenue for the each category

select category,
sum(discountedsellingprice*availablequantity) as total_revenue
from zepto
group by category
order by total_revenue;
--------------------------------------------------------------------------------------------------------------------
--find the the products where mrp is greater than 500 which hardly have any discounts which is less than 10 %
select name, mrp,discountpercent
from zepto
where mrp >500 and discountpercent <10
order by mrp desc;
-------------------------------------------------------------------------------------------------------------------
--identify the top 5 categories offering the highest average discount percentage.
select top 5 category,
avg(discountpercent) as avg_discount
from zepto
group by category
order by avg_discount desc;
-------------------------------------------------------------------------------------------------------------------
--find the price per gram of the products above 100gm and sort by best value.
select name,
weightinGms, 
discountedsellingprice,
discountedsellingprice/weightinGms as price_per_gm

from zepto

where weightInGms >=100
Order by price_per_gm;
------------------------------------------------------------------------------------------------------------------
--group the products into categories like low, medium, bulk
select distinct name, weightingms,
case when weightingms <1000 then 'low'
     when weightingms<5000 then 'medium'
     else 'bulk'
     end as weighted_category

    from zepto;
--------------------------------------------------------------------------------------------------------------------
-- what is the total inventory weight per category
select category,
sum(cast( weightingms as bigint )* availablequantity) as total_weight
from zepto
group by category
order by total_weight;
------------------------------------------------------------------------------------------------------------------
