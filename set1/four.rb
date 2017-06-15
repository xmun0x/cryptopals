#!/usr/bin/env ruby

# http://www.cryptopals.com/sets/1/challenges/4

require_relative "./three"

def find_secret(filename)
    file = File.new(filename, "r")
    best_result = {"score" => 0}
    while (line = file.gets)
        result = single_byte_xor(line) 
        if !result['secret_phrase'].empty? && result['score'] > best_result['score'] 
            best_result = result
        end
    end
    best_result['secret_phrase']
end

# test
if __FILE__ == $0
    solution = "Now that the party is jumping\n5"
    fail unless find_secret("4.txt").eql?(solution)
    puts "Challenge #4 test passed"
end
