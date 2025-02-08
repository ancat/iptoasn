# frozen_string_literal: true

require_relative 'lib/iptoasn'
require 'fileutils'

input_file = ARGV[0]
out_dir = ARGV[1] || 'data'

FileUtils.mkdir_p(out_dir)

output_index = File.open(File.join(out_dir, IpToAsn::DB_MAIN), 'w')
country_index = File.open(File.join(out_dir, IpToAsn::DB_COUNTRIES), 'w')
asn_index = File.open(File.join(out_dir, IpToAsn::DB_ASNAMES), 'w')

countries = {}
asnames = []
seen_asnames = {}
asname_offset = 0

File.foreach(input_file) do |line|
  range_start, range_end, asnumber, country, asname = *line.strip.split("\t")

  country = 'XX' if country.length != 2
  unless seen_asnames.include? asnumber
    seen_asnames[asnumber] = asname_offset
    asname_offset += asname.length
    asnames << asname
  end

  countries[country] = true

  as = IpToAsn::AsEntry.new(
    range_start,
    range_end,
    asnumber.to_i,
    countries.keys.index(country),
    seen_asnames[asnumber],
    asname.length
  )
  output_index.write(as.serialize)
end

output_index.close

country_index.write(countries.keys.join(''))
country_index.close

asn_index.write(asnames.join(''))
asn_index.close
