-- Do products generate higher monthly revenue in their first 6 months after launch compared to months 6–12?

with cte as(
select p.product_id,p.product_name,p.launch_date,s.sale_date,
timestampdiff(month,p.launch_date,s.sale_date) as months,
(s.quantity*s.unit_price) as revenue
from products p
join sales s
on p.product_id=s.product_id
WHERE s.sale_date >= p.launch_date
),cte2 as (

select product_id,product_name,months,sum(revenue)  as revenue
from cte
where months <= 12
group by product_id,product_name,months
)
select * ,
case when months<=6 then "first_6mnt" 
else "above_6" end as lifecycle
from cte2

order by product_name,months


