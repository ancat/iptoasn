# iptoasn

`iptoasn` is a Ruby gem that provides a simple way to query Autonomous System (AS) information for a given IP address using the [iptoasn.com](https://iptoasn.com) dataset. This repo only contains the `iptoasn` gem which is responsible for loading, parsing, and searching through the ip2asn dataset. The data itself is in the [iptoasn-data](https://github.com/ancat/iptoasn-data) repository. This makes managing updates to the code vs the data a bit simpler.

## Features

- Query AS information by IP address.
- Efficient lazy loading to minimize memory usage.
- Compatible with IPv4 addresses.

## Installation and Updates

Add this line to your application's Gemfile:

```ruby
gem 'iptoasn'
gem 'iptoasn-data'
```

And then execute:

```bash
bundle install
```

The dataset can be updated periodically by running `bundle update iptoasn-data`.

## Usage

Here is a basic example of how to use the `iptoasn` gem:

```ruby
require 'iptoasn'

finder = IpToAsn::Lookup.new
ip_address = ARGV[0]

response = finder.lookup(ip_address)
if response.nil?
  puts "Couldn't locate #{ip_address}!"
  exit 1
end

puts "#{ip_address} is in #{response[:country_code]} and belongs to #{response[:as_name]}"
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Acknowledgments

This gem utilizes the [iptoasn.com](https://iptoasn.com) dataset. Special thanks to them for providing this valuable resource.
