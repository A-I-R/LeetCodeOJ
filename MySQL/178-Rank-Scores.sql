/*
Write a SQL query to rank scores. If there is a tie between two scores, both should have the same ranking. Note that after a tie, the next ranking number should be the next consecutive integer value. In other words, there should be no "holes" between ranks.

+----+-------+
| Id | Score |
+----+-------+
| 1  | 3.50  |
| 2  | 3.65  |
| 3  | 4.00  |
| 4  | 3.85  |
| 5  | 4.00  |
| 6  | 3.65  |
+----+-------+
For example, given the above Scores table, your query should generate the following report (order by highest score):

+-------+------+
| Score | Rank |
+-------+------+
| 4.00  | 1    |
| 4.00  | 1    |
| 3.85  | 2    |
| 3.65  | 3    |
| 3.65  | 3    |
| 3.50  | 4    |
+-------+------+
*/

select Score, (select count(distinct Score) from Scores tmp where sc.Score<=tmp.Score) as Rank from Scores as sc order by Rank;

select Score, (select count(*) from (select distinct Score from Scores) as tmp where sc.Score<=tmp.Score) as Rank from Scores as sc order by Rank;

select sc1.Score, count(distinct sc2.Score) as Rank from Scores as sc1 inner join Scores as sc2 on sc1.Score<=sc2.Score group by sc1.Id order by Rank;
