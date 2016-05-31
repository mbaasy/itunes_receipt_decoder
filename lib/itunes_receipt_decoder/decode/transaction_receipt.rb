require 'openssl'
require 'cfpropertylist'
require 'itunes_receipt_decoder/decode/base'
require 'itunes_receipt_decoder/public_key'

##
# ItunesReceiptDecoder
module ItunesReceiptDecoder
  ##
  # ItunesReceiptDecoder::Decode
  module Decode
    ##
    # ItunesReceiptDecoder::Decode::TransactionReceipt
    class TransactionReceipt < Base
      ##
      # ItunesReceiptDecoder::Decode::TransactionReceipt::SignatureValidation
      class SignatureValidation
        attr_reader :blob, :purchase_info
        attr_accessor :version, :signature, :raw_cert, :cert_length

        def initialize(blob, purchase_info)
          @blob = blob
          @purchase_info = purchase_info
        end

        def valid?
          unpack &&
            raw_cert.size == cert_length &&
            cert &&
            cert.verify(public_key) &&
            verify
        end

        private

        def verify
          data = [version, purchase_info].pack('ca*')
          cert.public_key.verify(OpenSSL::Digest::SHA1.new, signature, data)
        end

        def cert
          @cert ||= OpenSSL::X509::Certificate.new(raw_cert)
        rescue OpenSSL::X509::CertificateError => _e
          false
        end

        def unpack
          self.version, following = blob.unpack('c a*')
          return false unless [2, 3].include?(version)
          arrangement =
            case version
            when 2 then 'a128 N a*'
            when 3 then 'a256 N a*'
            end
          self.signature, self.cert_length, self.raw_cert =
            following.unpack(arrangement)
        end

        def public_key
          @public_key ||=
            case version
            when 2 then PublicKey::V2
            when 3 then PublicKey::V3
            end
        end
      end

      def style
        :transaction
      end

      def signature_valid?
        SignatureValidation.new(signature, purchase_info).valid?
      end

      private

      def decode
        @receipt = parse_purchase_info
        @environment =
          if payload.fetch('environment', 'Production') == 'Production'
            :production
          else
            :sandbox
          end
      end

      def parse_purchase_info
        result = parse_plist(purchase_info)
        result.keys.each do |key|
          new_key = key.tr('-', '_').to_sym
          result[new_key] = result.delete(key)
        end
        result
      end

      def purchase_info
        @purchase_info ||= payload.fetch('purchase-info').unpack('m').first
      end

      def signature
        @signature ||= payload.fetch('signature').unpack('m').first
      end

      def payload
        @payload ||= parse_plist(raw_receipt)
      end

      def parse_plist(contents)
        plist = CFPropertyList::List.new(data: contents)
        hash = CFPropertyList.native_types(plist.value)
        raise DecodingError, 'hash not found in plist' unless hash.is_a?(Hash)
        hash
      rescue CFPlistError => e
        raise DecodingError, e.message
      end
    end
  end
end
