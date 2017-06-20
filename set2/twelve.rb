#!/usr/bin/env ruby

# http://www.cryptopals.com/sets/2/challenges/12

require_relative "./ten"
require_relative "./eleven"

$key = generate_random_bytes(16)

def compute_block_size()
    start = ""
    cipher = msgappend_encrypt(start)
    start_length = cipher.length
    while true
        start += "A"
        cipher = msgappend_encrypt(start)
        break unless cipher.length.eql?(start_length)
    end
    cipher.length - start_length
end

def cipher_detection(blocksize)
	input = "Z" * blocksize * 4
	mode = "CBC"
    output = msgappend_encrypt(input)
	if output.slice(blocksize*2, blocksize).eql?(output.slice(blocksize*3, blocksize))
	   mode = "ECB"
	end
	mode
end

def byte_at_a_time_decryption(blocksize)
    padding = ""
    encr_padding = msgappend_encrypt(padding)
    chars_to_decrypt = encr_padding.length + blocksize

    decrypted_append = ""
    last_decrypted = nil
    while !last_decrypted.eql?(decrypted_append)
        padding = "\x00" * (chars_to_decrypt - decrypted_append.length - 1)
        encr_padding = msgappend_encrypt(padding).slice(0, chars_to_decrypt)
        (0..255).each do |i|
            plain = padding + decrypted_append + i.chr
            if msgappend_encrypt(plain).slice(0, chars_to_decrypt).eql?(encr_padding)
                decrypted_append += i.chr
                break
            end
        last_decrypted = decrypted_append
        end
    end
    decrypted_append 
end

def msgappend_encrypt(message)
    append_bytes = "Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkgaGFpciBjYW4gYmxv"\
                   "dwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBqdXN0IHRvIHNheSBoaQpEaWQgeW91IHN0"\
                   "b3A/IE5vLCBJIGp1c3QgZHJvdmUgYnkK"
    message = message + append_bytes.unpack("m0")[0]
    encrypted = ecb_encrypt(message, $key)
end


# tests
if __FILE__ == $0

    message = "this is my message."
    cipher = msgappend_encrypt(message)

    blocksize = compute_block_size()
    fail unless blocksize.eql?(16)

    cipher_name = cipher_detection(blocksize)
    fail unless cipher_name.eql?("ECB")

    result = byte_at_a_time_decryption(blocksize)
    fail unless result.length.eql?(138)
    fail unless result.slice(0, blocksize).eql?("Rollin' in my 5.")

    puts "Challenge #12 tests passed"
end
