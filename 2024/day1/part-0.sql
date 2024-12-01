-- read in the data
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