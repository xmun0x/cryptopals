#!/usr/bin/env ruby

# exercises
#
def hex2base64(a)
    [[a].pack("H*")].pack("m0") 
end

def base642hex(a)
    a.unpack("m0")[0].unpack("H*")[0]
end

def fixedXOR(a, b)
    result = (a.to_i(16) ^ b.to_i(16)).to_s(16)
    if (result.length % 2).odd?
        result = "0" + result
    end
    result
end

def singlebyteXOR(a)
    # taken from http://www.math.cornell.edu/~mec/2003-2004/cryptography/subs/frequencies.html
    most_common_letters = ["E", "T", "A", "O", "I", "N", "S", "H", "R", "D", "L", "U", " "]
    # filter out most strings by only allowing printable strings
    valid_char_vals =*(32..126)
    valid_char_vals.push(10) # \n
    highest_score = 0
    xor_char = 0
    secret_phrase = ""
    encoded_phase = ""
    for i in 1..255 do
        fullstring = ""
        j = 0
        # XOR each byte with i
        moveon = false 
        while j < a.length
            # eliminate phrases with non-printable characters
            value = (a.slice(j, 2).to_i(16) ^ i)
            if !valid_char_vals.include? value
                moveon = true
                break 
            end
            # using % notation instead of to_s because fixed-length value is needed e.g. 0A
            fullstring += "%02X" % value
            j += 2
        end
        if moveon
            next
        end

        # full decoded string
        decoded = [fullstring].pack("H*")
        # remove all non-alpha and non-space characters, then do shitty frequency analysis
        all_alpha = decoded.upcase.gsub(/[^A-Z\s]/i, "")
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
                encoded_phrase = fullstring
            end
        end
    end
    result = {
        "secret_phrase" => secret_phrase,
        "score" => highest_score,
        "xor_char" => [xor_char.to_s(16)].pack("H*"),
        "encoded_phrase" => encoded_phrase
    }
    result
end


def findSecret(filename)
    file = File.new(filename, "r")
    best_result = {"score" => 0}
    decoded_line = ""
    while (line = file.gets)
        result = singlebyteXOR(line) 
        if !result['secret_phrase'].empty? && result['score'] > best_result['score'] 
            best_result = result
            decoded_line = line
        end
    end
    puts "Secret phrase: #{best_result['secret_phrase']}"
end

def repeatingKeyXOR(message, key)
    full_key = ""
    for i in 0..message.length - 1
        full_key += key[i % key.length]
    end
    hex_message = message.unpack("H*")[0]
    hex_key = full_key.unpack("H*")[0]
    fixedXOR(hex_message, hex_key)
end

def ascii2bin(a)
    result = ""
    a.each_char{|c| result += "%08b" % c.ord }
    result
end

def hammingDistance(a, b)
    a = ascii2bin(a)
    b = ascii2bin(b)
    raise "ERROR: Hamming: Non equal lengths" if a.length != b.length
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
end

# tests

# lol plaintext: "I'm killing your brain like a poisonous mushroom"
one_hexstr = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d"
one_base64str = "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t"
fail if !hex2base64(one_hexstr).eql?(one_base64str)
puts "Exercise 1 passed"

two_input1 = "1c0111001f010100061a024b53535009181c"
two_input2 = "686974207468652062756c6c277320657965"
two_output = "746865206b696420646f6e277420706c6179"
fail if !fixedXOR(two_input1, two_input2).eql?(two_output)
puts "Exercise 2 passed"

# Secret phrase: Cooking MC's like a pound of bacon
three_input = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"
result = singlebyteXOR(three_input)
puts "Exercise 3"
puts "Secret phrase: #{result['secret_phrase']}"

puts "Exercise 4"
findSecret("4.txt")

phrase = "Burning 'em, if you ain't quick and nimble
I go crazy when I hear a cymbal"
solution = "0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f"
fail if !repeatingKeyXOR(phrase, "ICE").eql?(solution)
puts "Exercise 5 passed"

s1 = "this is a test"
s2 = "wokka wokka!!!"
fail if !hammingDistance(s1, s2).eql?(37)
puts "Exercise 6 part 1 passed"
# Secret key is 'Terminator X: Bring the noise'
breakRepeatingKeyXOR("6.txt")
