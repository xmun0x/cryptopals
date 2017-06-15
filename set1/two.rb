#!/usr/bin/env ruby

# http://www.cryptopals.com/sets/1/challenges/2

def fixedXOR(a, b)
    result = (a.to_i(16) ^ b.to_i(16)).to_s(16)
    if (result.length % 2).odd?
        result = "0" + result
    end
    result
end

# test
if __FILE__ == $0
    input1 = "1c0111001f010100061a024b53535009181c"
    input2 = "686974207468652062756c6c277320657965"
    output = "746865206b696420646f6e277420706c6179"
    fail if !fixedXOR(input1, input2).eql?(output)
    puts "Challenge #2 test passed"
end
