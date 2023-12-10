using Test
import Base.:<
import Base.parse
import Base.repr

@enum Card Ace=14 King=13 Queen=12 Jack=11 Ten=10 _9=9 _8=8 _7=7 _6=6 _5=5 _4=4 _3=3 _2=2 Joker=0

struct Hand
    cards::NTuple{5, Card}
end

function read_hand(string::AbstractString; jokers=false)::Hand
    _char_map = Dict('A' => Ace,  'K' => King,  'Q' => Queen,  'T' => Ten, 
                     '9' => _9, '8' => _8, '7' => _7, '6' => _6,
                     '5' => _5, '4' => _4, '3' => _3, '2' => _2)

    char_map = Dict(false => copy(_char_map),
                    true =>  copy(_char_map))
    char_map[false]['J'] = Jack
    char_map[true]['J'] = Joker

    @assert length(string) == 5
    cards = Tuple([char_map[jokers][char] for char in string])
    return Hand(cards)
end

Base.show(io::IO, hand::Hand) = print(io, join([replace(String(Symbol(c)),"_"=>"")[1] for c in hand.cards]))

function _score(hand::Hand)
    counts = sort([count(==(value), hand.cards) for value in unique(hand.cards)], rev=true)
    counts[1] == 5 && return 7
    counts[1] == 4 && return 6
    (counts[1] == 3 && counts[2] == 2) && return 5
    (counts[1] == 3 && counts[2] == 1) && return 4
    (counts[1] == 2 && counts[2] == 2) && return 3
    counts[1] == 2 && return 2
    counts[1] == 1 && return 1
    error("missed all conditions with counts $(counts)")
end

function score(hand::Hand)
    if any(hand.cards .== Joker)
        scores = Int[]
        for value in instances(Card)
            repl = collect(hand.cards)
            repl[repl .== Joker] .= value
            push!(scores, _score(Hand(Tuple(repl))))
        end
        return maximum(scores)
    else
        return _score(hand)
    end
end

Base.:<(a::Card, b::Card) = Integer(a) < Integer(b)

function Base.:<(a::Hand, b::Hand)
    # @show a, b
    sa, sb = score(a), score(b)
    if sa == sb
        i = 1
        while (a.cards[i] == b.cards[i])
            i += 1
        end
        return a.cards[i] < b.cards[i]
    else
        return sa < sb
    end
end

function winnings(lines; verbose=false, jokers=false)
    hands = []
    bets = []
    for line in lines
        hand, bet = split(line)
        push!(hands,  read_hand(hand; jokers=jokers))
        push!(bets, parse(Int, bet))
    end
    order = sortperm(hands, lt=Base.:<) # FIXME why is custom lt necessary?
    verbose && begin
        total = 0
        for (rank, index) in enumerate(order)
            println("[$rank] $(hands[index]) $(bets[index])")
            total += rank * bets[index]
        end
        println("total = $total")
    end
    return sum((1:length(order)) .* bets[order])
end

@testset "Sample 1" begin
    test_lines = split("""32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483""", "\n")
    @test winnings(test_lines) == 6440
    @test winnings(test_lines; jokers=true) == 5905
end

@testset "Sample 2" begin
    test_lines =split("""2345A 1
Q2KJJ 13
Q2Q2Q 19
T3T3J 17
T3Q33 11
2345J 3
J345A 2
32T3K 5
T55J5 29
KK677 7
KTJJT 34
QQQJA 31
JJJJJ 37
JAAAA 43
AAAAJ 59
AAAAA 61
2AAAA 23
2JJJJ 53
JJJJ2 41""", "\n")
    @test winnings(test_lines, verbose=true) == 6592
    @show winnings(test_lines, verbose=true, jokers=true) == 6839
end

lines = readlines("day7.txt")
@show winnings(lines)
@show winnings(lines; jokers=true)
