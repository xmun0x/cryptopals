#!/usr/bin/env ruby

# http://www.cryptopals.com/sets/1/challenges/5

require_relative "./two"

def repeating_key_xor(message, key)
    full_key = ""
    (0..message.length - 1).each do |i|
        full_key += key[i % key.length]
    end
    hex_message = message.unpack("H*")[0]
    hex_key = full_key.unpack("H*")[0]
    fixed_xor(hex_message, hex_key)
end

# test
if __FILE__ == $0
    phrase = "Burning 'em, if you ain't quick and nimble\n"\
             "I go crazy when I hear a cymbal"
    solution = "0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b"\
               "2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f"
    fail unless repeating_key_xor(phrase, "ICE").eql?(solution)
    puts "Challenge #5 test passed"
end
