#!/usr/bin/env ruby
#
# http://www.cryptopals.com/sets/1/challenges/8

def detect_aes(filename)
    lines = []
    file = File.new(filename, "r")
    while (line = file.gets)
        lines.push(line.chomp)
    end
    lines.each do |l|
        i = 0
        blocks = {}
        while i*32 < l.length
            block = l.slice(i*32, 32)
            if blocks.has_key?(block)
                return l
            else
                blocks[block] = i
            end
            i += 1
        end
    end
end

# test
if __FILE__ == $0
    aes_line = "d880619740a8a19b7840a8a31c810a3d08649af70dc06f4fd5d2d69c744cd283e2dd052f6b641dbf9"\
               "d11b0348542bb5708649af70dc06f4fd5d2d69c744cd2839475c9dfdbc1d46597949d9c7e82bf5a08"\
               "649af70dc06f4fd5d2d69c744cd28397a93eab8d6aecd566489154789a6b0308649af70dc06f4fd5d"\
               "2d69c744cd283d403180c98c8f6db1f2a3f9c4040deb0ab51b29933f2c123c58386b06fba186a"
    line = detect_aes("8.txt")
    fail if !line.eql?(aes_line)
    puts "Challenge #8 test passed"
end
