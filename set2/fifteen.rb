#!/usr/bin/env ruby

# http://www.cryptopals.com/sets/2/challenges/15

require_relative "./nine"

def remove_padding(string)
    padding = string[-1].unpack("H*")[0].to_i(16)
    if padding > 16 or padding < 1
        fail
    end

    valid_padding = string[0..-padding-1] + ["%02x" % padding].pack("H*") * padding

    if string.eql?(valid_padding)
        return string.slice(0, string.length - padding)
    else
        fail
    end
end

# test
if __FILE__ == $0
    fail unless remove_padding("ICE ICE BABY\x04\x04\x04\x04").eql?("ICE ICE BABY")
    "Challenge #15 test passed"
end
