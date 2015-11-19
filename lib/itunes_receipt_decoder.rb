require 'time'
require 'base64'
require 'openssl'
require 'cfpropertylist'
require 'itunes_receipt_decoder/version'
require 'itunes_receipt_decoder/decode/base'
require 'itunes_receipt_decoder/decode/transaction_receipt'
require 'itunes_receipt_decoder/decode/unified_receipt'

##
# ItunesReceiptDecoder
module ItunesReceiptDecoder
  class DecodingError < StandardError; end

  ##
  # Initializes either ItunesReceiptDecoder::Decode::Transaction or
  # ItunesReceiptDecoder::Decode::Unified with the base64 encoded receipt
  # ==== Arguments
  #
  # * +receipt_data+ - the base64 encoded receipt
  # * +options+ - optional arguments
  def self.new(receipt_data, options = {})
    raw_receipt = Base64.strict_decode64(receipt_data)
  rescue ArgumentError => e
    raise DecodingError, e.message
  else
    if /^\{*+\}$/ =~ raw_receipt
      Decode::TransactionReceipt.new(raw_receipt, options)
    else
      Decode::UnifiedReceipt.new(raw_receipt, options)
    end
  end
end
