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
      INTERMEDIATE_CERT = OpenSSL::X509::Certificate.new <<-CERTIFICATE
-----BEGIN CERTIFICATE-----
MIIECzCCAvOgAwIBAgIBGjANBgkqhkiG9w0BAQUFADBiMQswCQYDVQQGEwJVUzET
MBEGA1UEChMKQXBwbGUgSW5jLjEmMCQGA1UECxMdQXBwbGUgQ2VydGlmaWNhdGlv
biBBdXRob3JpdHkxFjAUBgNVBAMTDUFwcGxlIFJvb3QgQ0EwHhcNMDkwNTE5MTgz
MTMwWhcNMTYwNTE4MTgzMTMwWjB/MQswCQYDVQQGEwJVUzETMBEGA1UECgwKQXBw
bGUgSW5jLjEmMCQGA1UECwwdQXBwbGUgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkx
MzAxBgNVBAMMKkFwcGxlIGlUdW5lcyBTdG9yZSBDZXJ0aWZpY2F0aW9uIEF1dGhv
cml0eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKS8rzKUQz4LvDeH
zWOJ8szZviBNWrT+h2fSmt4aVJ2i89+H5EzLkxF4oDCPNEHB075mbUdsmLjsetXJ
3aXk6sZw9DXQkfez2AoRmas6Yjq9e/RWT9ufJJNRUHwg1WZNZvMYpBOWIhb9Maf0
OWab+2JpXEuflKhL6OxbZFoYeYoWdWNCpEnZjDPerXvWOQT04p0KaYzrSxIoSzRI
B5sOWfkfYrADnza4TqPTdVnU8zoFysUzO/jABgkIk9vnTb8R81IspRY1FfNBAs0C
0fz1+MWEvWNqhta2mfaGrl/9A9Qoilpdr7xldNH3GsOSCPQcrWnoAkwOlRUHvL5q
b8GzraECAwEAAaOBrjCBqzAOBgNVHQ8BAf8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB
/zAdBgNVHQ4EFgQUNh3o4p2C0gEYtTJrDtdDC5FYQzowHwYDVR0jBBgwFoAUK9Bp
R5R2Cf70a40uQKb3R01/CF4wNgYDVR0fBC8wLTAroCmgJ4YlaHR0cDovL3d3dy5h
cHBsZS5jb20vYXBwbGVjYS9yb290LmNybDAQBgoqhkiG92NkBgICBAIFADANBgkq
hkiG9w0BAQUFAAOCAQEAdaaQ5pqn22VwpgmTbwjfLNvpKI1AG1deoOr07BNlG3FK
TdyASE/y5an7hWy3Hp3b9BhIEHkX6sM9h9i0eW0UUK3Svz1O/A3ixQOUdYBzTaWh
kf4c3hUXrIlxKm8PZwrTnDChaPvPcBfK2UD8+Bu/zrDErvRKLamZhwZCCYYiaoRA
OfS7rFYY95ocAYFcjG5B8l0ZLBccSUbZHH6TEhPIZ5nC6oPjoowOuDsq3xy/S4tv
Grjul2dK2Kuvi6TaXIceILjF87HEmKI3+J7GmmulrfZ4lg6CjwRGHLKl/ZowUSj9
UgQVA9U8rf72eODqNe9ltSF226Tvy3LvVGsBDcfdGg==
-----END CERTIFICATE-----
CERTIFICATE

      def initialize(raw_receipt, options = {})
        @style = :transaction
        super
      end

      def signature_valid?
        version, sig, cert_length, cert =
          payload.fetch('signature').unpack('m').first.unpack('c a128 N a*')
        return false unless
          version == 2 &&
          sig.size == 128 &&
          cert.size == cert_length &&
          (cert = OpenSSL::X509::Certificate.new(cert)) &&
          cert.verify(INTERMEDIATE_CERT.public_key)
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
