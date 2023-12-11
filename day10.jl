using Test
using CairoMakie
using Graphs
using GraphMakie

# all indices are (row, col) of the matrix with (1, 1) the top-left element
pipes = Dict('|' => ((-1, 0), (+1, 0)),
             '-' => ((0, -1), (0, +1)),
             'L' => ((-1, 0), (0, +1)),
             'J' => ((0, -1), (-1, 0)),
             '7' => ((0, -1), (+1, 0)),
             'F' => ((+1, 0), (0, +1)),
             '.' => (),
             'S' => ())

read_matrix(lines) = permutedims(hcat(collect.(lines)...))

print_matrix(mat) = (println.([join(row) for row in eachrow(mat)]); nothing)

function print_path(mat, path)
    mat = copy(mat)
    for p in path
        mat[p] = '*'
    end
    print_matrix(mat)
end

function build_graph(mat)
    linear = LinearIndices(mat)
    g = SimpleDiGraph(length(mat))
    for row in axes(mat, 1)
        for col in axes(mat, 2)
            for (drow, dcol) in pipes[mat[row, col]]
                try
                    linear[row+drow, col+dcol]
                catch e
                    if e isa BoundsError 
                        continue
                    else
                        rethrow()
                    end
                end
                add_edge!(g, linear[row, col], linear[row+drow, col+dcol])
            end
        end
    end

    start = linear[only(findall(mat .== 'S'))]
    neighs = all_neighbors(g, start)
    for n in neighs
        add_edge!(g, start, n)
    end

    return g, start
end

function solve_graph(g::SimpleDiGraph, start::Int)
    distances = gdistances(g, start)
    max_dist = maximum(distances[distances .!= typemax(Int)])
    return distances, max_dist
end

function solve_graph(lines::Union{Vector{String}, Vector{SubString{String}}})
    mat = read_matrix(lines)
    g, start = build_graph(mat)
    distances, max_dist = solve_graph(g, start)
    return mat, g, distances, max_dist, start
end

function plot_graph(g::SimpleDiGraph, mat, distances)
    cart = CartesianIndices(mat)
    labels = join.(reshape(mat, length(mat)))
    labels .*=  [" ($deg, $(dist == typemax(Int) ? "." : dist) )" for (deg, dist) in zip(degree(g), distances)]

    f, ax, p = graphplot(g, nlabels=labels)
    fixed_layout(_) = [reverse(Float32.(Tuple((cart[i])))) for i in 1:length(mat)]
    p.layout = fixed_layout

    offsets = Point2f(0.1, 0.3)
    p.nlabels_offset[] = offsets
    autolimits!(ax)
    ax.aspect = DataAspect()
    xlims!(ax, 0.5, size(mat, 2) + 1)
    ylims!(ax, size(mat, 1) + 0.5, 0.5) # flip vertically
    f
end

# @testset "Sample" begin
    lines = split("-L|F7
7S-7|
L|7||
-L-J|
L|-JF","\n")
    mat, g, distances, max_dist, start = solve_graph(lines)
    @test max_dist == 4

    lines = split(".....
.S-7.
.|.|.
.L-J.
.....", "\n")
    mat, g, distances, max_dist, start = solve_graph(lines)
    @test max_dist == 4

    lines = split("7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ", "\n")
    mat, g, distances, max_dist, start = solve_graph(lines)
    @test max_dist == 8
#end

lines = split("""..........
.S------7.
.|F----7|.
.||....||.
.||....||.
.|L-7F-J|.
.|..||..|.
.L--JL--J.
..........""", "\n")

lines = split(""".F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ...""", "\n")

lines = split("""FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L""", "\n")

function walk(g, start; dir=1)
    function step(pos)
        for outn in outneighbors(g, pos)
            outn ∉ path && return outn
        end
        for outn in outneighbors(g, pos)
            outn == start && return start
        end
    end

    pos = outneighbors(g, start)[dir]
    path = Int[start, pos]
    while (pos != start)
        pos = step(pos)
        push!(path, pos)
    end
    path
end

function cast_rays(mat)
    in_nodes = []
    linear = LinearIndices(mat)
    for i in axes(mat, 1)
        inside = false
        for j in axes(mat, 2)
            if mat[i, j] ∈ ['|', 'L', 'J'] 
                inside = !inside
                # println("crossing loop at $((i, j)), now $(inside ? "inside" : "outside")")
            end
            if inside && (mat[i, j] == '.')
                push!(in_nodes, linear[i, j])
            end
        end
        # println("row $i n_in = $(length(in_nodes))")
    end
    in_nodes
end

mat, g, distances, max_dist, start = solve_graph(lines)
path = walk(g, start)
mask = [i for i in LinearIndices(mat) if i ∉ path]

mat2 = copy(mat)
mat2[mask] .= '.'
print_matrix(mat2)

inside = cast_rays(mat2)
print_path(mat2, inside)
@test length(inside) == 10

mat = read_matrix(readlines("day10.txt"))
g, start = build_graph(mat)
distances, max_dist = solve_graph(g, start)
@show max_dist # part 1 solution

path = walk(g, start)
mask = [i for i in LinearIndices(mat) if i ∉ path]

mat2 = copy(mat)
mat2[mask] .= '.'
mat2[mat .== 'S'] .= '|'
print_matrix(mat2)

inside = cast_rays(mat2)
print_path(mat2, inside)
@show length(inside) # part 2 solution