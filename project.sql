
               --  Ajeet sql project mobility_analytics

SET GLOBAL local_infile = 1;
CREATE DATABASE mobility_analytics;
USE mobility_analytics;

CREATE TABLE cities (
  city_id VARCHAR(10) PRIMARY KEY,
  city_name VARCHAR(50),
  state VARCHAR(50),
  tier VARCHAR(10)
);

CREATE TABLE users (
  user_id VARCHAR(15) PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(150),
  phone VARCHAR(15),
  signup_date DATE,
  city_id VARCHAR(10),
  device_type VARCHAR(20),
  preferred_payment_mode VARCHAR(20),
  wallet_balance DECIMAL(10,2),
  referral_code VARCHAR(20),
  referred_by_user_id VARCHAR(15),
  rating DECIMAL(3,2),
  is_active TINYINT,
  total_rides INT,
  last_ride_date DATE,
  FOREIGN KEY (city_id) REFERENCES cities(city_id),
  FOREIGN KEY (referred_by_user_id) REFERENCES users(user_id)
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE '/Users/ajeetkumar/Downloads/mobility_data 2/users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(user_id, name, @email, @phone, signup_date, city_id, device_type,
 preferred_payment_mode, wallet_balance, referral_code, @referred_by_user_id,
 @rating, is_active, total_rides, @last_ride_date)
SET
  email = NULLIF(@email, ''),
  phone = NULLIF(@phone, ''),
  referred_by_user_id = NULLIF(@referred_by_user_id, ''),
  rating = NULLIF(@rating, ''),
  last_ride_date = NULLIF(@last_ride_date, '');
  
  SHOW GLOBAL VARIABLES LIKE 'local_infile';
  
  SHOW WARNINGS;
  
  select version();
  select * from users;
  
  
  
  CREATE TABLE cities (
  city_id VARCHAR(10) PRIMARY KEY,
  city_name VARCHAR(50),
  state VARCHAR(50),
  tier VARCHAR(10)
);

LOAD DATA LOCAL INFILE '/Users/ajeetkumar/Downloads/mobility_data 2/cities.csv'
INTO TABLE cities
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from cities;



CREATE TABLE drivers (
  driver_id VARCHAR(15) PRIMARY KEY,
  name VARCHAR(100),
  phone VARCHAR(15),
  city_id VARCHAR(10),
  join_date DATE,
  license_number VARCHAR(20),
  vehicle_id VARCHAR(15),
  linked_user_id VARCHAR(15),
  rating DECIMAL(3,2),
  total_rides_completed INT,
  is_active TINYINT,
  background_check_status VARCHAR(20),
  weekly_hours_online DECIMAL(4,1),
  acceptance_rate DECIMAL(4,1),
  cancellation_rate DECIMAL(4,1),
  FOREIGN KEY (city_id) REFERENCES cities(city_id),
  FOREIGN KEY (linked_user_id) REFERENCES users(user_id)
);

LOAD DATA LOCAL INFILE '/Users/ajeetkumar/Downloads/mobility_data 2/drivers.csv'
INTO TABLE drivers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(driver_id, name, phone, city_id, join_date, license_number, vehicle_id,
 @linked_user_id, rating, total_rides_completed, is_active, @bg_status,
 weekly_hours_online, acceptance_rate, cancellation_rate)
SET
  linked_user_id = NULLIF(@linked_user_id, ''),
  background_check_status = NULLIF(@bg_status, '');
  
select * from drivers;

select 
	*
from users as u
join drivers as d
on u.user_id = d.linked_user_id;

-- select * from users;

CREATE TABLE vehicles (
  vehicle_id VARCHAR(15) PRIMARY KEY,
  driver_id VARCHAR(15),
  vehicle_type VARCHAR(20),
  make VARCHAR(50),
  model VARCHAR(50),
  year INT,
  registration_number VARCHAR(20),
  fuel_type VARCHAR(20),
  insurance_expiry_date DATE,
  last_service_date DATE,
  FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
);


