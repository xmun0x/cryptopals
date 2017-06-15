#!/usr/bin/env ruby

# http://www.cryptopals.com/sets/1/challenges/6

require_relative "./two"
require_relative "./three"

def base642hex(a)
    a.unpack("m0")[0].unpack("H*")[0]
end

def ascii2bin(a)
    result = ""
    a.each_char{|c| result += "%08b" % c.ord }
    result
end

def hammingDistance(a, b)
    a = ascii2bin(a)
    b = ascii2bin(b)
    fail "hammingDistance: unequal input lengths" if a.length != b.length
    (a.chars.zip(b.chars)).count {|l, r| l != r}
end

def breakRepeatingKeyXOR(filename)
    lines = ""
    file = File.new(filename, "r")
    while (line = file.gets)
        lines += line.chomp
    end
    lines = base642hex(lines)
    smallest_keysize = 2
    largest_keysize = 40
    distances = []
    n = 8 # re-run a few times while changing this number to be sure of top result

    for i in (smallest_keysize*2..largest_keysize*2).step(2)
        a = lines.slice(0, i*n)
        b = lines.slice(i*n, i*n)
        c = lines.slice(2*i*n, i*n)
        normdist1 = hammingDistance(a, b)/(Float(i) * 8)
        normdist2 = hammingDistance(b, c)/(Float(i) * 8)
        normdist3 = hammingDistance(a, c)/(Float(i) * 8)
        average = (normdist1 + normdist2 + normdist3)/3
        distances.push({"keysize" => i/2, "distance" => average})
    end

    sorted = distances.sort_by { |k| k["distance"] }
    keysize = sorted[0]['keysize']

    blocks = {}
    for i in 0..keysize - 1
        blocks[i] = ""
    end

    for i in 0..(lines.length/2) - 1
        blocks[i%keysize] += lines.slice(i*2, 2)
    end

    key = ""
    blocks.each do |position, string|
        result = singlebyteXOR(string)
        key += result["xor_char"]
    end

    puts "The key is '#{key}'"

    full_key = ""
    for i in 0..(lines.length/2) - 1
        full_key += key[i % key.length]
    end

    hex_key = full_key.unpack("H*")[0]
    puts "Here is the decrypted text:"
    puts [fixedXOR(lines, hex_key)].pack("H*")

    key
end

# tests
if __FILE__ == $0
    s1 = "this is a test"
    s2 = "wokka wokka!!!"
    fail if !hammingDistance(s1, s2).eql?(37)
    key = breakRepeatingKeyXOR("6.txt")
    fail if !key.eql?("Terminator X: Bring the noise")
    puts "Challenge #6 tests passed"
end
