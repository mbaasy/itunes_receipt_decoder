##
# ItunesReceiptDecoder
module ItunesReceiptDecoder
  ##
  # ItunesReceiptDecoder::Config
  class Config
    class << self
      attr_accessor :certificate_path
    end

    def self.certificate_store
      return @certificate_store if @certificate_store
      @certificate_store = OpenSSL::X509::Store.new
      @certificate_store.add_cert(certificate)
    end

    def self.certificate
      @certificate ||= OpenSSL::X509::Certificate.new(
        File.read(certificate_path)
      )
    end
  end
end
