/*
The Employee table holds all employees. Every employee has an Id, a salary, and there is also a column for the department Id.

+----+-------+--------+--------------+
| Id | Name  | Salary | DepartmentId |
+----+-------+--------+--------------+
| 1  | Joe   | 70000  | 1            |
| 2  | Henry | 80000  | 2            |
| 3  | Sam   | 60000  | 2            |
| 4  | Max   | 90000  | 1            |
+----+-------+--------+--------------+
The Department table holds all departments of the company.

+----+----------+
| Id | Name     |
+----+----------+
| 1  | IT       |
| 2  | Sales    |
+----+----------+
Write a SQL query to find employees who have the highest salary in each of the departments. For the above tables, Max has the highest salary in the IT department and Henry has the highest salary in the Sales department.

+------------+----------+--------+
| Department | Employee | Salary |
+------------+----------+--------+
| IT         | Max      | 90000  |
| Sales      | Henry    | 80000  |
+------------+----------+--------+
*/

--Solution 1
select Department.Name as Department, e1.Name as Employee, e1.Salary from Employee as e1 left join Employee e2 on e1.DepartmentId=e2.DepartmentId and e1.Salary<e2.Salary inner join Department on e1.DepartmentId=Department.Id where e2.Id is null;

--Solution 2 (Best)
select Department.Name as Department, Employee.Name as Employee, Salary from Employee inner join Department on DepartmentId=Department.Id where not exists(select 1 from Employee as e where e.DepartmentId=Employee.DepartmentId and e.Salary>Employee.Salary);

--Solution 3
select D.Name as Department, E.Name as Employee, Salary from Employee as E inner join Department as D on DepartmentId=D.Id where (DepartmentId, Salary) in (select DepartmentId, max(Salary) from Employee group by DepartmentId);

--Solution 4
select D.Name as Department, E.Name as Employee, Salary from Employee as E inner join Department as D on DepartmentId=D.Id where Salary=(select max(Salary) from Employee tmp where tmp.DepartmentId=E.DepartmentId);