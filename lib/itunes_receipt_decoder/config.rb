##
# ItunesReceiptDecoder
module ItunesReceiptDecoder
  ##
  # ItunesReceiptDecoder::Config
  class Config
    class << self
      ##
      # Set this to the path of the AppleIncRootCertificate.cer file
      attr_accessor :certificate_path
    end

    ##
    # Returns the OpenSSL X509 Store for the certificate
    def self.certificate_store
      return @certificate_store if @certificate_store
      @certificate_store = OpenSSL::X509::Store.new
      @certificate_store.add_cert(certificate)
    end

    ##
    # returns the OpenSSL X509 Certificate
    def self.certificate
      @certificate ||= OpenSSL::X509::Certificate.new(
        File.read(certificate_path)
      )
    end
  end
end
