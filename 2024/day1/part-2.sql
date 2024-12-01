-- read the file the same way part-1.sql does

-- get counts of eqach item in list 2
with counts as (
    select list2, count(*) count
    from day_1_input
    group by list2
), 
-- left join the counts on list 1 and multiply each item in list 1 by the counts of list 2
similarities as (
    select list1 * coalesce(count, 0) score
    from day_1_input
    left join counts on day_1_input.list1 = counts.list2
)
select sum(score)
from similarities;
