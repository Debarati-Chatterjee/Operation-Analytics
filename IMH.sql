create database IMH_db;

use IMH_db;

create table users
(user_id int,	
created_at datetime,	
company_id int,	
language text,	
activated_at datetime,	
state text);

create table events
(user_id int,	
occurred_at datetime,	
event_type text,	
event_name text,	
location text,	
device text,	
user_type int);

create table email_event
(user_id int,	
occurred_at datetime,	
action text,	
user_type int);

select * from users;

select * from events;

select * from email_event;

/*1.User Engagement: To measure the activeness of a user. Measuring if the user finds quality in a product/service.
Your task: Calculate the weekly user engagement?*/

select extract(week from occurred_at) as week_of_year,
count(distinct user_id) as total_user
from events
where event_type ="engagement"
group by 1
order by 1;


/*2.User Growth: Amount of users growing over time for a product.
Your task: Calculate the user growth for product?*/

with active_table as
(select extract(week from created_at) as created_week, count(user_id) as active_users
from users
where state ="active"
group by 1
order by 1)

select created_week, active_users,
round(((active_users/lag(active_users,1) over (order by created_week)-1)*100),2) as growth_rate
from active_table;




/*3.Weekly Retention: Users getting retained weekly after signing-up for a product.
Your task: Calculate the weekly retention of users-sign up cohort?*/

select extract(week from occurred_at) as week, count(user_id) as engaged_user, 
 sum(case when retention_week >0 then 1 else 0 end) as
retained_user
from
(
select distinct a.user_id,
 a.sign_up_week,
 b.engagement_week,
 b.engagement_week - a.sign_up_week as retention_week
from
(
select distinct user_id, extract(week from occurred_at) as sign_up_week
from events
where event_type = "signup_flow" and event_name ="complete_signup"
and extract(week from occurred_at)=18
)a
left join
(
select distinct user_id, extract(week from occurred_at) as engagement_week
from events
where event_type ="engagement"
)b
on a.user_id = b.user_id)c
left join
events using(user_id)
group by 1
order by 1;













/*4.Weekly Engagement: To measure the activeness of a user. Measuring if the user finds quality in a product/service weekly.
Your task: Calculate the weekly engagement per device?*/

select extract(week from occurred_at) as week_of_year,device,
count(distinct user_id) as _count
from events
where event_type ="engagement"
group by 1,2
order by 1;






/*5.Email Engagement: Users engaging with the email service.
Your task: Calculate the email engagement metrics?*/

select
100.0 * sum(case when email_category = 'email_opened' then 1 else 0 end)
 /sum(case when email_category = 'email_sent' then 1 else 0 end)
as opening_rate,
100.0 * sum(case when email_category = 'email_clicked' then 1 else 0 end)
 /sum(case when email_category = 'email_sent' then 1 else 0 end)
as clicking_rate
from
(
select *,
case when action in ('sent_weekly_digest', 'sent_reengagement_email')
 then 'email_sent'
 when action in ('email_open')
 then 'email_opened'
 when action in ('email_clickthrough')
 then 'email_clicked'
end as email_category
from email_event
) as email_engagement;

