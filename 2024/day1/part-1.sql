-- number each item in each list by its order
-- join the table on itself to get both lists in sorted order
-- get the distance of each pair and sum up the distances
with sorted as (
    select
        list1,
        list2,
        row_number() over (order by list1) as rn1,
        row_number() over (order by list2) as rn2
    from day_1_input
)
select sum(abs(a.list1 - b.list2))
from sorted a
join sorted b on a.rn1 = b.rn2
