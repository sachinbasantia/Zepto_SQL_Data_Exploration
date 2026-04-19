select * from zepto

--remove  sku_id in the popup menu of import/export of data fro csv fiel to zepto table , as it was not one of the original 
--column that dataset had 
--------------------------------------------------------------

--data exploration

--count rows 
select count(*) from zepto

--null values 
select * from zepto 
where name IS NULL
or 
category IS NULL 
or 
mrp IS NULL 
or 
discountPercent IS NULL 
or 
discountedsellingprice IS NULL
or 
weightInGms IS NULL
or 
availableQuantity IS NULL
or 
outOfStock IS NULL 
or 
quantity IS NULL;

-- this dataset has null values ( 1000 null values in different columns )
--check Nulls per columns 
select 
    count(*) as total_rows,
	count(category),
    count(mrp) as mrp_not_null,
	count(discountedsellingprice) as discount_SP_not_null, 
	count(weightInGms) as weight_not_null,
	count(outOfStock) as out_of_stock_not_null,
	count(quantity) as quantity_not_null,
    count(discountPercent) as discount_not_null,
    count(availablequantity) as qty_not_null
from zepto;

--total nulls per column
select 
    sum(case when name is null then 1 else 0 end) as name_nulls,
	sum(case when mrp is null then 1 else 0 end) as mrp_nulls,
    sum(case when discountPercent is null then 1 else 0 end) as discount_nulls,
    sum(case when availablequantity is null then 1 else 0 end) as qty_nulls,
	sum(case when category is null then 1 else 0 end) as category_nulls,
	sum(case when quantity is null then 1 else 0 end) as quantity_nulls,
	sum(case when discountedsellingprice is null then 1 else 0 end) as discount_selling_price_null,
	sum(case when weightInGms is null then 1 else 0 end) as weightInGms_nulls,
	sum(case when outOfStock is null then 1 else 0 end) as outOfStock_nulls
from zepto

--dataset has nearly 30% null values , so we have to strategise for each solumn, what we can implement which 
--techniques like imputation, deletion, logical etc. 
--COALESCE Function is the key to handle null values in SQL

select * from zepto 
where discountedsellingprice IS NULL

SELECT * FROM zepto
WHERE name LIKE '%Cherry%';

-- Now lets start fixing the null values in each column 

--create a backup table just in case 
create table zepto_backup as
select * from zepto;

-- first is the discount column the discount will be zero where there is null value 
update zepto -- updating the table 
set discountpercent = 0
where discountpercent is null;
--check 
select * from zepto
where discountPercent IS NULL 

-- null values in avaiablequantity column
update zepto
set availablequantity = 0 -- used set & update fucntion here
where availablequantity is null
  and outofstock = true;
--check 
 select * from zepto
where availablequantity IS NULL 

--alternative for remaining ones whose avaialble quantity is zero if if the out of stock says false 
--Advance SQL
update zepto
set availablequantity = sub.median_val
from (
    select percentile_cont(0.5) within group (order by availablequantity) as median_val
    from zepto
    where availablequantity is not null
) sub
where zepto.availablequantity is null;

-- for quantity null values will replace with zero 
update zepto
set quantity = 0
where quantity is null;

-- Fix discountedsellingprice column 
-- first impute the mrp value for the product and then calc the discountedSeellingPrice based on the discount
select * from zepto
where mrp is null

-- checking how tp impute values or which values median should be taken 
SELECT *
FROM zepto
WHERE mrp IS NOT NULL
  AND category = 'Home & Cleaning';

--main query for mrp column
update zepto z
set mrp = sub.median_val
from (
    select percentile_cont(0.5) within group (order by mrp) as median_val
    from zepto
    where mrp is not null
      and category = 'Home & Cleaning'
      and name ilike 'Cherry%'
) sub
where z.mrp is null
  and z.category = 'Home & Cleaning'
  and z.name ilike 'Cherry%';

-- DiscountedSellingprice column null removal
update zepto
set discountedsellingprice = round(
    mrp - (coalesce(discountpercent, 0) * mrp / 100.0),
    2
)
where discountedsellingprice is null
  and mrp is not null;

