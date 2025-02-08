# frozen_string_literal: true

module IpToAsn
  DB_MAIN = 'ip2asn.dat'
  DB_COUNTRIES = 'countries.dat'
  DB_ASNAMES = 'asnames.dat'
end

module IpToAsn
  class AsEntry
    attr_accessor :range_start, :range_end, :number, :country, :name_offset, :name_length

    def initialize(range_start, range_end, number, country, name_offset, name_length) # rubocop:disable Metrics/ParameterLists
      @range_start = ip_to_int(range_start)
      @range_end = ip_to_int(range_end)
      @number = number
      @country = country
      @name_offset = name_offset
      @name_length = name_length
    end

    def serialize
      [@range_start, @range_end, @number, @country, @name_offset, @name_length].pack('L L L C L C')
    end

    def self.deserialize(binary_data)
      range_start, range_end, number, country, name_offset, name_length = binary_data.unpack('L L L C L C')
      new(int_to_ip(range_start), int_to_ip(range_end), number, country, name_offset, name_length)
    end

    def self.size
      18 # L + L + L + C + L + C = 18 bytes
    end

    def self.int_to_ip(int)
      [24, 16, 8, 0].map { |b| (int >> b) & 0xFF }.join('.')
    end

    private

    def ip_to_int(ip)
      ip.split('.').map(&:to_i).inject(0) { |acc, num| (acc << 8) | num }
    end
  end
end
