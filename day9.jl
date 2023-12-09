using Test

function read_data(file)
    data = Vector{Vector{Int}}()
    for line in readlines(file)
        push!(data, parse.(Int, [m.match for m in eachmatch(r"-?\d+", line)]))
    end
    data
end

function extrapolate(row)
    last_entries = [row[end]]
    while true
        row = diff(row)
        @show row
        push!(last_entries, row[end])
        all(row .== 0) && break
    end
    sum(last_entries)
end

data = read_data("day9_test.txt")
@test sum([extrapolate(row) for row in data]) == 114

data = read_data("day9.txt")
@show sum([extrapolate(row) for row in data])

rev_data = reverse.(read_data("day9.txt"))
@show sum([extrapolate(row) for row in rev_data])
