# frozen_string_literal: true

require 'rspec'
require_relative '../lib/main'

RSpec.describe IpToAsn do
  subject(:ip_to_asn) { described_class.new }

  describe '#lookup' do
    context 'when IP is provided' do
      before do
        subject.instance_eval do
          # fake chunk index
          # middle chunk contains info for IP range consisting of
          # 1.3.3.6 to 1.3.3.8
          @index = [
            [0, 16_974_597, 'a'],
            [16_974_598, 16_974_601, 'target'],
            [16_974_602, 4_294_967_295, 'c']
          ]

          # fake chunk
          def chunk_target
            [[
              16_974_598, 16_974_601, 1337, 'OK', 'Test AS'
            ]]
          end
        end
      end

      it 'returns information if the IP is in a reserved range' do
        allow(ip_to_asn).to receive(:require_relative)
        result = ip_to_asn.lookup('192.168.1.1')

        expect(result).to eq({
                               as_number: 0,
                               country_code: 'XX',
                               as_name: 'RFC1918 Private'
                             })
        expect(ip_to_asn).not_to have_received(:require_relative)
      end

      it 'loads a chunk if the IP is not in a reserved range' do
        allow(ip_to_asn).to receive(:require_relative)
        result = ip_to_asn.lookup('1.3.3.7')

        expect(result).to eq({
                               as_number: 1337,
                               country_code: 'OK',
                               as_name: 'Test AS'
                             })
        expect(ip_to_asn).to have_received(:require_relative).with('./chunks/target.rb')
      end

      it 'returns the ip info but loads the chunk just once' do
        allow(ip_to_asn).to receive(:require_relative)
        ip_to_asn.lookup('1.3.3.7')
        result = ip_to_asn.lookup('1.3.3.7')

        expect(result).to eq({
                               as_number: 1337,
                               country_code: 'OK',
                               as_name: 'Test AS'
                             })
        expect(ip_to_asn).to have_received(:require_relative).with('./chunks/target.rb').once
      end
    end
  end
end
