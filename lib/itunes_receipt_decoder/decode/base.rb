##
# ItunesReceiptDecoder
module ItunesReceiptDecoder
  ##
  # ItunesReceiptDecoder::Decode
  module Decode
    ##
    # ItunesReceiptDecoder::Decode::Base
    class Base
      ##
      # The raw receipt, i.e. not base64 encoded
      attr_reader :raw_receipt, :receipt, :options, :style

      ##
      # Initializes with a raw (base64 decoded receipt)
      #
      # ==== Arguments
      #
      # * +raw_receipt+ - the raw receipt, i.e. not base64 encoded
      def initialize(raw_receipt, options = {})
        @raw_receipt = raw_receipt
        @options = options
        decode
      end
    end
  end
end