LOAD DATA LOCAL INFILE '/Users/ajeetkumar/Downloads/mobility_data 2/vehicles.csv'
INTO TABLE vehicles
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(vehicle_id, driver_id, vehicle_type, make, model, year,
 registration_number, fuel_type, insurance_expiry_date, @last_service_date)
SET last_service_date = NULLIF(@last_service_date, '');

ALTER TABLE drivers ADD CONSTRAINT fk_driver_vehicle
FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id);

select * from vehicles;




CREATE TABLE rides (
  ride_id VARCHAR(15) PRIMARY KEY,
  user_id VARCHAR(15),
  driver_id VARCHAR(15),
  vehicle_id VARCHAR(15),
  city_id VARCHAR(10),
  pickup_time DATETIME,
  drop_time DATETIME,
  distance_km DECIMAL(6,2),
  duration_min DECIMAL(6,1),
  base_fare DECIMAL(10,2),
  surge_multiplier DECIMAL(3,2),
  total_fare DECIMAL(10,2),
  payment_mode VARCHAR(20),
  ride_status VARCHAR(15),
  cancellation_reason VARCHAR(100),
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id),
  FOREIGN KEY (city_id) REFERENCES cities(city_id)
);

LOAD DATA LOCAL INFILE '/Users/ajeetkumar/Downloads/mobility_data 2/rides.csv'
INTO TABLE rides
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ride_id, user_id, driver_id, vehicle_id, city_id, pickup_time,
 @drop_time, @distance_km, @duration_min, @base_fare, @surge_multiplier,
 total_fare, payment_mode, ride_status, @cancellation_reason)
SET
  drop_time = NULLIF(@drop_time, ''),
  distance_km = NULLIF(@distance_km, ''),
  duration_min = NULLIF(@duration_min, ''),
  base_fare = NULLIF(@base_fare, ''),
  surge_multiplier = NULLIF(@surge_multiplier, ''),
  cancellation_reason = NULLIF(@cancellation_reason, '');
  
  
select count(*) from rides;
select * from rides
join users
where rides.user_id = users.user_id;



CREATE TABLE payments (
  payment_id VARCHAR(15) PRIMARY KEY,
  ride_id VARCHAR(15),
  amount DECIMAL(10,2),
  payment_mode VARCHAR(20),
  payment_status VARCHAR(15),
  transaction_id VARCHAR(20),
  timestamp DATETIME,
  wallet_used TINYINT,
  cashback_applied DECIMAL(8,2),
  FOREIGN KEY (ride_id) REFERENCES rides(ride_id)
);

LOAD DATA LOCAL INFILE '/Users/ajeetkumar/Downloads/mobility_data 2/payments.csv'
INTO TABLE payments
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(payment_id, ride_id, amount, payment_mode, payment_status,
 @transaction_id, timestamp, wallet_used, @cashback_applied)
SET
  transaction_id = NULLIF(@transaction_id, ''),
  cashback_applied = NULLIF(@cashback_applied, '');
  
  
  
  CREATE TABLE ratings_feedback (
  feedback_id VARCHAR(15) PRIMARY KEY,
  ride_id VARCHAR(15),
  user_rating DECIMAL(3,1),
  driver_rating DECIMAL(3,1),
  user_comment VARCHAR(255),
  driver_comment VARCHAR(255),
  feedback_tags VARCHAR(50),
  FOREIGN KEY (ride_id) REFERENCES rides(ride_id)
);

LOAD DATA LOCAL INFILE '/Users/ajeetkumar/Downloads/mobility_data 2/ratings_feedback.csv'
INTO TABLE ratings_feedback
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(feedback_id, ride_id, user_rating, @driver_rating, @user_comment,
 @driver_comment, @feedback_tags)
SET
  driver_rating = NULLIF(@driver_rating, ''),
  user_comment = NULLIF(@user_comment, ''),
  driver_comment = NULLIF(@driver_comment, ''),
  feedback_tags = NULLIF(@feedback_tags, '');
  
  
  
  
  
  
