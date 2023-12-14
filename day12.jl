using Test

function parse_lines(lines)
    results = []
    for line in lines
        pattern, counts = split(line)
        pattern = collect(pattern)
        counts = parse.(Int, split(counts, ","))
        push!(results, (pattern, counts))
    end
    return results
end

function get_counts(pattern)
    damaged = false
    n = 0
    counts = Int[]
    for i in eachindex(pattern)
        if pattern[i] == '.' 
            if damaged
                damaged = false
                push!(counts, n)
                n = 0
            end
        elseif pattern[i] == '#'
            if damaged
                n += 1
            else
                damaged = true
                n = 1
            end
        else
            error("unexpected character $(pattern[i])")
        end
    end
    damaged && push!(counts, n)
    counts
end

function generate_subs(pattern)
    wildcards = findall(==('?'), pattern)
    N = length(wildcards)
    substitutions = [ join([ x == 0 ? '.' : '#' for  x in digits(i, base=2, pad=N) ]) for i=0:(2^N-1)]
    cands = []
    for subs in substitutions
        cand = copy(pattern)
        for (i, s) in zip(wildcards, subs)
            cand[i] = s
        end
        push!(cands, cand)
    end
    cands
end

function generate_subs2(pattern)
    wildcards = findall(==('?'), pattern)
    cands = []
end

lines = split("#.#.### 1,1,3
.#...#....###. 1,1,3
.#.###.#.###### 1,3,1,6
####.#...#... 4,1,1
#....######..#####. 1,6,5
.###.##....# 3,2,1", "\n")

for (pattern, counts) in parse_lines(lines)
    @test all(get_counts(pattern) .== counts)
end

lines = split("""???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1""", "\n")

function count_matches(lines)
    sum_matches = 0
    for (pattern, counts) in parse_lines(lines)
        matches = 0
        subs = generate_subs(pattern)
        for sub in subs
            (get_counts(sub) == counts) && (matches += 1)
        end
        @show join(pattern), counts, matches
        sum_matches += matches
    end
    @show sum_matches
end

@test count_matches(lines) == 21

count_matches(readlines("day12.txt"))

