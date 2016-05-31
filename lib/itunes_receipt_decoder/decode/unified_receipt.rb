require 'time'
require 'openssl'
require 'itunes_receipt_decoder/decode/base'
require 'itunes_receipt_decoder/public_key'

##
# ItunesReceiptDecoder
module ItunesReceiptDecoder
  ##
  # ItunesReceiptDecoder::Decode
  module Decode
    ##
    # ItunesReceiptDecoder::Decode::UnifiedReceipt
    class UnifiedReceipt < Base
      ##
      # ASN.1 Field types
      #
      # See https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW1
      RECEIPT_FIELDS = {
        0 => :environment,
        2 => :bundle_id,
        3 => :application_version,
        4 => :opaque_value,
        5 => :sha1_hash,
        12 => :creation_date,
        17 => :in_app,
        19 => :original_application_version,
        21 => :expiration_date,
        1701 => :quantity,
        1702 => :product_id,
        1703 => :transaction_id,
        1705 => :original_transaction_id,
        1704 => :purchase_date,
        1706 => :original_purchase_date,
        1708 => :expires_date,
        1712 => :cancellation_date,
        1711 => :web_order_line_item_id
      }.freeze

      TIMESTAMP_FIELDS = %i(creation_date expiration_date purchase_date
                            original_purchase_date expires_date
                            cancellation_date).freeze

      def style
        :unified
      end

      def uuid_valid?(uuid)
        digest = OpenSSL::Digest::SHA1.new
        digest << uuid.scan(/[0-9A-F]{2}/).map(&:hex).pack('c*')
        digest << @receipt[:opaque_value]
        digest << @raw_bundle_id
        digest.digest == @receipt[:sha1_hash]
      end

      def signature_valid?
        serial = pkcs7.signers.first.serial.to_i
        cert = pkcs7.certificates.find { |c| c.serial.to_i == serial }
        cert && cert.verify(PublicKey::V3)
      end

      private

      def decode
        @receipt = parse_app_receipt_fields(payload.value)
        @environment =
          if @receipt.fetch(:environment, 'Production') == 'Production'
            :production
          else
            :sandbox
          end
      end

      def parse_app_receipt_fields(fields)
        result = {}
        fields.each do |seq|
          type, _version, value = seq.value.map(&:value)
          next unless (field = RECEIPT_FIELDS[type.to_i])
          if %i(opaque_value sha1_hash).include?(field)
            result[field] = value
          else
            @raw_bundle_id = value if field == :bundle_id
            build_result(result, field, value)
          end
        end
        result
      end

      def build_result(result, field, value)
        value = OpenSSL::ASN1.decode(value).value
        case field
        when :in_app
          (result[field] ||= []).push(parse_app_receipt_fields(value))
        when *timestamp_fields
          result.merge! expand_timestamp(field, value) unless value.empty?
        else
          result[field] = value.class == OpenSSL::BN ? value.to_i : value.to_s
        end
      end

      def timestamp_fields
        options[:expand_timestamps] && TIMESTAMP_FIELDS
      end

      def expand_timestamp(field, value)
        time = Time.parse(value).utc
        {
          field => time.strftime('%F %T') + ' Etc/GMT',
          "#{field}_ms".to_sym => (time.to_i * 1000).to_s,
          "#{field}_pst".to_sym => (time + Time.zone_offset('PST'))
            .strftime('%F %T') + ' America/Los_Angeles'
        }
      end

      def payload
        verify && OpenSSL::ASN1.decode(pkcs7.data)
      rescue OpenSSL::ASN1::ASN1Error => e
        raise DecodingError, e.message
      end

      def verify
        pkcs7.verify [], OpenSSL::X509::Store.new, nil, OpenSSL::PKCS7::NOVERIFY
      end

      def pkcs7
        @pkcs7 ||= OpenSSL::PKCS7.new(raw_receipt)
      rescue ArgumentError => e
        raise DecodingError, e.message
      end
    end
  end
end
