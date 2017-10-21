#!/usr/bin/env ruby

# http://www.cryptopals.com/sets/3/challenges/19

require_relative "../set2/eleven"
require_relative "../set1/six"
require_relative "../set1/two"
require_relative "./eighteen"


strings = [
    "SSBoYXZlIG1ldCB0aGVtIGF0IGNsb3NlIG9mIGRheQ==",
    "Q29taW5nIHdpdGggdml2aWQgZmFjZXM=",
    "RnJvbSBjb3VudGVyIG9yIGRlc2sgYW1vbmcgZ3JleQ==",
    "RWlnaHRlZW50aC1jZW50dXJ5IGhvdXNlcy4=",
    "SSBoYXZlIHBhc3NlZCB3aXRoIGEgbm9kIG9mIHRoZSBoZWFk",
    "T3IgcG9saXRlIG1lYW5pbmdsZXNzIHdvcmRzLA==",
    "T3IgaGF2ZSBsaW5nZXJlZCBhd2hpbGUgYW5kIHNhaWQ=",
    "UG9saXRlIG1lYW5pbmdsZXNzIHdvcmRzLA==",
    "QW5kIHRob3VnaHQgYmVmb3JlIEkgaGFkIGRvbmU=",
    "T2YgYSBtb2NraW5nIHRhbGUgb3IgYSBnaWJl",
    "VG8gcGxlYXNlIGEgY29tcGFuaW9u",
    "QXJvdW5kIHRoZSBmaXJlIGF0IHRoZSBjbHViLA==",
    "QmVpbmcgY2VydGFpbiB0aGF0IHRoZXkgYW5kIEk=",
    "QnV0IGxpdmVkIHdoZXJlIG1vdGxleSBpcyB3b3JuOg==",
    "QWxsIGNoYW5nZWQsIGNoYW5nZWQgdXR0ZXJseTo=",
    "QSB0ZXJyaWJsZSBiZWF1dHkgaXMgYm9ybi4=",
    "VGhhdCB3b21hbidzIGRheXMgd2VyZSBzcGVudA==",
    "SW4gaWdub3JhbnQgZ29vZCB3aWxsLA==",
    "SGVyIG5pZ2h0cyBpbiBhcmd1bWVudA==",
    "VW50aWwgaGVyIHZvaWNlIGdyZXcgc2hyaWxsLg==",
    "V2hhdCB2b2ljZSBtb3JlIHN3ZWV0IHRoYW4gaGVycw==",
    "V2hlbiB5b3VuZyBhbmQgYmVhdXRpZnVsLA==",
    "U2hlIHJvZGUgdG8gaGFycmllcnM/",
    "VGhpcyBtYW4gaGFkIGtlcHQgYSBzY2hvb2w=",
    "QW5kIHJvZGUgb3VyIHdpbmdlZCBob3JzZS4=",
    "VGhpcyBvdGhlciBoaXMgaGVscGVyIGFuZCBmcmllbmQ=",
    "V2FzIGNvbWluZyBpbnRvIGhpcyBmb3JjZTs=",
    "SGUgbWlnaHQgaGF2ZSB3b24gZmFtZSBpbiB0aGUgZW5kLA==",
    "U28gc2Vuc2l0aXZlIGhpcyBuYXR1cmUgc2VlbWVkLA==",
    "U28gZGFyaW5nIGFuZCBzd2VldCBoaXMgdGhvdWdodC4=",
    "VGhpcyBvdGhlciBtYW4gSSBoYWQgZHJlYW1lZA==",
    "QSBkcnVua2VuLCB2YWluLWdsb3Jpb3VzIGxvdXQu",
    "SGUgaGFkIGRvbmUgbW9zdCBiaXR0ZXIgd3Jvbmc=",
    "VG8gc29tZSB3aG8gYXJlIG5lYXIgbXkgaGVhcnQs",
    "WWV0IEkgbnVtYmVyIGhpbSBpbiB0aGUgc29uZzs=",
    "SGUsIHRvbywgaGFzIHJlc2lnbmVkIGhpcyBwYXJ0",
    "SW4gdGhlIGNhc3VhbCBjb21lZHk7",
    "SGUsIHRvbywgaGFzIGJlZW4gY2hhbmdlZCBpbiBoaXMgdHVybiw=",
    "VHJhbnNmb3JtZWQgdXR0ZXJseTo=",
    "QSB0ZXJyaWJsZSBiZWF1dHkgaXMgYm9ybi4="
]

def get_best_score(arr)
    arr.sort_by {|k,v| v}.reverse[0][0].to_s(16)
end

def cribdrag(ciphertexts)
    valid_char_vals = *(32..122)
    puts valid_char_vals
    [0].pack("V") * 2
    longest = ""
    hex_ciphertexts = []
    ciphertexts.each do |c|
        result = base642hex(c)
        if result.length > longest.length
            longest = result
        end
        hex_ciphertexts.push(result)
    end

    # find all possible matches for longest string
    hex_ciphertexts.delete(longest)
    all_possible_matches = []
    (0..longest.length/2).each do |i|
        matches = []
        (0..255).each do |j|
            value = (longest.slice(i, 2).to_i(16) ^ j)
            if valid_char_vals.include? value
                matches.push(j)
            end
        end
        all_possible_matches.push(matches)
    end
    # validate against other strings to find the true value for each bytes of keystream
    p all_possible_matches
    keystream = ""
    (0..all_possible_matches.length - 1).each do |k|
        all_possible_matches[k].each do |l|
            temp_results = []
            b = false
            hex_ciphertexts.each do |h|
                if k*2 > h.length
                    puts "next"
                    next 
                end
                value = h.slice(k, 2).to_i(16) ^ l
                if !valid_char_vals.include? value
                    all_possible_matches[k].delete(l)
                    b = true
                    break 
                else
                   temp_results.push([fixed_xor(h.slice(0, keystream.length + 2), keystream + l.to_s(16))].pack('H*'))
                end
            end
            if b.eql?(true)
                next
            end
            puts temp_results 
            puts "Does this look good? (y/n)"
            response = gets
            if response.eql?("y\n")
                keystream += l.to_s(16)
                break
            end
        end
    end
end

# test
if __FILE__ == $0
    key = generate_random_bytes(16)
    nonce = [0].pack("V") * 2
    ciphertexts = []
    strings.each do |i|
        i_decoded = i.unpack("m0")[0]
        ciphertexts.push(ctr_encrypt(i_decoded, key, nonce))
    end
    cribdrag(ciphertexts)
    puts "Challenge #19 test passed"
end
