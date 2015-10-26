##
# ItunesReceiptDecoder
module ItunesReceiptDecoder
  ##
  # ItunesReceiptDecoder::Decode
  module Decode
    ##
    # ItunesReceiptDecoder::Decode::Base
    class Base
      attr_reader :raw_receipt

      def initialize(raw_receipt)
        @raw_receipt = raw_receipt
      end

      def receipt
        decode && @receipt
      end

      def production?
        environment == 'Production'
      end

      def sandbox?
        !production?
      end
    end
  end
end
