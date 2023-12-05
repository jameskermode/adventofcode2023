using Test

map_names = ["seed-to-soil",
             "soil-to-fertilizer",
             "fertilizer-to-water",
             "water-to-light",
             "light-to-temperature",
             "temperature-to-humidity",
             "humidity-to-location"]

function read_input(filename)
    seeds = nothing
    maps = Dict{String}{Any}()
    lines = readlines(filename)
    while(length(lines) > 0)
        line = popfirst!(lines)
        @show line
        seed_re = match(r"^seeds: ", line)
        if seed_re !== nothing
            seeds = parse.(Int, split(replace(line, r"seeds: " => s"")))
            while((line = popfirst!(lines)) != "")
                @show line
            end
        else
            block = match(r"^([a-z-]+) map:", line)[1]
            @assert block in map_names
            maps[block] = []
            while(length(lines) > 0 && (line = popfirst!(lines)) != "")
                @show line
                dest_start, source_start, len = parse.(Int, split(line))
                push!(maps[block], ((source_start, source_start+len-1), (dest_start, dest_start+len-1)))
            end
        end
    end
    for (key, value) in maps
        maps[key] = sort(value)
    end
    return (seeds, maps)
end

function lookup(table, index)
    for ((source_start, source_end), (dest_start, dest_end)) in table
        if (index >= source_start && index <= source_end)
            return dest_start + index-source_start
        end
    end
    return index
end

function resolve(seeds, maps; verbose=true)
    output = zeros(Int, length(seeds))
    for (idx, item) in enumerate(seeds)
        verbose && print("Seed $item")
        for map in map_names
            item = lookup(maps[map], item)
            verbose && print(", $(split(map,"-")[end]) $item")
        end
        output[idx] = item
        verbose && print("\n")
    end
    return minimum(output)
end

function expand_seeds(seeds)
    new_seeds = Int[]
    for (start_value, len) in zip(seeds[1:2:end], seeds[2:2:end])
        append!(new_seeds, (start_value, start_value+len-1, start_value, start_value+len-1)
    end
    new_seeds
end

@testset "Sample" begin
    seeds, maps = read_input("day5_test.txt")
    resolve(seeds, maps) == 35

    new_seeds = expand_seeds(seeds)
    resolve(new_seeds, maps) == 46
end

seeds, maps = read_input("day5.txt")
@show resolve(seeds, maps)

new_seeds = expand_seeds(seeds)
@show resolve(new_seeds, maps)