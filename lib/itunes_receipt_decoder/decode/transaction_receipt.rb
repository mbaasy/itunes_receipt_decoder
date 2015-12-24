require 'openssl'
require 'cfpropertylist'
require 'itunes_receipt_decoder/decode/base'

##
# ItunesReceiptDecoder
module ItunesReceiptDecoder
  ##
  # ItunesReceiptDecoder::Decode
  module Decode
    ##
    # ItunesReceiptDecoder::Decode::TransactionReceipt
    class TransactionReceipt < Base
      PUBLIC_KEY = OpenSSL::PKey::RSA.new <<-PUBLIC_KEY
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApLyvMpRDPgu8N4fNY4ny
zNm+IE1atP6HZ9Ka3hpUnaLz34fkTMuTEXigMI80QcHTvmZtR2yYuOx61cndpeTq
xnD0NdCR97PYChGZqzpiOr179FZP258kk1FQfCDVZk1m8xikE5YiFv0xp/Q5Zpv7
YmlcS5+UqEvo7FtkWhh5ihZ1Y0KkSdmMM96te9Y5BPTinQppjOtLEihLNEgHmw5Z
+R9isAOfNrhOo9N1WdTzOgXKxTM7+MAGCQiT2+dNvxHzUiylFjUV80ECzQLR/PX4
xYS9Y2qG1raZ9oauX/0D1CiKWl2vvGV00fcaw5II9BytaegCTA6VFQe8vmpvwbOt
oQIDAQAB
-----END PUBLIC KEY-----
PUBLIC_KEY

      def style
        :transaction
      end

      def signature_valid?
        version, sig, cert_length, cert =
          payload.fetch('signature').unpack('m').first.unpack('c a128 N a*')
        return false unless
          version == 2 &&
          sig.size == 128 &&
          cert.size == cert_length &&
          (cert = OpenSSL::X509::Certificate.new(cert)) &&
          cert.verify(PUBLIC_KEY)
        data = [version, purchase_info].pack('ca*')
        cert.public_key.verify(OpenSSL::Digest::SHA1.new, sig, data)
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
