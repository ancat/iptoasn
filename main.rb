require 'ipaddr'
require_relative 'index.rb'

class IpToAsn
  def initialize
    @index = chunk_index
    @cache = {}
    @chunk_dir = "./chunks"
  end

  def lookup(ip_str)
    chunk_name = binary_search(@index, ip_str).first
    return nil if chunk_name.nil?

    if @cache[chunk_name].nil?
      require_relative "#{@chunk_dir}/#{chunk_name}.rb"
      @cache[chunk_name] = send "chunk_#{chunk_name}".to_sym
    end

    result = binary_search(@cache[chunk_name], ip_str)
    nil if result.empty?

    { as_number: result[0], country_code: result[1], as_name: result[2] }
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
