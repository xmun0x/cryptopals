#!/usr/bin/env ruby

# http://www.cryptopals.com/sets/1/challenges/7

require "openssl"

def aes_decrypt(message, key)
    decipher = OpenSSL::Cipher::AES.new(128, :ECB)
    decipher.decrypt
    decipher.padding = 0
    decipher.key = key
    plain = decipher.update message + decipher.final
end

def decrypt(filename, key)
    lines = ""
    file = File.new(filename, "r")
    while (line = file.gets)
        lines += line.chomp
    end
    # convert base64 to plaintext
    lines = lines.unpack("m0")[0]
    aes_decrypt(lines, key)
end

# tests
if __FILE__ == $0
    key = "YELLOW SUBMARINE"
    result = decrypt("7.txt", key)
    fail unless result.length.eql?(2880)
    fail unless result.slice(0, 33).eql?("I'm back and I'm ringin' the bell")
    puts "Challenge #7 tests passed"
end
