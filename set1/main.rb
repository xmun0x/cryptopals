#!/usr/bin/env ruby

# exercises
#
def hex2base64(a)
    [[a].pack("H*")].pack("m0") 
end

def fixedXOR(a, b)
    (a.to_i(16) ^ b.to_i(16)).to_s(16)
end

def singlebyteXOR(a)
    # taken from http://www.math.cornell.edu/~mec/2003-2004/cryptography/subs/frequencies.html
    most_common_letters = ["E", "T", "A", "O", "I", "N", "S", "H", "R", "D", "L", "U", " "]
    valid_char_vals =*(32..126)
    valid_char_vals.push(10)
    highest_score = 0
    xor_char = 0
    secret_phrase = ""
    for i in 1..255 do
        fullstring = ""
        j = 0
        # XOR each byte with i
        moveon = true
        while j < a.length
            # eliminate phrases with non-printable characters
            value = (a.slice(j, 2).to_i(16) ^ i)
            if !valid_char_vals.include? value
                moveon = false
                break 
            end
            fullstring += value.to_s(16)
            j += 2
        end
        if !moveon
            next
        end

        # full decoded string
        decoded = [fullstring].pack("H*")
        # remove all special characters, then do shitty frequency analysis
        all_alpha = decoded.upcase.gsub(/[^A-Z\s]/i, '')
        if !all_alpha.empty?
            score = 0
            all_alpha.each_char do |c| 
                if most_common_letters.include? c
                    score += 1
                end
            end
            if score > highest_score
                highest_score = score
                xor_char = i
                secret_phrase = decoded
            end
        end
    end
    result = {
        "secret_phrase" => secret_phrase,
        "score" => highest_score,
        "xor_char" => [xor_char.to_s(16)].pack('H*')
    }
    return result
end


def findSecret(filename)
    file = File.new(filename, "r")
    highest_score = 0
    best_result = {}
    while (line = file.gets)
        result = singlebyteXOR(line) 
        if !result['secret_phrase'].empty? && result['score'] > highest_score
            highest_score = result['score']
            best_result = result
        end
    end
    puts "Secret phrase: #{best_result['secret_phrase']}"
    puts "XOR char: #{best_result['xor_char']}"
    puts "Score: #{best_result['score']}"
end

# tests

# lol plaintext: "I'm killing your brain like a poisonous mushroom"
one_hexstr = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d"
one_base64str = "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t"
fail if !hex2base64(one_hexstr).eql?(one_base64str)
puts "Test 1 passed"

two_input1 = "1c0111001f010100061a024b53535009181c"
two_input2 = "686974207468652062756c6c277320657965"
two_output = "746865206b696420646f6e277420706c6179"
fail if !fixedXOR(two_input1, two_input2).eql?(two_output)
puts "Test 2 passed"

# Secret phrase: Cooking MC's like a pound of bacon
three_input = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"
result = singlebyteXOR(three_input)
puts "Exercise 3"
puts "Secret phrase: #{result['secret_phrase']}"
puts "XOR char: #{result['xor_char']}"

puts "Exercise 4"
findSecret("4.txt")
