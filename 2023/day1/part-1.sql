create table day_1_input(line text)
-- download the file first
COPY day_1_input FROM '/users/yeedle/Downloads/input.txt' WITH (FORMAT text);

select
    sum(
        (substring(line from '[0-9]') || substring(line from '([0-9])[^0-9]*$'))::int
    ) as solution
from day_1_input
;