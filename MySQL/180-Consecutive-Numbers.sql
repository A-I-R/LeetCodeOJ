/*
Write a SQL query to find all numbers that appear at least three times consecutively.

+----+-----+
| Id | Num |
+----+-----+
| 1  |  1  |
| 2  |  1  |
| 3  |  1  |
| 4  |  2  |
| 5  |  1  |
| 6  |  2  |
| 7  |  2  |
+----+-----+
For example, given the above Logs table, 1 is the only number that appears consecutively for at least three times.

+-----------------+
| ConsecutiveNums |
+-----------------+
| 1               |
+-----------------+
*/

--Solution 1
select distinct t1.Num as ConsecutiveNums from Logs as t1 inner join Logs as t2 on (t1.Num=t2.Num and t2.Id=t1.Id+1) inner join Logs as t3 on (t1.Num=t3.Num and t3.Id=t2.Id+1);