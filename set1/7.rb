# openssl enc -a -d -aes-128-ecb -k "YELLOW SUBMARINE" -in 7.txt

require "openssl"

def base642plain(a)
    a.unpack("m0")[0]
end

def aesDecrypt(message, key)
	decipher = OpenSSL::Cipher::AES.new(128, :ECB)
  	decipher.decrypt
  	decipher.padding = 0
  	decipher.key = key
	plain = decipher.update message + decipher.final
end

def decrypt()
    key = "YELLOW SUBMARINE"
    lines = ""
    file = File.new("7.txt", "r")
    while (line = file.gets)
        lines += line.chomp
    end
    lines = base642plain(lines)
    puts aesDecrypt(lines, key)
end

decrypt()
