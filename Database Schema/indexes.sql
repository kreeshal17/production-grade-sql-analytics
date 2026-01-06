-- here we will create index from the table okey

CREATE INDEX idx_sales_date ON sales(sale_date);
CREATE INDEX idx_sales_store ON sales(store_id);
CREATE INDEX idx_sales_product ON sales(product_id);

explain analyze
select * from stores
where city='paris';
-- -> Filter: (stores.city = 'paris')  (cost=2.25 rows=2) (actual time=0.0616..0.0704 rows=3 loops=1)
-- -> Table scan on stores  (cost=2.25 rows=20) (actual time=0.0547..0.0638 rows=20 loops=1)

create index idx_city on stores(city);
create index idx_country on stores(country);
create index idx_open_date on stores(open_Date);
create index store_name on stores(store_name);


explain analyze
select * from stores
where city='paris';
--  Index lookup on stores using idx_city (city='paris')  (cost=0.8 rows=3) (actual time=0.03..0.0321 rows=3 loops=1



CREATE INDEX idx_warranty_sale ON warranty(sale_id);
CREATE INDEX idx_products_category ON products(category_id);