#!/usr/bin/env ruby

# http://www.cryptopals.com/sets/2/challenges/14

require_relative "./ten"
require_relative "./eleven"
require_relative "./fifteen"

$key = generate_random_bytes(16)
prepend_num_bytes = 5 + rand(50)
$prefix = generate_random_bytes(prepend_num_bytes)

def cipher_base_size()
    start = ""
    cipher = msgappend_encrypt(start)
    cipher.length
end

def parse_cipher_segments(blocksize)
    # determine what the padding block looks like
    num_blocks = 3
    padding = "\x00" * blocksize * num_blocks
    encr_padding = msgappend_encrypt(padding)
    blocks = encr_padding.length / blocksize
    encrypted_padding_block = ""
    total_length = 0
    (0..blocks).each do |i|
        block = encr_padding.slice(i * blocksize, blocksize)
        if block.eql?(encr_padding.slice((i+1) * blocksize, blocksize))
            encrypted_padding_block = block
            break
        end
    end

    # determine base cipher length
    base_size = cipher_base_size()

    # get the segment lengths
    segments = {}
    padding = "\x00" * blocksize
    encr_padding = msgappend_encrypt(padding)
    cipher_length = encr_padding.length
    (blocksize+1..blocksize*2).each do |i|
        padding = "\x00" * i
        encr_padding = msgappend_encrypt(padding)
        found_padding = encr_padding.index(encrypted_padding_block)
        if found_padding
            segments['prefix_length'] = found_padding - (i - blocksize)
            segments['suffix_length'] = encr_padding.length - found_padding - blocksize
            break
        end
    end
    segments
end

def byte_at_a_time_decryption(blocksize)
    segments = parse_cipher_segments(blocksize)
    prefix_padding  = blocksize - (segments["prefix_length"] % blocksize)
    start_i = segments["prefix_length"] + prefix_padding
    last_decrypted = nil
    decrypted_suffix = ""
    while !last_decrypted.eql?(decrypted_suffix)
        padding = "\x00" * (prefix_padding + segments["suffix_length"] - decrypted_suffix.length - 1)
		encr_padding = msgappend_encrypt(padding).slice(start_i, segments["suffix_length"])
        (0..255).each do |i|
            plain = padding + decrypted_suffix + i.chr
            encr_plain = msgappend_encrypt(plain).slice(start_i, segments["suffix_length"])
            if encr_plain.eql?(encr_padding)
                decrypted_suffix += i.chr
                break
            end
            last_decrypted = decrypted_suffix
        end
    end
	remove_padding(decrypted_suffix)
end

def msgappend_encrypt(message)
    target_bytes = "Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkgaGFpciBjYW4gYmxv"\
                   "dwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBqdXN0IHRvIHNheSBoaQpEaWQgeW91IHN0"\
                   "b3A/IE5vLCBJIGp1c3QgZHJvdmUgYnkK"
    message = add_padding($prefix + message + target_bytes.unpack("m0")[0], 16)
    ecb_encrypt(message, $key)
end


# tests
if __FILE__ == $0
    blocksize = 16
    result = byte_at_a_time_decryption(blocksize)
    fail unless result.length.eql?(138)
    fail unless result.slice(0, blocksize).eql?("Rollin' in my 5.")
    puts "Challenge #14 tests passed"
end
