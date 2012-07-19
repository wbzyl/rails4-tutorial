def parse(io)
  pattern = /.*"(?<method>[A-Z]{3,}) (?<url>.*?)(\?(.*?))? HTTP\/1\.\d" (?<status>\d\d\d)/
  results = {}
  io.each do |line|
    next unless line.include?(' 404 ')

    match = pattern.match(line)
    status = match[:status].to_i
    next unless status == 404

    url = "#{match[:method]} #{match[:url]}"
    results[url] = 0 unless results.include?(url)
    results[url] += 1
  end
  results
end

results = parse File.new PATH_TO_ACCESS_LOG
