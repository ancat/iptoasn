# iptoasn

`iptoasn` is a Ruby gem that provides a simple way to query Autonomous System (AS) information for a given IP address using the [iptoasn.com](https://iptoasn.com) dataset. This gem directly contains the iptoasn dataset broken up into chunks; at build time an index is created so individual chunks can be lazy loaded.

## Features

- Query AS information by IP address.
- Efficient lazy loading to minimize memory usage.
- Compatible with IPv4 addresses.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'iptoasn'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install iptoasn
```

## Usage

Here is a basic example of how to use the `iptoasn` gem:

```ruby
require 'iptoasn'

finder = IpToAsn.new
ip_address = ARGV[0]

response = finder.lookup(ip_address)
if response.nil?
  puts "Couldn't locate #{ip_address}!"
  exit 1
end

puts "#{ip_address} is in #{response[:country_code]} and belongs to #{response[:as_name]}"
```

## Building

```shell
$ make fetch   # grab the latest copy of the dataset
$ make process # break it up into chunks
$ make index   # build indexes
$ make clean   # clean up
```

## Dataset

The gem wraps the [iptoasn.com](https://iptoasn.com) dataset, which contains information about:
- IP address ranges (start and end IPs)
- Autonomous System Numbers (ASNs)
- Country codes
- Autonomous System names

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Acknowledgments

This gem utilizes the [iptoasn.com](https://iptoasn.com) dataset. Special thanks to them for providing this valuable resource.
