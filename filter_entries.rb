require 'json'
require 'time'
require 'date'

puts(JSON.parse($stdin.read, symbolize_names: true).select do |entry|
    published_at = Time.parse(entry[:published_at])
    today = Date.today
    yesterday = today - 1
    published_at.between?(yesterday.to_time, today.to_time)
end.to_json)