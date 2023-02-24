create database portfolio_project;

use portfolio_project;


CREATE TABLE goldusers_signup(userid integer,gold_signup_date varchar(20)); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');


CREATE TABLE users(userid integer,signup_date varchar(20) ); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');


CREATE TABLE sales(userid integer,created_date varchar(20), product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);



select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;



use portfolio_project;

# 1. Changing the Datatype from varchar to date.

update sales
set created_date = str_to_date(created_date , '%m-%d-%Y' );

Alter table sales
modify  created_date date;

# 2. What is the total amount spent by each Customer on zoomato?

select a.userid, sum(b.price) as Total_amount_spent from sales as a inner join product as b on a.product_id = b.product_id
group by userid;

# 3. How many days has each customer visited Zomato?

select userid, count(distinct created_date) as No_of_Days from sales
group by userid;

# 4. What was the first product purchased by each Customer?
select * from
(select *, rank() over (partition by userid order by created_date) as Rnk from sales) as a
where Rnk = 1;

# 5. What is the most purcahsed item on the menu and How many times each customer bought it?

select userid, count(product_id) as Cnt from sales where product_id =
 (select product_id from sales 
 group by product_id
 order by count(product_id) desc
 limit 1)
 group by userid;
 
 # 6.Which item was the most popular for each Customer?
 
 select * from
 (select * , rank() over (partition by userid order by cnt desc) as Rnk from
 (select userid, product_id, count(Product_id) as cnt from sales
 group by userid, product_id) as a) as b
 where Rnk =1;
 
 # 7. Which item was first purhased by the customer after becoming a gold member?
 
 select d.* from
 (select c.*, rank() over(partition by userid order by created_date) as Rnk from 
 (select a.userid, a.product_id, a.created_date,b.gold_signup_date from sales as a 
 inner join goldusers_signup as b on a.userid = b.userid and created_date >= gold_signup_date) as c)as d
 where rnk =1;
 
 # 8.Which item was purchased by the customer just before becoming a gold member?
 
select d.* from
 (select c.*, rank() over(partition by userid order by created_date desc) as Rnk from 
 (select a.userid, a.product_id, a.created_date,b.gold_signup_date from sales as a 
 inner join goldusers_signup as b on a.userid = b.userid and created_date <= gold_signup_date) as c)as d
 where rnk =1;
 
 # 9. what is the total orders and amount spend by each member before they became a gold memeber?
 
 select userid, count(created_date) as NO_of_items , sum(price) as Amount_spent from
 (select c.*, d.price from 
 (select a.userid, a.product_id, a.created_date,b.gold_signup_date from sales as a 
 inner join goldusers_signup as b on a.userid = b.userid and created_date <= gold_signup_date) as c
 inner join product as d on c.product_id = d.product_id) as e
 group by userid
 order by userid;
 
 # 10. If buying each product generates points and each product has different purchasing points
    #for P1 5rs = 1 point, p2 10 rs = 5 points, p3 5rs = 1 point -- (2rs = 1point) --
    #calculate no. of points earned by each customer and for which product most points have been earned? 
    
    use portfolio_project;

select f.userid, sum(points_earned) from
(select e.*, amt/points as points_earned from
(select d.*, case when product_id = 1 then 5 when product_id = 2 then 2 when product_id = 3 then 5 else 0 end as points from
    (select c.userid,c.product_id, sum( c.price) as amt from
   ( select a.*,b.price from sales as a inner join product as b on a.product_id = b.product_id ) as c
    group by userid, product_id
    order by userid) as d) as e) as f
    group by userid;
    
select f.product_id, sum(points_earned) from
(select e.*, amt/points as points_earned from
(select d.*, case when product_id = 1 then 5 when product_id = 2 then 2 when product_id = 3 then 5 else 0 end as points from
    (select c.userid,c.product_id, sum( c.price) as amt from
   ( select a.*,b.price from sales as a inner join product as b on a.product_id = b.product_id ) as c
    group by userid, product_id
    order by userid) as d) as e) as f
    group by f.product_id
    order by sum(points_earned) desc
    limit 1;
    
    # 11. In the first one year after a customer joined the gold program, irrespectie of what the customer has purchased they earn 5 points
    # for eery 10rs spent who earned most and what was there earnings in the first year?
    
     use portfolio_project;
   SELECT 
    c.*, d.price * 0.5 as total_point_earnings
FROM
    (SELECT 
        a.userid, a.product_id, a.created_date, b.gold_signup_date
    FROM
        sales AS a
    INNER JOIN goldusers_signup AS b ON a.userid = b.userid
        AND created_date >= gold_signup_date
        AND created_date <= DATE_ADD(gold_signup_date, INTERVAL 365 DAY)) AS c
        INNER JOIN
    product AS d ON c.product_id = d.product_id
    order by total_point_earnings desc;
    
    #12. Rank all the Transactions of the customers
    
    select *, rank() over(partition by userid order by product_id) from sales
    order by userid;
    
    # 13. Rank all the Transactions of the customers when ever they are gold members, for every non gold member mark rank as na.alter
    
    
    select d.*, case when Rnk = 0 then 'na' else Rnk end as Rnk from
    (select c.*, 
    cast((case when gold_signup_date is null then 0 else rank() over (partition by userid order by created_date desc) end) as char)
    as Rnk from
    (select a.userid, a.product_id, a.created_date,b.gold_signup_date from sales as a 
 left join goldusers_signup as b on a.userid = b.userid and created_date >= gold_signup_date) as c) as d;
    
    
    
 
 
 
 
 
 
 
 





 






