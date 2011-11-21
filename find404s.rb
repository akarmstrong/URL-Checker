#!/usr/bin/env ruby
require 'net/http'
require 'uri'

def is_broken?( url )
  uri = URI.parse( url )
  response = nil
  Net::HTTP.start( uri.host, uri.port ) do | http |
    response = http.head(uri.path.size > 0 ? url.path : "/")
  end
  return response.code == "404"
end

puts "Please enter the file to read: "
file_to_read = gets.chomp
urls_to_check = IO.readlines( file_to_read )

need_redirects = ''
urls_to_check.each do | url |
  url.chomp
  # check if http:// was in the url if not add it in there
	url.insert(0, "http://") unless(url.match(/^http\:\/\//))
	puts "Checking #{url}..."
	# Get the HTTP_RESPONSE from the site we are checking
	res = Net::HTTP.get_response(URI.parse(url.to_s))
	# Check the response code and send an email if the code is bad
	puts "code: #{res.code}\n"
	need_redirects.append( url ) if res.code =~ 404
#	if (res.code =~ /2|3\d{2}/ ) then
#  need_redirects.append( url ) if is_broken? url
end

puts "The following 404'ed:\n#{need_redirects}"