--- handling weight in Gms column null values 
select * from zepto where name like '%Kajal%' IS NULL and (
SELECT *
FROM zepto
WHERE category IN ('Personal Care', 'Paan Corner');


-- we are taking a safe assumption for the null values in Weight in GMs column sicne they all are eyeliners we are 
--going with the ususal direct data impitaion method, and in analysis also weightInGms doesn't help
update zepto
set weightingms = 15
where weightingms is null
  and name ilike '%kajal%';


--check null values now (it's zero now )
select 
    sum(case when name is null then 1 else 0 end) as name_nulls,
	sum(case when mrp is null then 1 else 0 end) as mrp_nulls,
    sum(case when discountPercent is null then 1 else 0 end) as discount_nulls,
    sum(case when availablequantity is null then 1 else 0 end) as qty_nulls,
	sum(case when category is null then 1 else 0 end) as category_nulls,
	sum(case when quantity is null then 1 else 0 end) as quantity_nulls,
	sum(case when discountedsellingprice is null then 1 else 0 end) as discount_selling_price_null,
	sum(case when weightInGms is null then 1 else 0 end) as weightInGms_nulls,
	sum(case when outOfStock is null then 1 else 0 end) as outOfStock_nulls
from zepto


--Analysis start 

-- differnt prouct categories
select DISTINCT category from zepto 
order by category

-- products in stock vs out of stock
select outOfStock, COUNT(sku_id)
from zepto
group by outOfStock

--check product names which are present more than one in the SKUs
select name, count(sku_id) as stock_keeping_units from zepto 
group by name 
having count(sku_id)>1
order by count(sku_id) desc 
-- these proucts can be treated as sepeated product as they come in diff price, weight and is quite common in E-comm



-- Will do some data cleaning 
-- price is zero
select * from zepto 
where mrp = 0 or discountedSellingPrice = 0
-- coz we already did this 

-- now the MRP is in paise not in rupees ( we have to convert it to rupees)
update zepto
set mrp = mrp/100.0, 
discountedsellingprice = discountedsellingprice/100.0

-- Business Questions /insights 

-- Q1. Find the top 10 best valued products based on discunt percentage 
select DISTINCT name, discountpercent from zepto 
order by discountpercent desc
limit 10 

--Q2. what are the products with high MRP but OutOfStock
select DISTINCT name, mrp from zepto 
where mrp >= (select avg(mrp) from zepto) and outOfStock = 'True'
order by mrp desc

--Q3. Calculate total revenue for each ctaegory
select 
    category,
    round(sum(discountedsellingprice * availablequantity), 2) as total_revenue
from zepto
group by category
order by total_revenue desc;

--Q4. FInd all products wher MRP  is greater than 500 rupees and discount is less than 10%
select name , mrp from zepto
where mrp > 500 and  discountPercent < 10
group by name, mrp
order by mrp desc

--Q5. Identify the top 5 categories offering the highest average discount percentage
select category, discountPercent  from zepto
group by category, discountPercent
order by discountPercent desc
limit 5 

--Q6. Find the price per grams for products above 100g and sort by best value
select 
   DISTINCT name,
    weightInGms,
    discountedsellingprice, -- not MRP but this is the real Selling price
    round(discountedsellingprice / weightInGms, 2) as price_per_gram --for another column write in select statement only
from zepto
where weightInGms >= 100
order by price_per_gram asc;

--Q.7 Group the products into categories like low, medium, Bulk
--Statistics approach
select 
    percentile_cont(0.33) within group (order by weightingms) as p33,
    percentile_cont(0.66) within group (order by weightingms) as p66
from zepto
where weightingms is not null;

--next step
select 
    name,
    weightingms,
    case -- ususlaly used with seelcetc statements 
        when weightingms is null then 'Unknown'
        when weightingms <= 120 then 'Low'
        when weightingms <= 450 then 'Medium'
        else 'Bulk'
    end as weight_category
from zepto;

--Q8. What is the total inventory weight per category
select category, sum( weightingms*availablequantity) as Total_Inventory_weight 
from zepto
group by category -- hamesha quantity multiply krna bhul jata h total me
order by Total_Inventory_weight 
