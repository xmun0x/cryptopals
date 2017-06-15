#!/usr/bin/env ruby

# http://www.cryptopals.com/sets/1/challenges/1

def hex2base64(a)
    [[a].pack("H*")].pack("m0") 
end

# test
if __FILE__ == $0
    # plaintext: "I'm killing your brain like a poisonous mushroom"
    one_hexstr = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f75732"\
                 "06d757368726f6f6d"
    one_base64str = "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t"
    fail unless hex2base64(one_hexstr).eql?(one_base64str)
    puts "Challenge #1 test passed"
end
