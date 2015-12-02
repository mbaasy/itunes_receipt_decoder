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
      rescue KeyError => e
        raise DecodingError, e.message
      end

      def parse_purchase_info
        purchase_info.keys.each do |key|
          new_key = key.tr('-', '_').to_sym
          purchase_info[new_key] = purchase_info.delete(key)
        end
        purchase_info
      end

      def purchase_info
        return @purchase_info if @purchase_info
        contents = Base64.decode64 payload.fetch('purchase-info')
      rescue KeyError => e
        raise DecodingError, e.message
      rescue ArgumentError => e
        raise DecodingError, e.message
      else
        @purchase_info = parse_plist(contents)
      end

      def payload
        @payload ||= parse_plist(raw_receipt)
      end

      def parse_plist(contents)
        plist = CFPropertyList::List.new(data: contents)
        hash = CFPropertyList.native_types(plist.value)
        fail DecodingError, 'hash not found in plist' unless hash.is_a?(Hash)
        hash
      end
    end
  end
end
