using Test

function extract_calibration(input; words=false)
    patterns = zip(["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"],
                   ["o1e", "t2o", "t3e",   "f4r",  "f5e",  "s6x", "s7n",   "e8t",   "n9e"])
    if words
        for (src, dest) in patterns
            input = replace(input, src=>dest)
        end
    end
    mask = isdigit.(collect(input))
    digits = input[findfirst(mask)] * input[findlast(mask)]
    return parse(Int, digits)
end

@testset "Test 1" begin

    sample_inputs = ["1abc2",
    "pqr3stu8vwx",
    "a1b2c3d4e5f",
    "treb7uchet"]

    sample_outputs = [12, 38, 15, 77]

    outputs = [ extract_calibration(input) for input in sample_inputs ]
    @show outputs
    @show outputs .== sample_outputs
    @show sum(outputs)
    @test sum(outputs) == sum(sample_outputs)
end

@testset "Test 2" begin

    sample_inputs = ["two1nine",
                    "eightwothree",
                    "abcone2threexyz",
                    "xtwone3four",
                    "4nineeightseven2",
                    "zoneight234",
                    "7pqrstsixteen",
                    "sevenine"] # tricky edge case with overlapping words

    sample_outputs = [29, 83, 13, 24, 42, 14, 76, 79]

    outputs = [ extract_calibration(input; words=true) for input in sample_inputs ]
    @show outputs
    @show outputs .== sample_outputs
    @show sum(outputs)
    @test sum(outputs) == sum(sample_outputs)
end

println("My results:")
mylines = open("input1.txt") do f
    readlines(f)
end

@testset "Problems" begin
    prob1 = sum([extract_calibration(line) for line in mylines])
    @show prob1
    @test prob1 == 53194

    prob2 = sum([extract_calibration(line; words=true) for line in mylines])
    @show prob2
    @test prob2 == 54249
end
