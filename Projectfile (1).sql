create database project_PA905;
use project_PA905;

select * from maindata;

----------------------------------------------------------------------------------------------------------------
ALTER TABLE Maindata RENAME COLUMN `# Available Seats` to Available_Seats;
ALTER TABLE Maindata RENAME COLUMN `# Transported Passengers` to Transported_Passengers;
ALTER TABLE Maindata RENAME COLUMN `# Transported Freight` to Transported_Freight;
ALTER TABLE Maindata RENAME COLUMN `%Distance Group ID` to Distance_group_ID;
ALTER TABLE Maindata RENAME COLUMN `Month (#)` to Month;

-- View -----------------------------------------------
drop view if exists view_1;

CREATE VIEW View_1 AS
SELECT *,
       STR_TO_DATE(CONCAT(`Year`, '-', `Month`, '-', `Day`), '%Y-%m-%d') AS Date_Field,
       QUARTER(STR_TO_DATE(CONCAT(`Year`, '-', `Month`, '-', `Day`), '%Y-%m-%d')) AS Quarter
FROM Maindata;
----------------------------------------------------------------------------------------------------------------
/*
Q1. Calcuate the following fields from the Year Month (#) Day fields ( First Create a Date Field from Year , Month , Day fields)
A.Year
B.Monthno
C.Monthfullname
D.Quarter(Q1,Q2,Q3,Q4)
E. YearMonth ( YYYY-MMM)
F. Weekdayno
G.Weekdayname
H.FinancialMOnth
I. Financial Quarter
*/
SELECT
    `Year`,												# Q1.a
    `Month` AS Month_No,								# Q1.b
    `Day`,												
    MONTHNAME(Date_Field) AS monthfullname,				# Q1.c
    CONCAT('Q', QUARTER(Date_Field)) AS Quarter,    	# Q1.d
    DATE_FORMAT(Date_Field, '%Y-%b') AS YearMonth,  	# Q1.e
    DAYOFWEEK(Date_Field) AS Weekday_No,				# Q1.f
    DAYNAME(Date_Field) AS Weekday_Name,				# Q1.g
# Q1.h
    CASE
        WHEN MONTH(Date_Field) >= 4 THEN MONTH(Date_Field) - 3
        ELSE MONTH(Date_Field) + 9
    END AS FinancialMonth,
# Q1.i
    CASE
        WHEN MONTH(Date_Field) BETWEEN 4 AND 6 THEN 'FQ1'
        WHEN MONTH(Date_Field) BETWEEN 7 AND 9 THEN 'FQ2'
        WHEN MONTH(Date_Field) BETWEEN 10 AND 12 THEN 'FQ3'
        ELSE 'FQ4'
    END AS Financial_Quarter
FROM View_1;
----------------------------------------------------------------------------------------------------------------
# Q2. Find the load Factor percentage on a yearly , Quarterly , Monthly basis ( Transported passengers / Available seats).
SELECT
    `Year`,
    Quarter,
    `Month`,
    SUM(`Transported_Passengers`) AS total_passengers,
    SUM(`Available_Seats`) AS total_seats,
    ROUND(SUM(`Transported_Passengers`) / SUM(`Available_Seats`) * 100, 2) AS load_factor_percentage
FROM View_1
GROUP BY `Year`, Quarter, `Month`
ORDER BY `Year`, Quarter, `Month`;
----------------------------------------------------------------------------------------------------------------
# Q3. Find the load Factor percentage on a Carrier Name basis ( Transported passengers / Available seats).
SELECT `Carrier Name`,
	SUM(`Transported_Passengers`) AS `total_passengers`,
    SUM(`Available_Seats`) AS `total_seats`,
    ROUND(SUM(`Transported_Passengers`) / SUM(`Available_Seats`) * 100, 2) AS `load_factor_percentage`
from maindata
group by `Carrier Name` 
order by `load_factor_percentage` desc;
----------------------------------------------------------------------------------------------------------------
# Q4. Identify Top 10 Carrier Names based passengers preference.
SELECT `Carrier Name`,
	SUM(`Transported_Passengers`) AS `total_passengers`,
    SUM(`Available_Seats`) AS `total_seats`,
    ROUND(SUM(`Transported_Passengers`) / SUM(`Available_Seats`) * 100, 2) AS `load_factor_percentage`
from maindata
group by `Carrier Name` 
order by `total_passengers` desc limit 10;
----------------------------------------------------------------------------------------------------------------
# Q5. Display top Routes ( from-to City) based on Number of Flights.
select `From - To City`, count(`From - To City`) as No_flight from maindata
group by `From - To City` order by count(`From - To City`) desc limit 10;
----------------------------------------------------------------------------------------------------------------
# Q6. Identify the how much load factor is occupied on Weekend vs Weekdays.
SELECT
    CASE 
        WHEN DAYOFWEEK(Date_Field) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS DayCategory,
    SUM(`Transported_Passengers`) AS total_passengers,
    SUM(`Available_Seats`) AS total_seats,
    ROUND(SUM(`Transported_Passengers`) / SUM(`Available_Seats`) * 100, 2) AS load_factor_percentage
FROM View_1
GROUP BY DayCategory;
----------------------------------------------------------------------------------------------------------------
# Q7. Identify number of flights based on Distance group.
SELECT 
    IFNULL(`Distance_group_ID`, 'Total Flights') AS Distance_group_ID,
    COUNT(*) AS No_of_flight
FROM Maindata GROUP BY `Distance_group_ID` WITH ROLLUP;