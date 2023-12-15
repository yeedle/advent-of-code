with
    words_for_numbers as (
        select *
        from
            (
                values
                    ('one', '1'),
                    ('two', '2'),
                    ('three', '3'),
                    ('four', '4'),
                    ('five', '5'),
                    ('six', '6'),
                    ('seven', '7'),
                    ('eight', '8'),
                    ('nine', '9')
            ) as digit_words(word, numeral)
    ),
    first_and_last_digits as (
        select
            line,
            substring(
                line from '([0-9]|one|two|three|four|five|six|seven|eight|nine)'
            ) first_digit_or_word,
            -- could use negative lookahead probably, but this is simpler
            reverse(
                substring(
                    reverse(line)
                    from '([0-9]|eno|owt|eerht|ruof|evif|xis|neves|thgie|enin)'
                )
            ) last_digit_or_word
        from day_1_input
    )
select sum((first_digit.numeral || last_digit.numeral)::int)
from first_and_last_digits
left join
    words_for_numbers first_digit
    on first_digit.word = first_digit_or_word
    or first_digit.numeral = first_digit_or_word
left join
    words_for_numbers last_digit
    on last_digit.word = last_digit_or_word
    or last_digit.numeral = last_digit_or_word
