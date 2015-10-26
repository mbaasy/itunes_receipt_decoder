module ItunesReceiptDecoder
  class DecodeIos6
    attr_accessor :receipt_data
    attr_accessor :receipt

    def initialize(receipt_data)
      @receipt_data = Base64.strict_decode64(receipt_data)
      @parsed_receipt_data = {}
      @receipt = {}
    end

    def decode
      self.receipt = parsed_receipt_data
    end

    private

    def parsed_receipt_data
      @parsed_receipt_data = parse_serialized_ios_hash(@receipt_data)

      @parsed_receipt_data.merge('purchase-info' => purchase_info)
    end

    def purchase_info
      purchase_info_data = @parsed_receipt_data["purchase-info"]
      purchase_info = Base64.strict_decode64(purchase_info_data)
      parse_serialized_ios_hash(purchase_info)
    end

    def parse_serialized_ios_hash(string)
      hash = string.gsub(/^\{[\s]+/, '')
                   .gsub(/[\s]+\}$/, '')
                   .gsub(/\"/, '')
                   .gsub("\n\t", '')
                   .split(";")
                   .map { |string| string.split(" = ") }

      Hash[*hash.flatten].with_indifferent_access
    end
  end
end
