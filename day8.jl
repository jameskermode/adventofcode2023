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

function walk_nodes(instructions, nodes)
    location = :AAA
    nsteps = 0
    for step in instructions
        # @show (nsteps, location, step)
        location = nodes[location][LR_map[step]]
        nsteps += 1
        location == :ZZZ && break
    end
    nsteps
end

function walk_ghosts(instructions, nodes)
    _keys = collect(keys(nodes))
    locations = _keys[findall(endswith.([String(key) for key in _keys], "A"))]
    exits = Set(_keys[findall(endswith.([String(key) for key in _keys], "Z"))])
    @show locations, exits
    nsteps = 0
    for step in instructions
        for i in eachindex(locations)
            locations[i] = nodes[locations[i]][LR_map[step]]
        end
        nsteps += 1
        nexit = sum([endswith.(String(loc), "Z") for loc in locations])
        @show nsteps, nexit 
        Set(locations) == exits && break
    end
    nsteps
end

instructions, nodes = read_nodes("day8_test.txt")
@test walk_nodes(instructions, nodes) == 2

instructions, nodes = read_nodes("day8_test2.txt")
@test walk_nodes(instructions, nodes) == 6

instructions, nodes = read_nodes("day8.txt")
@test walk_nodes(instructions, nodes) == 23147

instructions, nodes = read_nodes("day8_test3.txt")
walk_ghosts(instructions, nodes)

instructions, nodes = read_nodes("day8.txt")
walk_ghosts(instructions, nodes)
