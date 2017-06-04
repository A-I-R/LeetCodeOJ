MySQL解题总结及注意事项
======
<br />

## SQL语句语法相关

#### SQL select语句的执行顺序
原文参考：[关于sql和MySQL的语句执行顺序](http://blog.csdn.net/u014044812/article/details/51004754)

	from->join->on->where->group by->avg,sum...->having->select->distinct->order by
所有的查询语句都是从from开始执行的，在执行过程中，每个步骤都会为下一个步骤生成一个虚拟表（VT），这个虚拟表将作为下一个执行步骤的输入：
1. 首先对`from`子句中的前两个表执行笛卡尔乘积，此时生成虚拟表VT1（选择相对小的表做基础表）。
2. 应用`on`筛选器，`on`中的逻辑表达式将应用到VT1中的各个行，筛选出满足`on`逻辑表达式的行，生成虚拟表 VT2。
3. 如果是`outer join`那么这一步就将添加外部行。`left outer join`就把左表在第二步中过滤的添加进来，如果是`right outer join`那么就将右表在第二步中过滤掉的行添加进来，这样生成虚拟表VT3。
4. 如果`from`子句中的表数目多于两个表，那么就将VT3与第三个表计算笛卡尔乘积，生成虚拟表，该过程就是一个重复1-3的步骤，最终得到一个新的虚拟表VT3。 
5. 应用`where`筛选器，对上一步生产的虚拟表应用`where`筛选器，生成虚拟表VT4。
6. 应用`group by`子句，将VT4中的唯一的值组合成为一组，得到虚拟表VT5。如果应用了`group by`，那么后面的所有步骤都只能得到VT5的列或者是聚合函数（count、sum、avg等）。原因在于最终的结果集中只为每个组包含一行。
7. 应用`cube`或者`rollup`选项，为VT5生成超组，生成VT6。
8. 应用`having`筛选器，生成VT7。`having`筛选器是唯一一个应用到已分组数据的筛选器。
9. 处理`select`子句，将VT7中需要在`select`中出现的列筛选出来，生成VT8。
10. 应用`distinct`子句，VT8中移除相同的行，生成VT9。事实上如果应用了`group by`子句那么`distinct`是多余的，原因同样在于，分组的时候是将列中唯一的值分成一组，同时只为每一组返回一行记录，那么所以的记录都将是不相同的。
11. 应用`order by`子句。按照order_by_condition排序VT9，此时返回的是一个游标，而不是虚拟表。SQL是基于集合的，集合不会预先对它的行排序，它只是成员的逻辑集合，成员的顺序是无关紧要的。对表进行排序的查询会返回一个对象，这个对象包含特定的物理顺序的逻辑组织。这个对象就叫游标。排序是很需要成本的，除非你必须要排序，否则最好不要指定`order by`。这是唯一一个可以使用`select`列表中列别名的步骤。
12. 应用`limit`选项。此时才返回结果给请求者。

--------

#### `using`的使用方式
`using`子句可以用于join连接。当需要连接的两端字段名称完全一样的时候，可以使用USING(字段名)来取代a.字段名=b.字段名。可以提高语句执行的效率。

--------

#### Alias相关问题
* 当select from 后面跟的是select语句查出来的集合时，该集合必须设置一个别名，即使别名毫无意义。否则无法执行。
* 定义别名时可以省略AS。即`select * from Person (AS) p`。

--------

#### `where`、`on`与`having`的区别
* `where`：最常用，进行筛选。在三个子句（`where`、`on`、`having`）之中执行的时间在中间。可以理解为对表中所有的记录进行循环，符合`where`后面条件的记录就输出，不符合条件的记录就不输出。
* `on`：与`join`联用，可以进行筛选（将筛选条件写在on语句中，不能进行单表筛选）。在三个子句中执行时间最早。由上面[SQL select语句的执行顺序](#关于sql和MySQL的语句执行顺序)可知，对于内连接和外连接，数据库都需要先取两张表的笛卡尔积，再根据`on`中的条件进行筛选。但是由于内/外连接在`on`子句完成后的步骤不同，因此最后筛选效果也不同：
>* 在`inner join`中，不会在完成`on`筛选后在结果集中补充不匹配的记录。因此表现为对两张表共同筛选，与`where`效果相同。
>* 在`left/right join`中，会在完成`on`筛选后在结果集中补充左/右表中不匹配的记录（这里与`inner join`不同）。因此表现为不影响最后输出的总行数（即不会筛选掉左/右表中的记录），但是会阻止不满足条件的行进行匹配（例如，如果在`on`中规定A表中的字段满足一定条件，B表中的字段满足一定条件，则当A、B表左连接时，还是会返回A表中的所有记录，但是两张表中不满足条件的行将不进行互相匹配，在最后的结果中表现为null）。
* `having`：与`where`相近，进行筛选。在三个子句中执行时间最晚，在聚合函数之后执行。与`where`的区别除了执行的时机之外，还有`having`子句中可以出现聚合函数，`where`子句中则不行。在没有聚合函数和`group by`子句的情况下，两者的含义基本相同，可以互换使用。

--------

#### 关于`inner join...on` 与 `where`的选择
`inner join...on`与`where`在效果上相同。在执行效率上，似乎`where`的效率更高（在MySQL中是这样）。但是并不建议在太复杂的查询中使用`where`替代`inner join...on`，因为这会使语句可读性变差。此外，微软在SQL Server中好像正在逐渐废弃`where`的写法。
因此推荐使用`inner join...on`。

--------

#### `exists`的使用方式
`exists`是特殊的子句，一般在`where`、`on`、`having`子句中使用，后面跟子查询。

它判断后面跟着的子查询是否有记录返回，如果有记录返回，则整个`exists`返回`true`；若没有记录返回，则返回`false`。`exists`的返回值与后面跟着的子查询的具体结果无关，它只关心子查询是否有结果返回，返回1行与返回1K行是一样的。

`exists`可以通过返回值的`true`和`false`来控制是否返回该行。

以`183-Customers-Who-Never-Order`中的`Solution 3`为例：
`select A.Name as Customers from Customers A where not exists (select 1 from Orders B, Customers C where A.Id = B.CustomerId);`
对于`Customers`表中的每一条记录，都与`Orders`表进行关联，根据是否存在返回记录判断该条记录在`Orders`表中有无对应的记录。若有，则`exists`返回`true`，经过`not`反转变成`false`，则该条记录不会被查询到。否则，该条记录会被查询到。这样就可以查询出`Customers`表中无法与`Orders`表对应的记录，即那些从来没有买过东西的顾客。

--------

### `distinct`关键字的用法
`distinct`可以删除重复的数据，使用的方法有两种：
>* 跟在`select`后面，删除重复的数据行。这种是最常用的。
>* 出现在聚合函数（如count等）后面的参数中（如count(distinct XXX)），可以单独在该函数的计算中去除重复数据。但是这种方法会降低比较多的效率。

--------

### `select`语句嵌套在`select list`中
`select`语句可以嵌套，大多数的嵌套出现在`from`和`where`子句中。而在用`select`语句筛选所需要的数据列的过程中，也可以进行嵌套。

例如，`178-Rank-Scores`中的`Solution 1`，`select Score, (select count(distinct Score) from Scores tmp where sc.Score<=tmp.Score) as Rank from Scores as sc order by Rank;`。对于查询出的每一行数据，在执行`select`语句筛选所需的列的时候，对于在查询结果中的每一行数据，都会执行一遍`select list`中嵌套的`select`语句，获取查询出的数据拼接在最后的结果中。

有一点需要注意，在`select list`中嵌套的`select`子查询，对主查询结果中的每一行数据执行的时候，最多只能返回一行数据。如果返回的数据超过一行，数据库将会报错。（例如，上面的例子中，如果子查询`select count(distinct Score) from Scores tmp where sc.Score<=tmp.Score`对于主查询结果集中的每一行数据返回超过一行的话，数据库就会报错，因为数据库不知道到底要附加哪一行数据到结果集中。这点和两表连接不同，两表连接的时候如果出现A表中的一行数据匹配B表中的多行数据，则所有匹配的数据都将被一一罗列。）

--------

### `group by`语句的一些事项
在MySQL中，如果使用了`group by`子句，则跟在`group by`后面的字段不一定需要出现在`select list`中。换句话说，我可以按照某一字段进行分组聚合，而在最后的结果集中不选择该字段。

其它类型的数据库没有验证过。

--------

### `delete`语句的使用
1. 简单的`delete`语句为`delete from XXX(表名) where XXX`
2. 如果`delete from`后面的表名使用了别名（`as`），则在`delete`与`from`之间一定要出现表的别名。例如`delete t1 from XXX as t1 where XXX`，如果删除`delete`后面的`t1`则会报语法错误。
3. `delete`可以删除多张表。例如`delete t1, t2 from t1, t2 where XXX`。具体注意事项如下：
	1. `from`后面如果跟多个表的话，则`from`前面一定要加上需要删除的表名（删除单表可以不加）。否则MySQL不知道删除哪张表的数据。
	2. 在`from`后面出现出现出现多个表时，只有出现在`from`前面的表才会被删除。例如，`delete t1 from t1, t2`就只会删除t1中的数据，t2中的数据在过程中只作为参考，不会被删除。
	3. 从from开始后面的部分与select没有什么区别。判断某表中某行数据是否会被删除主要从两个方面决定：
		1. delete后面有没有出现该表的名称（单表删除的话忽略此条）。
		2. 将delete替换为select * 后该表中的该行数据有没有出现在结果集中，如果出现，则会被删除，反之则不会（其实就是是否满足后面的条件）。例如`196-Delete-Duplicate-Emails`中的`Solution 3`： `delete p1 from Person as p1 inner join Person as p2 on p1.Email=p2.Email where p1.Id>p2.Id;`，只会删除Person表中`Email`有重复，且`Id`不是重复的`Email`中最小的数据行。
4. 在MySQL中，还存在另一个问题。就是当按照正常的顺序写完`delete`语句后（例如`delete from Person where Id not in (select min(Id) as Id from Person group by Email);`），运行后会发现报错（`You can't specify target table 'Person' for update in FROM clause`）。原因是MySQL不允许对于一个表查询（`from`该表）后将返回值用来删除同一张表中的数据。要解决这个问题，方法很简单。就是在子查询外面再套一层`select`（`delete from Person where Id not in (select Id from (select min(Id) as Id from Person group by Email) as tmp);`），让数据库误认为这个结果不是从这张表里查询出来的即可。只有MySQL有这个问题。

--------

## SQL技巧相关
* 巧用自相关来查重，即自己与自己join。
