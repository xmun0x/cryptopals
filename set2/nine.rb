#!/usr/bin/env ruby

# http://www.cryptopals.com/sets/2/challenges/9

def addPadding(string, blocksize)
    padding = blocksize - (string.length % blocksize)
    padding = ["%02x" % padding].pack("H*") * padding
    string + padding
end

# test
if __FILE__ == $0
    input = "YELLOW_SUBMARINE"
    fail if !addPadding(input, 20).eql?("YELLOW_SUBMARINE\x04\x04\x04\x04")
    puts "Challenge #9 test passed"
end
