create table day_1_input (
    list1 int,
    list2 int
);

-- download the file first from https://adventofcode.com/2024/day/1/input
create temporary table temp_numbers (
    raw_line text
);

-- Load the raw data
copy temp_numbers (raw_line)
from '/path/to/input.txt';

-- insert into the final table, splitting the string
insert into day_1_input (list1, list2)
select
    trim(split_part(raw_line, ' ', 1))::integer as list1,
    trim(split_part(raw_line, ' ', 4))::integer as list2
from temp_numbers;

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
), distances as (
    select abs(a.list1 - b.list2) as distance
    from sorted a
    join sorted b on a.rn1 = b.rn2
)
select sum(distance)
from distances;