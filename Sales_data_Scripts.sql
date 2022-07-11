--Inspecting dataset

select * from dbo.sales_data_sample

--Checking unique values
select distinct status from dbo.sales_data_sample -- Plot in tableau
select distinct year_id from dbo.sales_data_sample -- 3 years
select distinct PRODUCTLINE from dbo.sales_data_sample -- 7 different products
select distinct COUNTRY from dbo.sales_data_sample -- 19 countries (Plot in tableau)
select distinct DEALSIZE from dbo.sales_data_sample -- 3 sizes (Plot)
select distinct TERRITORY from dbo.sales_data_sample -- 4 (plot)

--Data Analysis
---Group sales by Productline

select PRODUCTLINE, SUM(sales) as Revenue
from dbo.sales_data_sample
group by PRODUCTLINE
order by 2 desc


-- Check revenue per year
select YEAR_ID, SUM(sales) as Revenue
from dbo.sales_data_sample
group by YEAR_ID
order by 2 desc
-- Explore why 2005 had the lowest sales -- Operated only for 5 months
select distinct MONTH_ID from dbo.sales_data_sample
where YEAR_ID = 2005

--Explore the deal sizes
select DEALSIZE, SUM(sales) as Revenue
from dbo.sales_data_sample
group by DEALSIZE
order by 2 desc

--What was the best month for sale in a specific year, how much revenues earned 
select MONTH_ID, SUM(sales) as Revenue, COUNT(ORDERNUMBER) Frequency
from dbo.sales_data_sample
where YEAR_ID = 2003 -- change to each unique year
group by MONTH_ID
order by 2 desc


--November seems to be the best month, what product do they sell in November?

select MONTH_ID, PRODUCTLINE, SUM(sales) Revenue, COUNT(ORDERNUMBER)
from dbo.sales_data_sample
where YEAR_ID = 2003 and MONTH_ID = 11 --change to each unique year
group by MONTH_ID, PRODUCTLINE
order by 3 desc

--Explore who is the best customer using RFM Analysis


DROP TABLE IF EXISTS #rfm
;with rfm as 
(
	select 
		CUSTOMERNAME, 
		sum(sales) MonetaryValue,
		avg(sales) AvgMonetaryValue,
		count(ORDERNUMBER) Frequency,
		max(ORDERDATE) last_order_date,
		(select max(ORDERDATE) from [dbo].[sales_data_sample]) max_order_date,
		DATEDIFF(DD, max(ORDERDATE), (select max(ORDERDATE) from [dbo].[sales_data_sample])) Recency
	from [dbo].[sales_data_sample]
	group by CUSTOMERNAME
),
rfm_calc as
(

	select r.*,
		NTILE(4) OVER (order by Recency desc) rfm_recency,
		NTILE(4) OVER (order by Frequency) rfm_frequency,
		NTILE(4) OVER (order by MonetaryValue) rfm_monetary
	from rfm r
)
select 
	c.*, rfm_recency+ rfm_frequency+ rfm_monetary as rfm_cell,
	cast(rfm_recency as varchar) + cast(rfm_frequency as varchar) + cast(rfm_monetary  as varchar)rfm_cell_string
into #rfm
from rfm_calc c

--Results saved in #rfm
select * from #rfm 

select CUSTOMERNAME , rfm_recency, rfm_frequency, rfm_monetary,
	case 
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_cell_string in (311, 411, 331) then 'new customers'
		when rfm_cell_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_cell_string in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_cell_string in (433, 434, 443, 444) then 'loyal'
	end rfm_segment

from #rfm



--Which products are often sold together?

select distinct OrderNumber, stuff(

	(select ',' + PRODUCTCODE
	from [dbo].[sales_data_sample] p
	where ORDERNUMBER in 
		(

			select ORDERNUMBER
			from (
				select ORDERNUMBER, count(*) rn
				FROM [dbo].[sales_data_sample]
				where STATUS = 'Shipped'
				group by ORDERNUMBER
			)m
			where rn = 3
		)
		and p.ORDERNUMBER = s.ORDERNUMBER
		for xml path (''))

		, 1, 1, '') ProductCodes

from [dbo].[sales_data_sample] s
order by 2 desc


--
