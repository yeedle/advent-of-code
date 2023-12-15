create aggregate multiply(bigint) (sfunc = int8mul, stype=bigint);


with
    game_selections as (
        select
            substring(game_id from '[0-9]+')::int game_id,
            unnest(string_to_array(unnest(string_to_array(games, ';')), ',')) selection
        from day_2_input
    ),
    games as (
        select
            game_id,
            split_part(selection, ' ', 2)::int as number,
            split_part(selection, ' ', 3) color
        from game_selections
    ),
    min_num_of_cubes as (
        select game_id, color, max(number) number from games group by game_id, color
    ),
    game_powers as (
        select multiply(number) power from min_num_of_cubes group by game_id
    )
select sum(power)
from game_powers
