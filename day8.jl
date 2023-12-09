using Test

function read_nodes(file)
    lines = readlines(file)
    instructions = Iterators.cycle(collect(lines[1]))
    nodes = Dict{Symbol, NTuple{2,Symbol}}()
    for i=firstindex(lines)+2:lastindex(lines)
        m = match(r"(\w+) = \((\w+), (\w+)\)", lines[i])
        node, left, right = Symbol.(m.captures)
        nodes[node] = (left, right)
    end
    return (instructions, nodes)
end

LR_map = Dict('L' => 1, 'R' => 2)

function walk_nodes(instructions, nodes; start=:AAA)
    location = start
    nsteps = 0
    for step in instructions
        # @show (nsteps, location, step)
        location = nodes[location][LR_map[step]]
        nsteps += 1
        endswith(String(location), "Z") && break
    end
    nsteps
end

function walk_multiple(instructions, nodes)
    starts   = [key for key in keys(nodes) if endswith(String(key), "A")]
    cycles = Int[]
    for start in starts
        push!(cycles, walk_nodes(instructions, nodes; start=start))
        println("$start done")
    end
    @show cycles
    return lcm(cycles)
end

instructions, nodes = read_nodes("day8_test.txt")
@test walk_nodes(instructions, nodes) == 2

instructions, nodes = read_nodes("day8_test2.txt")
@test walk_nodes(instructions, nodes) == 6

instructions, nodes = read_nodes("day8.txt")
@test walk_nodes(instructions, nodes) == 23147

instructions, nodes = read_nodes("day8_test3.txt")
cycles = walk_multiple(instructions, nodes)

instructions, nodes = read_nodes("day8.txt")
@show walk_multiple(instructions, nodes)
