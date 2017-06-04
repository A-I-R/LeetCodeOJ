/*
Write a SQL query to delete all duplicate email entries in a table named Person, keeping only unique emails based on its smallest Id.

+----+------------------+
| Id | Email            |
+----+------------------+
| 1  | john@example.com |
| 2  | bob@example.com  |
| 3  | john@example.com |
+----+------------------+
Id is the primary key column for this table.
For example, after running your query, the above Person table should have the following rows:

+----+------------------+
| Id | Email            |
+----+------------------+
| 1  | john@example.com |
| 2  | bob@example.com  |
+----+------------------+
*/

--Solution 1
delete from Person where id in (select id from (select id from Person p1 where exists(select 1 from Person p2 where p1.Email=p2.Email and p1.Id>p2.Id)) as tmp);

--Solution 2 (Best)
delete from Person where Id not in (select Id from (select min(Id) as Id from Person group by Email) as tmp);

--Solution 3
delete p1 from Person as p1 inner join Person as p2 on p1.Email=p2.Email where p1.Id>p2.Id;

--Solution 4
delete p1 from Person as p1 inner join Person as p2 on p1.Email=p2.Email and p1.Id>p2.Id;