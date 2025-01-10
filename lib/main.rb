require 'ipaddr'
require_relative 'index.rb'

class IpToAsn
  def initialize
    @index = chunk_index
    @cache = {}
    @chunk_dir = "./chunks"
    @reserved_ranges = {
      IPAddr.new('10.0.0.0/8') => 'RFC1918 Private',
      IPAddr.new('172.16.0.0/12') => 'RFC1918 Private',
      IPAddr.new('192.168.0.0/16') => 'RFC1918 Private',
      IPAddr.new('0.0.0.0/8') => 'Current Network',
      IPAddr.new('127.0.0.0/8') => 'Loopback',
      IPAddr.new('169.254.0.0/16') => 'Link Local',
    }
  end

  def lookup(ip_str)
    reserved_range_name = find_range(
      ranges: @reserved_ranges,
      ip_address: ip_str
    )

    return { as_number: 0, country_code: 'XX', as_name: reserved_range_name } unless reserved_range_name.nil?

    chunk_name = binary_search(@index, ip_str).first
    return nil if chunk_name.nil?

    if @cache[chunk_name].nil?
      require_relative "#{@chunk_dir}/#{chunk_name}.rb"
      @cache[chunk_name] = send "chunk_#{chunk_name}".to_sym
    end

    result = binary_search(@cache[chunk_name], ip_str)
    return nil if result.empty?

    { as_number: result[0], country_code: result[1], as_name: result[2] }
  end

  private
  def find_range(ranges:, ip_address:)
    ranges.filter_map { |k, v|
      v if k.include? ip_address
    }.first
  end

  def binary_search(ranges, ip_str)
    ip_int = IPAddr.new(ip_str).to_i
    low = 0
    high = ranges.length - 1

    while low <= high
      mid = (low + high) / 2
      range_start, range_end, *data = *ranges[mid]

      if range_start <= ip_int && ip_int <= range_end
        return data
      elsif ip_int < range_start
        high = mid - 1
      else
        low = mid + 1
      end
    end

    []
  end
end
