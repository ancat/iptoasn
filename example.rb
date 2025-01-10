# frozen_string_literal: true

require 'iptoasn'

finder = IpToAsn.new
ip_address = ARGV[0]

response = finder.lookup(ip_address)
if response.nil?
  puts "Couldn't locate #{ip_address}!"
  exit 1
end

puts "#{ip_address} is in #{response[:country_code]} and belongs to #{response[:as_name]}"
