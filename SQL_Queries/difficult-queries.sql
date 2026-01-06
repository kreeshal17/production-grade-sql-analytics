	-- D1. Calculate year-over-year revenue growth 

	with cte as( 
	select  year(sale_date) as years,
	sum(quantity* unit_price) as revenue
	from sales
	group by year(sale_date)
	),

	cte3 as(
	select *,
	lag(revenue) over(order by years) as growth
	from cte
	)
	select * ,round(((revenue-growth)/growth)*100,2) as total_growth
	 from cte3
	 where growth is not null
	 ;
	 







	-- D2. Calculate year-over-year revenue growth per store
	with cte as(
	select st.store_id,st.store_name,year(s.sale_date) as years, (s.unit_price*s.quantity) as revenue
	  from sales s 
	join stores st
	on s.store_id=st.store_id
	)
	,
	cte2 as(
	select store_id,store_name,years,sum(revenue) as revenue
	from cte
	group by store_id,store_name,years
	order by store_id,years desc
	),
	cte3 as(
	select * ,
	lag(revenue) over(partition by store_id  order by years) as prev_rev
	from cte2

	)
	select store_name,years,round(((revenue-prev_rev)/prev_rev)*100,2) as growth
	from cte3
	where prev_rev is not null;



-- D3. Identify top 3 products per category by revenue

with topproducts as(
select s.product_id,sum(quantity* unit_price) as revenue
from sales s
group by product_id

),
ans as(
select t.product_id,p.product_name,c.category_id,c.category_name,t.revenue
 from topproducts t
 join products p 
 on p.product_id=t.product_id
 join category c
 on p.category_id=c.category_id

),
product as(
select category_id,product_id,category_name,product_name,revenue,
row_number() over(partition by category_id order by revenue desc) as top3

from ans

)
select category_name,product_name,revenue from product
where top3<4;

-- D4. Compute warranty claim rate per product
with productjoin as(
select s.sale_id,s.product_id,w.repair_status 
from sales s
join warranty w 
on s.sale_id=w.sale_id
),
pj as(
select product_id,repair_status
from productjoin



)
select product_id,
round(sum(case when repair_status="Replaced" then 1 else 0 end)/count(*)*100,2) as ans
from pj
group by product_id
order by product_id



;







-- D5. Calculate rolling 3-month revenue per store

 with  reve as (
 select store_id,year(sale_date) as saal,month(sale_date) as mahina,(quantity* unit_price) as revenue
 from sales
),
 reven as(
 select store_id,saal,mahina,
 sum(revenue) as revenue
 from reve
 group by store_id,saal,mahina
 order by store_id,saal,mahina
 ),
 revena as (
 select *,
 sum(revenue) over(partition by store_id  ORDER BY saal, mahina rows between 2 preceding and current row) as rolling_rev
 from reven
 )
 
 select * from revena;
 
 