CREATE TABLE promotions (
  coupon_id VARCHAR(15) PRIMARY KEY,
  ride_id VARCHAR(15),
  coupon_code VARCHAR(20),
  campaign_name VARCHAR(50),
  discount_type VARCHAR(15),
  discount_value DECIMAL(6,2),
  discount_amt DECIMAL(8,2),
  valid_from DATE,
  valid_to DATE,
  FOREIGN KEY (ride_id) REFERENCES rides(ride_id)
);

LOAD DATA LOCAL INFILE '/Users/ajeetkumar/Downloads/mobility_data 2/promotions.csv'
INTO TABLE promotions
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


select * from payments;

-- some questions from this dataset

-- 1. Find the total number of users in each city.

SELECT
c.city_name,
COUNT(u.user_id) AS total_users
FROM cities c
JOIN users u
ON c.city_id = u.city_id
GROUP BY c.city_name;

-- 2-- . Find the top 10 users who spent the most money.

select
sum(p.amount) as spent_money ,r.user_id
from payments as p
join rides as r
on p.ride_id = r.ride_id
join users as u
on r.user_id =u.user_id
group by r.user_id
order by sum(p.amount)desc
limit 10;


-- 3. Find the city having the highest revenue.
SELECT
c.city_name,
SUM(r.total_fare) AS revenue
FROM rides r
JOIN cities c
ON r.city_id=c.city_id
WHERE ride_status='Completed'
GROUP BY c.city_name
ORDER BY revenue DESC
LIMIT 1;

-- 4. Find the average driver rating in each city.
SELECT
c.city_name,
ROUND(AVG(d.rating),2) AS avg_rating
FROM drivers d
JOIN cities c
ON d.city_id=c.city_id
GROUP BY c.city_name;

-- 5. Find drivers whose rating is above the overall average rating.

SELECT
driver_id,
name,
rating
FROM drivers
WHERE rating>
(
SELECT AVG(rating)
FROM drivers
);

-- 6. Find top 5 drivers with the highest completed rides.

SELECT
driver_id,
name,
total_rides_completed
FROM drivers
ORDER BY total_rides_completed DESC
LIMIT 5;

-- 7. Find monthly revenue as total fare

SELECT
MONTH(pickup_time) AS month_no,
SUM(total_fare) AS revenue
FROM rides
WHERE ride_status='Completed'
GROUP BY MONTH(pickup_time)
ORDER BY month_no;

-- 8. Find the most preferred payment mode.

select
payment_mode,
count(payment_id) as no_of_time_used
from payments
group by payment_mode
order by count(payment_id) desc
limit 1;

-- 9. Find users who never booked any ride

with cte as (
select
r.user_id ,
u.name
from rides as r
left join users as u
on r.user_id = u.user_id)
select
* 
from cte;


-- 10. Find drivers who completed more than 100 rides.


SELECT
driver_id,
name,
total_rides_completed
FROM drivers
WHERE total_rides_completed>100;


-- 11. Rank drivers based on completed rides.

select
name,
sum(total_rides_completed) as completed_ride ,
dense_rank() over(order by sum(total_rides_completed)desc) as rnk
from drivers
group by name;


-- 12. Find each city's revenue contribution (%).

SELECT
c.city_name,
SUM(r.total_fare) revenue,
ROUND(
SUM(r.total_fare)*100/
(
SELECT SUM(total_fare)
FROM rides
WHERE ride_status='Completed'
),2) contribution
FROM rides r
JOIN cities c
ON r.city_id=c.city_id
WHERE ride_status='Completed'
GROUP BY c.city_name;

-- 13. Find the second highest spending user.

WITH cte AS
(
SELECT
u.user_id,
u.name,
SUM(r.total_fare) spent,
DENSE_RANK() OVER
(ORDER BY SUM(r.total_fare) DESC) rn
FROM users u
JOIN rides r
ON u.user_id=r.user_id
WHERE ride_status='Completed'
GROUP BY u.user_id,u.name
)

SELECT *
FROM cte
WHERE rn=2;

