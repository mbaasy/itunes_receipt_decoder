##
# ItunesReceiptDecoder
module ItunesReceiptDecoder
  ##
  # ItunesReceiptDecoder::Decode
  module Decode
    ##
    # ItunesReceiptDecoder::Decode::TransactionReceipt
    class TransactionReceipt < Base
      def initialize(raw_receipt, options = {})
        @style = :transaction
        super
      end

      private

      def decode
        @receipt = parse_purchase_info
        if payload.fetch('environment', 'Production') == 'Production'
          @environment = :production
        else
          @environment = :sandbox
        end
      end

      def parse_purchase_info
        purchase_info.keys.each do |key|
          new_key = key.tr('-', '_').to_sym
          purchase_info[new_key] = purchase_info.delete(key)
        end
        purchase_info
      end

      def purchase_info
        @purchase_info ||=
          parse_plist(payload.fetch('purchase-info').unpack('m').first)
      end

      def payload
        @payload ||= parse_plist(raw_receipt)
      end

      def parse_plist(contents)
        plist = CFPropertyList::List.new(data: contents)
        hash = CFPropertyList.native_types(plist.value)
        fail DecodingError, 'hash not found in plist' unless hash.is_a?(Hash)
        hash
      rescue CFPlistError => e
        raise DecodingError, e.message
      end
    end
  end
end
