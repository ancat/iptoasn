# frozen_string_literal: true

require 'ipaddr'

def ip_to_int(ip)
  IPAddr.new(ip).to_i
end

def parse_tsv_file(file_name)
  result = []
  File.foreach(file_name).with_index do |line, _index|
    fields = line.strip.split("\t")
    range_start = ip_to_int(fields[0])
    range_end = ip_to_int(fields[1])
    asn = fields[2].to_i
    country_code = fields[3]
    name = fields[4]

    result << [range_start, range_end, asn, country_code, name]
  end

  result
end

index = []
Dir.glob(File.join('tmp/', 'chunk_*')) do |file|
  puts "Processing file: #{file}"
  tsv_file = parse_tsv_file(file)
  filename = File.basename(file)

  ip_address_min = tsv_file[0][0]
  ip_address_max = tsv_file[-1][1]

  chunk_source = "def chunk_#{filename}()\n\t#{tsv_file.inspect}\nend\n"
  File.write("chunks/#{filename}.rb", chunk_source)

  index << [ip_address_min, ip_address_max, filename.to_s]
end

index_source = "def chunk_index()\n\t#{index.inspect}\nend\n"
File.write('index.rb', index_source)
