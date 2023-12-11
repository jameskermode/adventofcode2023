
read_matrix(lines) = permutedims(hcat(collect.(lines)...))

print_matrix(mat) = (println.([join(row) for row in eachrow(mat)]); nothing)

function print_galaxies(mat)
    galaxies = find_galaxies(mat)
    mat = copy(mat)
    for (idx, (i, j)) in enumerate(eachrow(galaxies))
        mat[i, j] = Char('0' + idx)
    end
    print_matrix(mat)
end

function expand(mat)
    new_mat = []
    for i in axes(mat, 1)
        row = mat[i, :]
        push!(new_mat, row)
        if all(row .== '.')
            push!(new_mat, row)
        end
    end
    mat = stack(new_mat, dims=1)

    new_mat = []
    for i in axes(mat, 2)
        col = mat[:, i]
        push!(new_mat, col)
        if all(col .== '.')
            push!(new_mat, col)
        end
    end
    mat = stack(new_mat, dims=2)
    return mat
end

manhattan_dist(a, b) = abs(a[1] - b[1]) + abs(a[2] - b[2])

function sum_pair_distances(galaxies::Matrix{Int})
    sum = 0
    for a in axes(galaxies, 1)
        for b in axes(galaxies, 1)
            b < a || continue
            sum += manhattan_dist(galaxies[a, :], galaxies[b, :])
        end
    end
    sum
end

function find_galaxies(mat)
    galaxies = sort(Tuple.(findall(==('#'), mat)))
    return stack(galaxies, dims=1)
end

function expand_galaxies(mat, galaxies, reps)
    new_galaxies = copy(galaxies)
    for i in axes(mat, 1)
        row = mat[i, :]
        if all(row .== '.')
            # println("blank row $i: shifting $(findall(galaxies[:, 1] .> i)) down by $(reps)")
            new_galaxies[galaxies[:, 1] .> i, 1] .+= reps - 1
        end
    end
    for i in axes(mat, 2)
        col = mat[:, i]
        if all(col .== '.')
            # println("blank col $i: shifting $(findall(galaxies[:, 2] .> i)) right by $(reps)")
            new_galaxies[galaxies[:, 2] .> i, 2] .+= reps - 1
        end
    end
    return new_galaxies
end

function sum_pair_distances(lines::Union{Vector{String}, Vector{SubString{String}}})
    mat = read_matrix(lines)
    mat = expand(mat)
    galaxies = find_galaxies(mat)
    return sum_pair_distances(galaxies)
end

lines = split("...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....", "\n")

@test sum_pair_distances(lines) == 374

mat = read_matrix(lines)
galaxies = find_galaxies(mat)
new_mat = expand(mat)
new_galaxies1 = find_galaxies(new_mat)
new_galaxies2 = expand_galaxies(mat, galaxies, 1)
@test new_galaxies1 == new_galaxies2

@show sum_pair_distances(readlines("day11.txt"))

sum_pair_distances(expand_galaxies(mat, galaxies, 10)) == 1030
sum_pair_distances(expand_galaxies(mat, galaxies, 100)) == 8410
sum_pair_distances(expand_galaxies(mat, galaxies, 10^6))

mat = read_matrix(readlines("day11.txt"))
galaxies = find_galaxies(mat)
galaxies = expand_galaxies(mat, galaxies, 10^6)
@show sum_pair_distances(galaxies)
