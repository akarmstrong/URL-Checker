#!/usr/bin/env ruby
require 'net/http'
require 'uri'


# Get response from uri_str. 
# Follow up to 10 redirects until uri_str returns as
# success or not success (basically not a redirect)
# 
# Returns true if not success or redirect
# Returns false if success
def fetch(uri_str, limit = 10)
  # You should choose better exception. 
  raise ArgumentError, 'HTTP redirect too deep' if limit == 0

  url = URI.parse(uri_str)
  

  response = Net::HTTP.get_response(url)
  
  # Check response
  # Based off of http://ruby-doc.org/stdlib-1.8.7/libdoc/net/http/rdoc/Net/HTTPResponse.html
  case response
  # Didn't 404 or redirect
  when Net::HTTPSuccess
    false
  # Redirect
  when Net::HTTPRedirection
    puts "Following redirect..."
    new_url = URI.parse(response['location'])
    new_url_str = new_url.to_s
    
    # Add domain if just path
    unless ( new_url_str.include? url.host )
      new_url_str.insert(0, url.host )
    end
    
    # Add in http:// if needed
    unless ( new_url_str.match( /^http\:\/\// ) )
      new_url_str.insert( 0, "http://" )
    end
    
    # Recursion!
    fetch( new_url_str, limit - 1 )
    
  # 404!
  else 
    true
  end
end


# Starts the checking of a url
def is_broken?( url )
  puts "Checking #{url}"
  return fetch url
  
end



# Make sure have all args
unless ARGV.length == 2
  puts "Dude, not the right number of arguments."
  puts "Usage: ruby filesplitter.rb ExportFile.txt\n"
  exit
end

# Assign args
file_to_read = ARGV[0]
file_to_write = ARGV[1]

# Grab urls from file
urls_wc = `wc -l #{file_to_read}`
urls_total = urls_wc.split.first.to_i.to_i
urls_to_check = IO.readlines( file_to_read )

# Open file to write results to
result = File.new(file_to_write,  "w+")


# Counters
urls_count = 0
urls_broken = 0;

# Check each url 
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