-- 14. Find the running total of revenue.
SELECT
DATE(pickup_time) ride_date,
SUM(total_fare) revenue,
SUM(SUM(total_fare))
OVER(ORDER BY DATE(pickup_time))
running_total
FROM rides
WHERE ride_status='Completed'
GROUP BY DATE(pickup_time);

-- 15. Find top-rated driver in every city.
WITH cte AS
(
SELECT
c.city_name,
d.driver_id,
d.name,
d.rating,
DENSE_RANK() OVER
(PARTITION BY c.city_name
ORDER BY d.rating DESC) rn
FROM drivers d
JOIN cities c
ON d.city_id=c.city_id
)

SELECT *
FROM cte
WHERE rn=1;

-- 16. Find users who spent more than the average spending.

WITH cte AS
(
SELECT
user_id,
SUM(total_fare) spent
FROM rides
WHERE ride_status='Completed'
GROUP BY user_id
)

SELECT *
FROM cte
WHERE spent>
(
SELECT AVG(spent)
FROM cte
);

-- 17. Find the most cancelled city.

SELECT
c.city_name,
COUNT(*) cancellations
FROM rides r
JOIN cities c
ON r.city_id=c.city_id
WHERE ride_status='Cancelled'
GROUP BY c.city_name
ORDER BY cancellations DESC
LIMIT 1;

-- 18. Find drivers who earned more than ₹10,000.

select
d.driver_id , d.name,
sum(r.total_fare) as earning
from drivers as d
join rides as r
on d.driver_id = r.driver_id
where r.ride_status = "completed"
group by d.driver_id , d.name
having earning > 10000;


-- 19. Find each driver's revenue rank inside their city.
WITH cte AS
(
SELECT
c.city_name,
d.driver_id,
d.name,
SUM(r.total_fare) revenue
FROM drivers d
JOIN rides r
ON d.driver_id=r.driver_id
JOIN cities c
ON d.city_id=c.city_id
WHERE ride_status='Completed'
GROUP BY c.city_name,d.driver_id,d.name
)

SELECT *,
DENSE_RANK() OVER
(PARTITION BY city_name
ORDER BY revenue DESC) ranking
FROM cte;


-- 20. Find the top 3 highest revenue cities.
WITH cte AS
(
SELECT
c.city_name,
SUM(r.total_fare) revenue,
DENSE_RANK() OVER
(ORDER BY SUM(r.total_fare) DESC) rn
FROM rides r
JOIN cities c
ON r.city_id=c.city_id
WHERE ride_status='Completed'
GROUP BY c.city_name
)

SELECT *
FROM cte
WHERE rn<=3;

-- 21. Find Daily Revenue with Running Total
SELECT
DATE(pickup_time) AS ride_date,
SUM(total_fare) AS daily_revenue,
SUM(SUM(total_fare)) OVER(
ORDER BY DATE(pickup_time)
) AS running_total
FROM rides
WHERE ride_status='Completed'
GROUP BY DATE(pickup_time);



-- - 23. Running Total of Revenue for Each City
SELECT
c.city_name,
DATE(r.pickup_time) AS ride_date,
SUM(r.total_fare) AS daily_revenue,
SUM(SUM(r.total_fare)) OVER(
PARTITION BY c.city_name
ORDER BY DATE(r.pickup_time)
) AS city_running_total
FROM rides r
JOIN cities c
ON r.city_id = c.city_id
WHERE r.ride_status='Completed'
GROUP BY c.city_name, DATE(r.pickup_time);


-- 24. Running Total of Driver Earnings

SELECT
d.driver_id,
d.name,
DATE(r.pickup_time) AS ride_date,
SUM(r.total_fare) AS daily_earning,
SUM(SUM(r.total_fare)) OVER(
PARTITION BY d.driver_id
ORDER BY DATE(r.pickup_time)
) AS running_earning
FROM rides r
JOIN drivers d
ON r.driver_id=d.driver_id
WHERE r.ride_status='Completed'
GROUP BY d.driver_id,d.name,DATE(r.pickup_time);






