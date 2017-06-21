#!/usr/bin/env ruby

# http://www.cryptopals.com/sets/2/challenges/11

require_relative "./ten"

def generate_random_bytes(n)
    value = ""
    n.times{ value << rand(255).chr }
    value
end

def encryption_oracle(message)
    blocksize = 16
    # randomly encrypts a message with either ecb or cbc
    key = generate_random_bytes(blocksize)

    prepend_num_bytes = 5 + rand(6)
    prepend_bytes = generate_random_bytes(prepend_num_bytes)
    append_num_bytes = 5 + rand(6)
    append_bytes = generate_random_bytes(append_num_bytes)
    message = prepend_bytes + message + append_bytes

    coin_flip =  rand(2)
    if coin_flip.eql?(0)
        encrypted = add_padding(ecb_encrypt(message, key), blocksize)
    else
        iv = generate_random_bytes(blocksize)
        encrypted = cbc_encrypt(message, key, iv)
    end
    encrypted
end

def detect_aes_mode()
    blocksize = 16
    input = "Z"* blocksize * 4
    output = encryption_oracle(input)

    mode = "CBC"
    if output.slice(blocksize*2, blocksize).eql?(output.slice(blocksize*3, blocksize))
       mode = "ECB"
    end
    mode
end

# test
if __FILE__ == $0
    a = {"CBC" => 0, "ECB" => 0}

    100.times do
        result = detect_aes_mode()
        a[result] += 1
    end
    # probability
    fail unless a["CBC"] > 40
    fail unless a["ECB"] > 40

    puts "Challenge #11 test passed"
end
