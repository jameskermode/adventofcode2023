using Test

max_rgb = [12, 13, 14]

function parse_game(line)
    id, rest = split(line, ":")
    id = parse(Int, replace(id, "Game "=>""))
    draws = split.(split(rest, ";"), ",")
    results = []
    for draw in draws
        rgb = [endswith.(draw, colour) for colour in ("red", "green", "blue")]
        N_rgb = zeros(Int, 3)
        for i_colour = 1:3
            !any(rgb[i_colour]) && continue
            N_rgb[i_colour] = parse(Int, split(draw[findfirst(rgb[i_colour])])[1] )
        end
        push!(results, N_rgb)
    end
    return id, hcat(results...)
end

is_valid(results) = all([all(col .<= max_rgb) for col in eachcol(results)])

power(results) = prod(maximum(results, dims=2))

function count_valid_games(lines)
    sum_id = 0
    for line in lines
        id, results = parse_game(line)
        if is_valid(results)
            sum_id += id
        end
    end
    return sum_id
end

function sum_powers(lines)
    sum_power = 0
    for line in lines
        id, results = parse_game(line)
        sum_power += power(results)
    end
    return sum_power
end

@testset "Sample" begin

    lines = split("""Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
    Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
    Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
    Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
    Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green""", "\n")

    @test count_valid_games(lines) == 8
    @test sum_powers(lines) == 2286
end


lines = open("day2.txt") do f
    readlines(f)
end

@show count_valid_games(lines)
@show sum_powers(lines)