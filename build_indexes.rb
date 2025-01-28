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
    country_code = fields[3].to_sym
    name = fields[4]

    result << [range_start, range_end, asn, country_code, name]
  end

  result
end

def build_as_index(parsed_contents)
  as_index = {}
  parsed_contents.each do |line|
    _, _, as_number, _, as_name = *line
    as_index[as_number] = as_name
  end

  as_index
end

index = []
Dir.glob(File.join('tmp/', 'chunk_*')) do |file|
  puts "Processing file: #{file}"
  tsv_file = parse_tsv_file(file)
  filename = File.basename(file)

  ip_address_min = tsv_file[0][0]
  ip_address_max = tsv_file[-1][1]

  handle = File.open("lib/chunks/#{filename}.rb", 'w')
  chunk_as_index = build_as_index(tsv_file)
  handle.write("def chunk_#{filename}()\n")
  handle.write("  c = #{chunk_as_index.inspect}\n")
  handle.write("  m = #{ip_address_min}\n")
  handle.write("  [\n")
  tsv_file.each do |line|
    handle.write("[m+#{line[0] - ip_address_min},m+#{line[1] - ip_address_min},#{line[2]},#{line[3].inspect},c[#{line[2]}]],")
  end

  handle.write("  ]\n")
  handle.write('end')
  handle.close

  index << [ip_address_min, ip_address_max, filename.to_s]
end

index_source = "def chunk_index()\n\t#{index.inspect}\nend\n"
File.write('lib/index.rb', index_source)
