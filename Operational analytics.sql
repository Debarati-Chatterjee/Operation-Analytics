create database op_db;

use op_db;

select *
from jobdata;



/*1.Number of jobs reviewed: Amount of jobs reviewed over time.
Your task: Calculate the number of jobs reviewed per hour per day for November 2020?*/

select ds,
round((count(distinct job_id)/sum(time_spent))*3600,2) as jobs_reviewed_per_hour_per_day
from jobdata
group by ds
order by ds;


/*2.Throughput: It is the no. of events happening per second.
Your task: Let’s say the above metric is called throughput. Calculate 7 day rolling average of throughput? For throughput, 
do you prefer daily metric or 7-day rolling and why?*/

with event_table as
(select ds,
round((count(distinct event)/sum(time_spent)),2) as event_per_second_daily
from jobdata
group by ds
order by ds
)

select ds, event_per_second_daily,
avg(event_per_second_daily) over(order by ds rows between 6 preceding and current row) as 7_days_rolling_avg
from event_table
group by ds
order by ds ;


/*3.Percentage share of each language: Share of each language for different contents.
Your task: Calculate the percentage share of each language in the last 30 days?*/

select language,
count(*)*100/total   as percentage
from jobdata cross join 
(select count(*) as total 
 from jobdata) as totaldata
group by language
order by count(*) desc;


/*4.Duplicate rows: Rows that have the same value present in them.
Your task: Let’s say you see some duplicate rows in the data. How will you display duplicates from the table?*/

select * from
(
select *,
row_number()over(partition by job_id) as rownum 
from jobdata
)a 
where rownum>1;
