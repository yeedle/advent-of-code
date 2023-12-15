create aggregate multiply(bigint) (sfunc = int8mul, stype=bigint);

-- using the same approach as part 1, but now we give IDs to the gears so we can see if any
-- parts share the same gear

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
                    is null
                    and regexp_match(character, '[0-9]') is not null
                then 1
                else 0
            end as gap,
            case when character = '*' then 1 else 0 end gear_gap
        from day_3_input, unnest(regexp_split_to_array(row, ''))
        with ordinality a(character, index)
    ),
    islands as (
        select
            *,
            sum(gap) over (order by row_number, index) island,
            sum(gear_gap) over (order by row_number, index) gear_id
        from characters
    ),
    has_adjacent_symbol as (
        select
            islands.island part_id, 
            (string_agg(islands.character, ''))::int part_number,
            unnest(
                array_agg(
                    array[
                        pos0.gear_id,
                        pos1.gear_id,
                        pos2.gear_id,
                        pos3.gear_id,
                        pos4.gear_id,
                        pos5.gear_id,
                        pos6.gear_id,
                        pos7.gear_id
                    ]
                )
            ) adjacent_gear_id -- we get every gear that is next to a number in its own row
        from islands
        left join
            islands pos0
            on islands.row_number = pos0.row_number + 1
            and islands.index = pos0.index + 1
            and pos0.character = '*'
        left join
            islands pos1
            on islands.row_number = pos1.row_number + 1
            and islands.index = pos1.index
            and pos1.character = '*'
        left join
            islands pos2
            on islands.row_number = pos2.row_number + 1
            and islands.index = pos2.index - 1
            and pos2.character = '*'
        left join
            islands pos3
            on islands.row_number = pos3.row_number
            and islands.index = pos3.index + 1
            and pos3.character = '*'
        left join
            islands pos4
            on islands.row_number = pos4.row_number
            and islands.index = pos4.index - 1
            and pos4.character = '*'
        left join
            islands pos5
            on islands.row_number = pos5.row_number - 1
            and islands.index = pos5.index + 1
            and pos5.character = '*'
        left join
            islands pos6
            on islands.row_number = pos6.row_number - 1
            and islands.index = pos6.index
            and pos6.character = '*'
        left join
            islands pos7
            on islands.row_number = pos7.row_number - 1
            and islands.index = pos7.index - 1
            and pos7.character = '*'
        where regexp_match(islands.character, '[0-9]') is not null
        group by islands.island
        order by islands.island
    ),
    parts_with_adjacent_gears as (
        select distinct on (part_id) *
        from has_adjacent_symbol
        where adjacent_gear_id is not null
    ),
    gear_ratios as (
        select multiply(part_number) ratio, adjacent_gear_id
        from parts_with_adjacent_gears
        group by adjacent_gear_id
        having count(*) = 2 -- only count if exactly 2 parts are adjacent to the same gear 
    )
select sum(ratio)
from gear_ratios;
