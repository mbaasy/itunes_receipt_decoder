##
# ItunesReceiptDecoder
module ItunesReceiptDecoder
  ##
  # ItunesReceiptDecoder::Decode
  module Decode
    ##
    # ItunesReceiptDecoder::Decode::TransactionReceipt
    class TransactionReceipt < Base
      def decode
        @receipt ||= purchase_info
        self
      end

      def style
        :transaction
      end

      def environment
        payload['environment']
      end

      private

      def purchase_info
        contents = Base64.strict_decode64(payload['purchase-info'])
        result = parse_plist(contents)
        result.keys.each do |key|
          new_key = key.tr('-', '_').to_sym
          result[new_key] = result.delete(key)
        end
        result
      end

      def payload
        @payload ||= parse_plist(raw_receipt)
      end

      def parse_plist(contents)
        plist = CFPropertyList::List.new(data: contents)
        CFPropertyList.native_types(plist.value)
      end
    end
  end
end
