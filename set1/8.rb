def detect_aes()
    lines = []
    file = File.new("8.txt", "r")
    while (line = file.gets)
        lines.push(line.chomp)
    end
    lines.each do |l|
        i = 0
        blocks = {}
        while i*32 <= l.length
            block = l.slice(i*32, 32)
            if blocks.has_key?(block)
                puts "This is probs AES ECB"
                puts l
                break 
            else
                blocks[block] = i
            end
            i += 1
        end
    end
end

detect_aes()
