require 'spec_helper'

describe ItunesReceiptDecoder::Decode do
  before :all do
    ItunesReceiptDecoder::Config.certificate_path =
      File.expand_path('../../../AppleIncRootCertificate.cer', __FILE__)
  end

  let(:receipt_data) do
    File.read(File.expand_path('../../fixtures/receipt.txt', __FILE__)).chomp
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

    it 'returns an object' do
      ap subject
    end
  end
end
