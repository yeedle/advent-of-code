create table day_2_input(
    game_id text,
    games text
)
COPY day_2_input FROM '/users/yeedle/Downloads/input.txt' WITH (FORMAT text, DELIMITER ':');

with
    possible_configurations as (
        select *
        from (values (12, 'red'), (13, 'green'), (14, 'blue')) as c(number, color)
    ),
    game_selections as (
        select
            substring(game_id from '[0-9]+')::int game_id, -- extract the game_id using regex
            unnest(string_to_array(unnest(string_to_array(games, ';')), ',')) selection -- get each selection into its own row
        from day_2_input
    ),
    games as (
        select
            game_id,
            split_part(selection, ' ', 2)::int as number, -- extract the number
            split_part(selection, ' ', 3) color -- extract the color
        from game_selections
    ),
    invalid_games as (
        select *
        from games
        inner join
            possible_configurations
            on games.number > possible_configurations.number
            and games.color = possible_configurations.color
    )
select sum(distinct game_id)
from games
where game_id not in (select game_id from invalid_games)
