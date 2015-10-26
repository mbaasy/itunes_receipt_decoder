require 'base64'
require 'openssl'
require 'cfpropertylist'
require 'itunes_receipt_decoder/version'
require 'itunes_receipt_decoder/config'
require 'itunes_receipt_decoder/decode/base'
require 'itunes_receipt_decoder/decode/transaction_receipt'
require 'itunes_receipt_decoder/decode/unified_receipt'

##
# ItunesReceiptDecoder
module ItunesReceiptDecoder
  ##
  # Initializes either ItunesReceiptDecoder::Decode::Transaction or
  # ItunesReceiptDecoder::Decode::Unified with the base64 encoded receipt
  # ==== Arguments
  #
  # * +receipt_data+ - the base64 encoded receipt
  def self.new(receipt_data)
    raw_receipt = Base64.strict_decode64(receipt_data)
    if /^\{*+\}$/ =~ raw_receipt
      Decode::TransactionReceipt.new(raw_receipt)
    else
      Decode::UnifiedReceipt.new(raw_receipt)
    end
  end
end
