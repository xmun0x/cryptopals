#!/usr/bin/env ruby

# http://www.cryptopals.com/sets/1/challenges/4

require_relative "./three"

def findSecret(filename)
    file = File.new(filename, "r")
    best_result = {"score" => 0}
    while (line = file.gets)
        result = singlebyteXOR(line) 
        if !result['secret_phrase'].empty? && result['score'] > best_result['score'] 
            best_result = result
        end
    end
    return best_result['secret_phrase']
end

# test
if __FILE__ == $0
    solution = "Now that the party is jumping\n5"
    fail if !findSecret("4.txt").eql?(solution)
    puts "Challenge #4 test passed"
end
