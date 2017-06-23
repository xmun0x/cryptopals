#!/usr/bin/env ruby

# http://www.cryptopals.com/sets/2/challenges/16

require_relative "../set1/two"
require_relative "./nine"
require_relative "./ten"
require_relative "./eleven"
require_relative "./fifteen"

$key = generate_random_bytes(16)
$iv = "\x00" * 16

def encrypt(string)
    blocksize = 16
    string = string.gsub("=", "'='")
    string = string.gsub(";", "';'")
    string = "comment1=cooking%20MCs;userdata=" + string + ";comment2=%20like%20a%20pound%20of%20bacon"
    # this method return base64-encoded ciphertext. decode before returning
    cbc_encrypt(string, $key, $iv).unpack("m0")[0]
end

def is_admin(cipher)
    encoded = [cipher].pack("m0")
    plaintext = remove_padding(cbc_decrypt(encoded, $key, $iv))
    if plaintext.index(";admin=true;")
        return true
    end
    false
end

def cbc_bitflip_attack()
    base_cipher = encrypt("")
    blocksize = 16

    # find the number of identical beginning blocks
    blocks = base_cipher.length / blocksize
    next_cipher = encrypt("\x00")
    same_blocks = 0
    (0..blocks).each do |i|
        same_blocks = i
        break unless base_cipher.slice(i * blocksize, blocksize).eql?(next_cipher.slice(i * blocksize, blocksize))
    end

    desired_string = ";admin=true;"
    input = "A" * blocksize
    cipher = encrypt(input)
    cipher_hex = cipher.unpack("H*")[0]
    input_hex = ("A" * desired_string.length).unpack("H*")[0]
    desired_string_hex = desired_string.unpack("H*")[0]

    # start with the block before the block with user-controlled bytes
    start = (same_blocks - 1)* blocksize
    res = fixed_xor(cipher_hex.slice(start*2, desired_string.length*2), input_hex)
    res = [fixed_xor(res, desired_string_hex)].pack("H*")
    cipher[start..start + desired_string.length - 1] = res 
    is_admin(cipher)
end

# test
if __FILE__ == $0
    fail unless cbc_bitflip_attack()
    puts "Challenge #16 test passed"
end
