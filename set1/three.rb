#!/usr/bin/env ruby

# http://www.cryptopals.com/sets/1/challenges/3

def single_byte_xor(a)
    # taken from http://www.math.cornell.edu/~mec/2003-2004/cryptography/subs/frequencies.html
    most_common_letters = ["E", "T", "A", "O", "I", "N", "S", "H", "R", "D", "L", "U", " "]

    # filter out most strings by only allowing printable characters 
    valid_char_vals = *(32..126)
    valid_char_vals.push(10) # \n
    result = {
        "score" => 0,
        "xor_char" => 0,
        "secret_phrase" => "",
        "encoded_phase" => ""
    }
    (1..255).each do |i|
        fullstring = ""
        j = 0
        moveon = false 
        while j < a.length
            value = (a.slice(j, 2).to_i(16) ^ i)
            if !valid_char_vals.include? value
                moveon = true
                break 
            end
            # using % notation instead of to_s because fixed-length value is needed e.g. 0A
            fullstring += "%02X" % value
            j += 2
        end

        # short circuit loop if non-printable char found
        if moveon
            next
        end

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
            if score > result["score"]
                result["score"] = score
                result["xor_char"] = [i.to_s(16)].pack("H*")
                result["secret_phrase"] = decoded
                result["encoded_phrase"] = fullstring
            end
        end
    end
    result
end

# test
if __FILE__ == $0
    three_input = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"
    result = single_byte_xor(three_input)
    fail unless result['secret_phrase'].eql?("Cooking MC's like a pound of bacon")
    puts "Challenge #3 test passed"
end
