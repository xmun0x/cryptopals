#!/usr/bin/env ruby

# http://www.cryptopals.com/sets/2/challenges/13

require_relative "./nine"
require_relative "./ten"
require_relative "./eleven"

def remove_padding(string)
    padding = string[-1].unpack("H*")[0].to_i(16)
    if string[-padding] == string[-1]
        return string.slice(0, string.length - padding)
    else
        return string
    end
end

def parse_query_string(input)
    parts = input.split("&")
    hash = {}
    parts.each do |i|
        elems = i.split("=")
        hash[elems[0]] = elems[1]
    end
    hash
end

def generate_query_string(hash)
    hash.collect { |k, v| "#{k}=#{v}" }.join("&")
end

def profile_for(email)
    valid_email = email.sub /[&=]/, ''
    {
        "email" => email,
        "uid" => 10,
        "role" => "user"
    }
end

def encrypt_profile_for(email, key, blocksize)
    padded_string = add_padding(generate_query_string(profile_for(email)), blocksize)
    ecb_encrypt(padded_string, key)
end

def decrypt_profile_for(ciphertext, key)
    decrypted = ecb_decrypt(ciphertext, key)
    parse_query_string(remove_padding(decrypted))
end

# tests
if __FILE__ == $0
    blocksize = 16
    input = "foo=bar&baz=qux&zap=zazzle"
    test_result = {
        "foo" => "bar",
        "baz" => "qux",
        "zap" => "zazzle"
    }

    fail unless parse_query_string(input).eql?(test_result)
    fail unless generate_query_string(test_result).eql?(input)

    test_result2 = "email=hi@foo.bar&uid=10&role=user"
    fail unless generate_query_string(profile_for("hi@foo.bar")).eql?(test_result2)

    key = generate_random_bytes(blocksize)
    # part A
    ciphertext = encrypt_profile_for("hi@foo.bar", key, blocksize)
    # part B
    plain = decrypt_profile_for(ciphertext, key)
    fail unless plain.eql?(parse_query_string(test_result2))

    input1 = "attak@foo.bar"
    ciphertext1 = encrypt_profile_for(input1, key, blocksize)
    # this is blocksize - "email=".length so that "admin" + padding will be in it's own block
    input2 = "Z" * 10 + "admin" + "\x0b" * 11
    ciphertext2 = encrypt_profile_for(input2, key, blocksize)

    copypasta_ciphertext = ciphertext1.slice(0, 32)  + ciphertext2.slice(16, 16)
    hax0r = decrypt_profile_for(copypasta_ciphertext, key)
    desired_result = {"email"=>"attak@foo.bar", "uid"=>"10", "role"=>"admin"}
    fail unless hax0r.eql?(desired_result)

    puts "Challenge #13 tests passed"
end
