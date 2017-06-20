#!/usr/bin/env ruby

# http://www.cryptopals.com/sets/2/challenges/10

require "openssl"
require_relative "../set1/two"
require_relative "../set1/seven"
require_relative "../set1/six"
require_relative "../set2/nine"

def ecb_encrypt(message, key)
    aes = OpenSSL::Cipher::AES.new(128, :ECB)
    aes.encrypt
    aes.key = key
    aes.update(message)
end

def cbc_decrypt(message, key, iv)
    # decode base64 to plaintext
    message = message.unpack("m0")[0]
	i = 0
	blocksize = 16
	result = ""
    last = iv
	while i < message.length
        block = message.slice(i, blocksize)
        # encode hex for xor
        result += fixed_xor(ecb_decrypt(block, key).unpack("H*")[0], last.unpack("H*")[0])
        last = block
        i += blocksize
	end
    # return plaintext result
    [result].pack("H*")
end

def cbc_encrypt(message, key, iv)
    blocksize = 16

    # add padding to messages that need it
    unless (message.length % blocksize).eql?(0)
        size = (message.length / blocksize) * blocksize + blocksize
        message = add_padding(message, size)
    end

    message = message.unpack("H*")[0]
    results = [iv]
    # double block size because hex
    blocksize = blocksize * 2
    i = 0
	while i < message.length
        xor = fixed_xor(message.slice(i, blocksize), results[-1].unpack("H*")[0])
        results.push(ecb_encrypt([xor].pack("H*"), key))
        i += blocksize
    end

    # purge iv
    results.shift
    [results.join("")].pack("m0")
end

# test
if __FILE__ == $0
    body = ""
    file = File.new("10.txt", "r")
    while (line = file.gets)
        body += line.chomp
    end

    key = "YELLOW SUBMARINE"
    iv = "\x00" * 16

    result = cbc_decrypt(body, key, iv)
    fail unless result.length.eql?(2880)
    fail unless result.slice(0, 33).eql?("I'm back and I'm ringin' the bell")

    result = cbc_encrypt(result, key, iv)
    fail unless result.eql?(body)

    puts "Challenge #10 test passed"
end
