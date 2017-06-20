#!/usr/bin/env ruby

# http://www.cryptopals.com/sets/2/challenges/9

def add_padding(string, blocksize)
    padding = blocksize - (string.length % blocksize)
    padding = ["%02x" % padding].pack("H*") * padding
    string + padding
end

# test
if __FILE__ == $0
    input = "YELLOW SUBMARINE"
    fail unless add_padding(input, 20).eql?("YELLOW SUBMARINE\x04\x04\x04\x04")
    puts "Challenge #9 test passed"
end
