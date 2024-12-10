--select * from df_orders
--Top 10 highest revenue generating products

select top 10 product_id,sum(sale_price) as total_sales from df_orders
group by product_id
order by sum(sale_price) desc;

--Top 5 highest selling products in each region
with cte as
(select region,product_id,sum(sale_price) as total_sales from df_orders
group by region,product_id
)
select* from
(select *,DENSE_RANK() over(partition by region order by total_sales desc) as rn from cte
) as A 
where rn<6;

--find month over month	growth comperision for 2022 and 2023 sales
with cte as(
select year(order_date) as Years,month(order_date) as Months,sum(sale_price) as Sales from df_orders
group by year(order_date) ,month(order_date)
)
select Months,sum(case when years=2022 then sales else 0 end) as [Sales'22] , sum(case when years=2023 then sales else 0 end) as [Sales'23] from cte
group by Months
order by Months

--For each category which month had highest sales
select * from df_orders
with cte as (
select category,format(order_date,	'yyyyMM') as Year_month, sum(sale_price) as Total_sales from df_orders
group by category,format(order_date,'yyyyMM')
)
select * from(
select*, row_number() over(partition by category order by Total_sales desc) as rn from cte
) as A
where rn=1

--which sub-category had highest growth by profit in 2023 compare to 2022
with cte as (
select year(order_date) as order_year,sub_category,sum(sale_price) as sales from df_orders
group by year(order_date),sub_category
)
select top 1 sub_category,round((sales2023-sales2022)*100/sales2022,2) as growth from (
select sub_category,sum(case when order_year=2022 then sales else 0 end) as sales2022,sum(case when order_year=2023 then sales else 0 end) as sales2023 
from cte
group by sub_category) A
order by (sales2023-sales2022)*100/sales2022 desc


