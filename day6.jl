function count_ways(time, record_distance)
    ways = 0
    for speed in 0:time
        distance = speed*(time - speed)
        distance > record_distance && (ways += 1)
    end
    return ways
end

function solve(lines)
    times     =  parse.(Int, split(replace(lines[1], "Time:" => "")))
    distances =  parse.(Int, split(replace(lines[2], "Distance:" => "")))
    prod([count_ways(t, d) for (t, d) in zip(times, distances)])
end

@testset "Sample" begin
    test_lines = split("""Time:      7  15   30
    Distance:  9  40  200""", "\n")
    @test solve(test_lines) == 288

    test_lines2 = split("""Time:      71530
Distance:  940200""", "\n")
    @test solve(test_lines2) == 71503
end

lines = split("""Time:        44     70     70     80
Distance:   283   1134   1134   1491""", "\n")
solve(lines)

lines2 = replace.(lines, " "=>"")
solve(lines2)