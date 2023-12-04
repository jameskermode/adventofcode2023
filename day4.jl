using Test

function parse_line(line)
    id, rest = split(line, ":")
    id = parse(Int, replace(id, "Card "=>""))
    winners, numbers = split(rest, "|") 
    winners = parse.(Int, split(winners))
    numbers = parse.(Int, split(numbers))
    return (id, winners, numbers)
end

find_winners(winners, numbers) = [number for number in numbers if number in winners]

function points(wins)
    length(wins) == 0 && return 0
    return 2^(length(wins)-1)
end

function get_scores(lines)
    scores = []
    for line in lines 
        id, winners, numbers = parse_line(line)
        wins = find_winners(winners, numbers)
        push!(scores, (id, length(wins), points(wins)))
    end
    scores
end

function count_copies(scores)
    copies = ones(Int, length(scores))
    for (id, wins, points) in scores
        for win in 1:wins
            copies[id+win] += copies[id]
        end
    end
    copies
end

@testset "Sample" begin
    test_lines = split("""Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11""", "\n")
    scores = get_scores(test_lines)
    @test sum(getindex.(scores, 3)) == 13
    @test sum(count_copies(scores)) == 30
end

lines = open("day4.txt") do f
    readlines(f)
end
scores = get_scores(lines)
@show sum(getindex.(scores, 3))
@show sum(count_copies(scores))




