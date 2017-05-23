/*
Given a Weather table, write a SQL query to find all dates' Ids with higher temperature compared to its previous (yesterday's) dates.

+---------+------------+------------------+
| Id(INT) | Date(DATE) | Temperature(INT) |
+---------+------------+------------------+
|       1 | 2015-01-01 |               10 |
|       2 | 2015-01-02 |               25 |
|       3 | 2015-01-03 |               20 |
|       4 | 2015-01-04 |               30 |
+---------+------------+------------------+
For example, return the following Ids for the above Weather table:
+----+
| Id |
+----+
|  2 |
|  4 |
+----+
*/

--Solution 1
select Id from Weather as w1 where exists (select * from Weather as w2 where w1.Temperature>w2.Temperature and datediff(w1.Date, w2.Date)=1);

--Solution 2
select w1.Id from Weather as w1 left join Weather as w2 on (datediff(w1.Date, w2.Date)=1) where w2.Temperature is not null and w1.Temperature>w2.Temperature;

--Solution 3 (Best)
select w1.Id from Weather w1, Weather w2 where (DATEDIFF(w1.Date, w2.Date) = 1) AND w1.Temperature > w2.Temperature;