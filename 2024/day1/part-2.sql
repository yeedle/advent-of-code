-- use a correlated subquery to get counts for each item in list 1,
-- multiply by the count, and sum it up
select sum(list1 * (
    select count(*)
     from day_1_input b
     where b.list2 = a.list1)
)
from day_1_input a;
