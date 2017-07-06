#!/usr/bin/env ruby

# http://www.cryptopals.com/sets/3/challenges/17

require_relative "../set2/ten"
require_relative "../set2/eleven"
require_relative "../set2/fifteen"

$key = generate_random_bytes(16)
$iv = generate_random_bytes(16)

$random_strings = [
    "MDAwMDAwTm93IHRoYXQgdGhlIHBhcnR5IGlzIGp1bXBpbmc=",
    "MDAwMDAxV2l0aCB0aGUgYmFzcyBraWNrZWQgaW4gYW5kIHRoZSBWZWdhJ3MgYXJlIHB1bXBpbic=",
    "MDAwMDAyUXVpY2sgdG8gdGhlIHBvaW50LCB0byB0aGUgcG9pbnQsIG5vIGZha2luZw==",
    "MDAwMDAzQ29va2luZyBNQydzIGxpa2UgYSBwb3VuZCBvZiBiYWNvbg==",
    "MDAwMDA0QnVybmluZyAnZW0sIGlmIHlvdSBhaW4ndCBxdWljayBhbmQgbmltYmxl",
    "MDAwMDA1SSBnbyBjcmF6eSB3aGVuIEkgaGVhciBhIGN5bWJhbA==",
    "MDAwMDA2QW5kIGEgaGlnaCBoYXQgd2l0aCBhIHNvdXBlZCB1cCB0ZW1wbw==",
    "MDAwMDA3SSdtIG9uIGEgcm9sbCwgaXQncyB0aW1lIHRvIGdvIHNvbG8=",
    "MDAwMDA4b2xsaW4nIGluIG15IGZpdmUgcG9pbnQgb2g=",
    "MDAwMDA5aXRoIG15IHJhZy10b3AgZG93biBzbyBteSBoYWlyIGNhbiBibG93"
]

def encrypt()
    #string = $random_strings[rand($random_strings.length)]
    string = "MDAwMDAxV2l0aCB0aGUgYmFzcyBraWNrZWQgaW4gYW5kIHRoZSBWZWdhJ3MgYXJlIHB1bXBpbic="
    string = string.unpack("m0")[0]
    cbc_encrypt(string, $key, $iv).unpack("m0")[0]
end

def padding_oracle(ciphertext)
    decrypted = cbc_decrypt([ciphertext].pack("m0"), $key, $iv)
    begin
        plain = remove_padding(decrypted)
    rescue
        return false
    end
    true
end

def decrypt_block(blocks)
    plain = ""
    fail unless blocks.length.eql?(32)
    first = blocks[0..15] 
    second = blocks[16..31]
    (1..16).each do |i|
        padding = ("%02x" % i) * i
        (0..255).each do |j|
            index = 16 - i
            tail = first[index..15]
            elem = tail.unpack("H*")[0]
            teststr = j.chr + plain
            replace = fixed_xor(fixed_xor(teststr.unpack("H*")[0], padding), elem)
            testblock =  first[0..index - 1] + [replace].pack("H*") + second
            if padding_oracle(testblock)
                plain = teststr
                break
            end
        end
    end
    plain
end

def attack()
    blocksize = 16
    ciphertext = encrypt()
    blocks = ciphertext.length / blocksize
    ciphertext = $iv + ciphertext
    plain = ""
    (0..blocks - 1).each do |i|
        plain += decrypt_block(ciphertext.slice(i*blocksize, blocksize*2))
    end
    plain
end

# tests
if __FILE__ == $0
    puts attack()
    puts "Challenge #17 tests passed"
end
