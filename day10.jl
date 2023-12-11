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
    @show neighs
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

function solve_graph(lines::Vector{String})
    mat = read_matrix(lines)
    g, start = build_graph(mat)
    distances, max_dist = solve_graph(g, start)
    return mat, g, distances, max_dist
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


@testset "Sample"
    lines = split("-L|F7
    7S-7|
    L|7||
    -L-J|
    L|-JF","\n")
    mat, g, distances, max_dist = solve_graph(lines)
    @test max_dist == 4

    lines = split(".....
    .S-7.
    .|.|.
    .L-J.
    .....", "\n")
    mat, g, distances, max_dist = solve_graph(lines)
    @test max_dist == 4

    lines = split("7-F7-
    .FJ|7
    SJLL7
    |F--J
    LJ.LJ", "\n")
    mat, g, distances, max_dist = solve_graph(lines)
    @test max_dist == 8
end

mat, g, distances, max_dist = solve_graph(readlines("day10.txt"))
plot_graph(g, mat, distances)