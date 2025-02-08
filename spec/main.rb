# frozen_string_literal: true

require 'rspec'
require_relative '../lib/iptoasn'

RSpec.describe IpToAsn::Lookup do
  subject(:ip_to_asn) { described_class.new }

  describe '#lookup' do
    context 'when IP is provided' do
      it 'returns information if the IP is in a reserved range' do
        result = ip_to_asn.lookup('192.168.1.1')

        expect(result).to eq({
                               as_number: 0,
                               country_code: 'XX',
                               as_name: 'RFC1918 Private'
                             })
      end

      it 'loads a chunk if the IP is not in a reserved range' do
        result = ip_to_asn.lookup('104.131.160.195')

        expect(result).to eq({
                               as_number: 14_061,
                               country_code: 'US',
                               as_name: 'DIGITALOCEAN-ASN'
                             })
      end
    end
  end
end
