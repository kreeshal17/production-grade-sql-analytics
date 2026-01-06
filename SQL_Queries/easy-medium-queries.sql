-- 🟢 Medium → Small (10 Questions)

-- Find total revenue per store
select st.store_name, sum(s.quantity *s.unit_price) as revenue
 from sales s
 join stores st
 on s.store_id=st.store_id
group by st.store_name
ORDER BY revenue DESC;


-- List top 5 products by total units sold
select p.product_name,sum(s.quantity) as total_sold_units
from products p
join sales s
on p.product_id=s.product_id 
group by p.product_name
order by  total_sold_units  desc
limit 5;

-- Calculate monthly sales volume per country
select st.country, year(s.sale_date),month(s.sale_date),sum(s.quantity) as total_sales
from sales s
join stores st
on s.store_id=st.store_id
group by st.country,year(s.sale_date),month(s.sale_date)
order by year(s.sale_date),month(s.sale_date);



-- Identify stores with  warranty void
select distinct st.store_name,w.repair_status
 from warranty w
 join sales  s
 on w.sale_id=s.sale_id
 join stores st
 on s.store_id=st.store_id
where repair_status ="Warranty Void"
order by 1 asc;

-- identify total system with no warrenty claim
	select count(sale_id)
    from sales where sale_id not in (
	select sale_id
	from warranty);  -- works when warranty.sale_id is guaranteed NOT NUL
    
  select count(s.sale_id)
  from sales s
  left join warranty w
  on  s.sale_id=w.sale_id
  where w.sale_id is null;
  
  
 

-- Find average selling price per category
select p.category_id,c.category_name,round( avg(s.unit_price),2) as average_selling_price
from sales s
join products p
on s.product_id=p.product_id
join category c
on  p.category_id=c.category_id
GROUP BY p.category_id, c.category_name
order by average_selling_price desc;

-- Identify sales with quantity above global average
select sale_id,quantity
 from sales s
 where quantity>(select avg(quantity) from sales);

-- Find the first sale date for each product
with cte as
( select *,
row_number() over(partition by product_id order by sale_date asc ) as ans
from sales
)
select c.product_id,p.product_name,c.sale_date
 from cte c
 join products p
 on c.product_id=p.product_id
 where c.ans=1;
 -- or use the below one 
 SELECT
    p.product_id,
    p.product_name,
    MIN(sa.sale_date) AS first_sale_date
FROM sales sa
JOIN products p ON sa.product_id = p.product_id
GROUP BY p.product_id, p.product_name;





-- Calculate total revenue per year
	select year(s.sale_date) as yrs,sum(s.quantity *s.unit_price) as revenue
	 from sales s
	 group by year(sale_date)
	 order by yrs asc

