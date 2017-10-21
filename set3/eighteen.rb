#!/usr/bin/env ruby

# http://www.cryptopals.com/sets/3/challenges/18

require_relative "../set1/seven"
require_relative "../set2/ten"
require_relative "../set2/fifteen"

def encrypt_ctr_block(block, key, nonce, counter)
    # no native 64-bit little endian conversions in ruby, so fake it with 32-bit
    # assumes small messages
    counter = [counter].pack("V") + [0].pack("V")
    encr_counter = ecb_encrypt(nonce + counter, key).slice(0, block.length).unpack("H*")[0]
    block = block.unpack("H*")[0]
    [fixed_xor(encr_counter, block)].pack("H*")
end

def ctr_encrypt(message, key, nonce)
    blocksize = 16
    blocks = message.length / blocksize

    if (message.length % blocksize).eql?(0)
        blocks -= 1
    end

    encrypted =  ""

    (0..blocks).each do |i|
        block = message.slice(i*blocksize, blocksize)
        encrypted += encrypt_ctr_block(block, key, nonce, i)
    end

    [encrypted].pack("m0")
end

def ctr_decrypt(ciphertext, key, nonce)
    raw = ciphertext.unpack("m0")[0]
    ctr_encrypt(raw, key, nonce).unpack("m0")[0]
end


# test
if __FILE__ == $0
    nonce = [0].pack("V") * 2
    key = "YELLOW SUBMARINE"
    ciphertext = "L77na/nrFsKvynd6HzOoG7GHTLXsTVu9qvY/2syLXzhPweyyMTJULu/6/kXX0KSvoOLSFQ=="
    result = "Yo, VIP Let's kick it Ice, Ice, baby Ice, Ice, baby "
    fail unless ctr_decrypt(ciphertext, key, nonce).eql?(result)
    puts "Challenge #18 test passed"
end
