create table day_4_input(
    card_id text,
    numbers text
);
copy day_4_input FROM '/users/yeedle/Downloads/input.txt' with (format text, delimiter ':');


select
    sum(
        round(
            pow(
                2,
                cardinality(
                    array(
                        select
                            unnest(
                                regexp_split_to_array(
                                    trim(split_part(numbers, '|', 1)), '\s+'
                                )
                            )
                        intersect
                        select
                            unnest(
                                regexp_split_to_array(
                                    trim(split_part(numbers, '|', 2)), '\s+'
                                )
                            )
                    )
                )
                - 1
            )
        )
    )
from day_4_input
;
