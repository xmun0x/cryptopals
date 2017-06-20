#!/usr/bin/env ruby

# http://www.cryptopals.com/sets/1/challenges/2

def fixed_xor(a, b)
    result = (a.to_i(16) ^ b.to_i(16)).to_s(16)
    # ruby cuts off initial zeros for some reason, so result could end up shorter than input
    unless result.length.eql?(a.length)
        result = "0" * (a.length - result.length) + result
    end
    result
end

# test
if __FILE__ == $0
    input1 = "1c0111001f010100061a024b53535009181c"
    input2 = "686974207468652062756c6c277320657965"
    output = "746865206b696420646f6e277420706c6179"
    fail unless fixed_xor(input1, input2).eql?(output)
    puts "Challenge #2 test passed"
end
