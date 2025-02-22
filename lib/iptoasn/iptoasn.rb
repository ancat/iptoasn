# frozen_string_literal: true

module IpToAsn
  class Lookup
    def initialize(db_ip2asn: nil, db_country: nil, db_names: nil) # rubocop:disable Metrics/AbcSize
      if db_ip2asn.nil? || db_country.nil? || db_names.nil?
        require 'iptoasn/data'
        db_ip2asn = IpToAsn::Data.ip2asn
        db_country = IpToAsn::Data.countries
        db_names = IpToAsn::Data.asnames
      end

      @db_ip2asn = File.open(db_ip2asn, 'r')
      @db_country = File.read(db_country)
      @db_names = File.open(db_names, 'r')

      @reserved_ranges = {
        IPAddr.new('10.0.0.0/8') => 'RFC1918 Private',
        IPAddr.new('172.16.0.0/12') => 'RFC1918 Private',
        IPAddr.new('192.168.0.0/16') => 'RFC1918 Private',
        IPAddr.new('0.0.0.0/8') => 'Current Network',
        IPAddr.new('127.0.0.0/8') => 'Loopback',
        IPAddr.new('169.254.0.0/16') => 'Link Local'
      }

      @entry_size = IpToAsn::AsEntry.size
      @db_ip2asn.seek(0, IO::SEEK_END)
      @db_total_entries = @db_ip2asn.size / @entry_size
      @db_ip2asn.seek(0)
      @mutex = Mutex.new
    end

    def ip_to_int(ip)
      ip.split('.').map(&:to_i).inject(0) { |acc, num| (acc << 8) | num }
    end

    def as_name(name_offset, name_length)
      @db_names.seek(name_offset, IO::SEEK_SET)
      @db_names.read(name_length)
    end

    def country(country_index)
      @db_country[country_index * 2, 2]
    end

    def lookup(ip)
      reserved_range_name = find_range(
        ranges: @reserved_ranges,
        ip_address: ip
      )

      return { as_number: 0, country_code: 'XX', as_name: reserved_range_name } unless reserved_range_name.nil?

      @mutex.synchronize do
        search_db(ip)
      end
    end

    def search_db(ip) # rubocop:disable Metrics/AbcSize
      ip_int = ip_to_int(ip)

      left = 0
      right = @db_total_entries - 1

      while left <= right
        mid = (left + right) / 2
        @db_ip2asn.seek(mid * @entry_size, IO::SEEK_SET)
        data = @db_ip2asn.read(@entry_size)
        break if data.nil? || data.size < @entry_size

        entry = IpToAsn::AsEntry.deserialize(data)

        if entry.range_start.to_i <= ip_int && ip_int <= entry.range_end.to_i
          return {
            as_number: entry.number,
            as_name: as_name(entry.name_offset, entry.name_length),
            country_code: country(entry.country)
          }
        elsif ip_int < entry.range_start.to_i
          right = mid - 1
        else
          left = mid + 1
        end
      end
    end

    def find_range(ranges:, ip_address:)
      ranges.filter_map do |k, v|
        v if k.include? ip_address
      end.first
    end
  end
end
