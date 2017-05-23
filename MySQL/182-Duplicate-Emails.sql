/*
Write a SQL query to find all duplicate emails in a table named Person.

+----+---------+
| Id | Email   |
+----+---------+
| 1  | a@b.com |
| 2  | c@d.com |
| 3  | a@b.com |
+----+---------+
For example, your query should return the following for the above table:

+---------+
| Email   |
+---------+
| a@b.com |
+---------+
Note: All emails are in lowercase.
*/

--Solution 1
select Email from (select Email, count(*) as num from Person group by Email having num >1) as tmp;

--Solution 2
select Email from Person group by Email having count(Email)>1;

--Solution 3
select Email from Person group by Email having count(*)>1;

--Solution 4 (Best)
select distinct p1.Email from Person p1 INNER JOIN Person p2 on p1.Email = p2.Email where p1.Id <> p2.Id;
--Id is unique. Using table Person inner join itself will put Id together and then pick the record with different Ids.
