#!/usr/bin/env ruby
require 'net/http'
require 'uri'

def fetch(uri_str, limit = 10)
  # You should choose better exception. 
  raise ArgumentError, 'HTTP redirect too deep' if limit == 0

  url = URI.parse(uri_str)
  

  response = Net::HTTP.get_response(url)
  case response
  when Net::HTTPSuccess
    false
  when Net::HTTPRedirection
    puts "Following redirect..."
    new_url = URI.parse(response['location'])
    new_url_str = new_url.to_s
    
    unless ( new_url_str.include? url.host )
      new_url_str.insert(0, url.host )
    end
    
    unless ( new_url_str.match( /^http\:\/\// ) )
      new_url_str.insert( 0, "http://" )
    end
    
    fetch( new_url_str, limit - 1 )
  else 
    true
  end
end



def is_broken?( url )
  puts "Checking #{url}"
  return fetch url
  
end


unless ARGV.length == 2
  puts "Dude, not the right number of arguments."
  puts "Usage: ruby filesplitter.rb ExportFile.txt\n"
  exit
end

file_to_read = ARGV[0]
file_to_write = ARGV[1]

urls_wc = `wc -l #{file_to_read}`
urls_total = urls_wc.split.first.to_i.to_i
urls_to_check = IO.readlines( file_to_read )
result = File.new(file_to_write,  "w+")




urls_count = 0
urls_broken = 0;
urls_to_check.each do | url |
  url.chomp
  url.insert(0, "http://") unless(url.match(/^http\:\/\//))
  
  if is_broken? url
    puts "Broken\n"
    urls_broken += 1
    result.puts( url )
  end
  
  
  # Update progress
  urls_count += 1
  puts "Progress: #{urls_count} / #{urls_total} | Broken: #{urls_broken}\n\n"
end



