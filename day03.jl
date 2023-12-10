using Test

is_symbol(char) = !isdigit(char) && char != '.'
has_symbol(str) = any(is_symbol.(collect(str)))
read_matrix(lines) = permutedims(hcat(collect.(lines)...))

function extract_number(mat, index)
    i, j = index.I
    left = right = j
    while(left > 1) 
        if isdigit(mat[i, left-1])
            left -= 1
        else
            break
        end
    end
    while(right < size(mat, 2))
        if isdigit(mat[i, right+1])
            right += 1
        else
            break
        end
    end
    return parse(Int, join(mat[i, left:right])), i, left, right
end

function find_part_numbers(mat)
    indices = findall(is_symbol, mat)
    neighbors = CartesianIndex(-1, -1):CartesianIndex(1, 1)
    found = zeros(Bool, size(mat))
    sum_part_numbers = 0
    for I in indices
        part_numbers = Int[]
        for N in neighbors
            N == CartesianIndex(0, 0) && continue # no self interaction
            checkbounds(Bool, mat, I+N) || continue
            if isdigit(mat[I+N])
                num, i, left, right = extract_number(mat, I+N)
                found[i, left:right] .= true

                # check for local (but not global) duplicates
                num ∉ part_numbers && push!(part_numbers, num)
            end
        end
        sum_part_numbers += sum(part_numbers)
    end
    return sum_part_numbers
end

function print_matrix(mat, found)
    for i=1:size(mat, 1)
        for j=1:size(mat, 2)
            if !isdigit(mat[i, j]) && mat[i, j] != '.'
                printstyled(join(mat[i, j]), color=:blue, bold=true)
            elseif found[i, j]
                printstyled(join(mat[i, j]), color=:red)
            else
                printstyled(join(mat[i, j]), color=:black)
            end
        end
        print("\n")
    end
end

function find_part_numbers_regex(lines)
    N, M = length(lines), length(first(lines))
    part_numbers = []
    prev_line = repeat(".", M)
    for (i, line) in enumerate(lines)
        next_line = i+1 > N ? repeat(".", M) : lines[i+1]
        for match in findall(r"\d+", line)
            left, right = first(match), last(match)

            # expand window if not on boundary
            left  > 1 && (left -= 1)
            right < M && (right += 1)

            valid = has_symbol(line[left:right]) ||
                    has_symbol(prev_line[left:right]) ||
                    has_symbol(next_line[left:right])

            if valid
                num = parse(Int, line[match])
                push!(part_numbers, num)
            end
        end
        prev_line = line
    end
    return part_numbers
end

function find_gears(mat)
    indices = findall(char -> char == '*', mat)
    neighbors = CartesianIndex(-1, -1):CartesianIndex(1, 1)

    gear_ratios = []
    for I in indices
        part_numbers = []
        for N in neighbors
            N == CartesianIndex(0, 0) && continue # no self interaction
            checkbounds(Bool, mat, I+N) || continue
            if isdigit(mat[I+N])
                num, _, _, _ = extract_number(mat, I+N)
                num ∉ part_numbers && push!(part_numbers, num)
            end
        end
        if length(part_numbers) == 2
            push!(gear_ratios, prod(part_numbers))
        end
    end
    return gear_ratios
end

@testset "Sample" begin
    lines = split(raw"""467..114..
    ...*......
    ..35..633.
    ......#...
    617*......
    .....+.58.
    ..592.....
    ......755.
    ...$.*....
    .664.598..""", "\n")

    part_numbers = find_part_numbers_regex(lines)
    @test sum(part_numbers) == 4361

    mat = read_matrix(lines)
    @test find_part_numbers(mat) == 4361

    gear_ratios = find_gears(read_matrix(lines))
    @test sum(gear_ratios) == 467835
end

lines = open("day3.txt") do f
    readlines(f)
end
part_numbers = find_part_numbers_regex(lines)
@show sum(part_numbers)

mat = read_matrix(lines)
@show find_part_numbers(mat)

gear_ratios = find_gears(mat)
@show sum(gear_ratios)