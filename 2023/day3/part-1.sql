create table day_3_input(
    row_number serial,
    row text
);

COPY day_3_input(row) from '/users/yeedle/Downloads/input.txt' with (format text)

-- The solution here deconstructs every row into individual characters
-- this lets us join the table on itself 8 times for each of the 8 possible symbol positions
-- pos0, pos1, pos2
-- pos3, char, pos4
-- pos5, pos6, pos7
-- To get the back the numbers from the deconstructed string, the "Gaps and Islands" approach is used 
-- to identify where a number starts

with
    characters as (
        select
            row_number,
            row,
            character,
            index,
            case
                when
                    regexp_match(
                        lag(character) over (
                            partition by row_number order by row_number, index
                        ),
                        '[0-9]'
                    )
                    is null -- if the previous character is not a digit
                    and regexp_match(character, '[0-9]') is not null -- and the current character is a digit
                then 1 -- then it's the start of a number
                else 0
            end as gap -- we identify the "gap" (i.e. where the number starts) so that we can mark the "islands" (each number)
        from day_3_input, unnest(regexp_split_to_array(row, '')) -- split each row into individual characters
        with ordinality a(character, index) -- get the index for each character
    ),
    islands as (
        -- using the rolling sum window function, give each number an id
        select *, sum(gap) over (order by row_number, index) island from characters
    ),
    has_adjacent_symbol as (
        -- we join the table on itself for each position we need to check for a symbol
        select (string_agg(islands.character, ''))::int part_number
        from islands
        left join
            islands pos0
            on islands.row_number = pos0.row_number + 1
            and islands.index = pos0.index + 1
            and regexp_match(pos0.character, '[0-9\.]') is null
        left join
            islands pos1
            on islands.row_number = pos1.row_number + 1
            and islands.index = pos1.index
            and regexp_match(pos1.character, '[0-9\.]') is null
        left join
            islands pos2
            on islands.row_number = pos2.row_number + 1
            and islands.index = pos2.index - 1
            and regexp_match(pos2.character, '[0-9\.]') is null
        left join
            islands pos3
            on islands.row_number = pos3.row_number
            and islands.index = pos3.index + 1
            and regexp_match(pos3.character, '[0-9\.]') is null
        left join
            islands pos4
            on islands.row_number = pos4.row_number
            and islands.index = pos4.index - 1
            and regexp_match(pos4.character, '[0-9\.]') is null
        left join
            islands pos5
            on islands.row_number = pos5.row_number - 1
            and islands.index = pos5.index + 1
            and regexp_match(pos5.character, '[0-9\.]') is null
        left join
            islands pos6
            on islands.row_number = pos6.row_number - 1
            and islands.index = pos6.index
            and regexp_match(pos6.character, '[0-9\.]') is null
        left join
            islands pos7
            on islands.row_number = pos7.row_number - 1
            and islands.index = pos7.index - 1
            and regexp_match(pos7.character, '[0-9\.]') is null
        where regexp_match(islands.character, '[0-9]') is not null
        group by islands.island
        having
            -- we aggregate all the joined positions
            -- if the string is empty, there are no adjecent symbols
            string_agg(
                coalesce(pos0.character, '')
                || coalesce(pos1.character, '')
                || coalesce(pos2.character, '')
                || coalesce(pos3.character, '')
                || coalesce(pos4.character, '')
                || coalesce(pos5.character, '')
                || coalesce(pos6.character, '')
                || coalesce(pos7.character, ''),
                ''
            )
            <> ''
        order by islands.island
    )
select sum(part_number)
from has_adjacent_symbol;
