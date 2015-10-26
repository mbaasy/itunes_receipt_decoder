require 'spec_helper'

describe ItunesReceiptDecoder::DecodeIos6 do
  before :all do
    ItunesReceiptDecoder::Config.certificate_path =
      File.expand_path('../../../AppleIncRootCertificate.cer', __FILE__)
  end

  let(:receipt_data) do
    File.read(File.expand_path('../../fixtures/ios6_receipt.txt', __FILE__)).chomp
  end

  describe '.new' do
    subject { described_class.new(receipt_data) }

    it 'assigns @receipt_data' do
      expect(subject.receipt_data).to eq(Base64.strict_decode64(receipt_data))
    end
  end

  describe '#decode' do
    subject { instance.decode }
    let(:instance) { described_class.new(receipt_data) }

    let(:purchase_info) do
      {
        "app-item-id" => "473626161",
        "bid" => "com.company.productname",
        "bvrs" => "9788",
        "expires-date" => "1453546076041",
        "expires-date-formatted" => "2016-01-23 10:47:56 Etc/GMT",
        "expires-date-formatted-pst" => "2016-01-23 02:47:56 America/Los_Angeles",
        "item-id" => "649821550",
        "original-purchase-date" => "2015-10-23 09:47:57 Etc/GMT",
        "original-purchase-date-ms" => "1445593677855",
        "original-purchase-date-pst" => "2015-10-23 02:47:57 America/Los_Angeles",
        "original-transaction-id" => "30000181531396",
        "product-id" => "SPA_3M",
        "purchase-date" => "2015-10-23 09:47:56 Etc/GMT",
        "purchase-date-ms" => "1445593676041",
        "purchase-date-pst" => "2015-10-23 02:47:56 America/Los_Angeles",
        "quantity" => "1",
        "transaction-id" => "30000181531396",
        "unique-identifier" => "ea7967baf4261663daa00c50d59410b01f442d83",
        "unique-vendor-identifier" => "3421ADB4-7430-4C40-B396-0859EC884FEC",
        "version-external-identifier" => "813008003",
        "web-order-line-item-id" => "30000021380371"
      }
    end

    let(:expected) do
      {
        "signature" => "Y29tcGFueV9zaWduYXR1cmU=",
        "purchase-info" => purchase_info,
        "pod"=>"3",
        "signing-status"=>"0"
      }
    end

    it 'has the expected receipt values' do
      expect(subject).to eql(expected)
    end

  end
end
