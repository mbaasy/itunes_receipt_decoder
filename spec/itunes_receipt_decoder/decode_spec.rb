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

    it 'includes the application_version' do
      expect(subject[:application_version]).to eq('1')
    end

    it 'includes the original_application_version' do
      expect(subject[:original_application_version]).to eq('1.0')
    end

    it 'includes the environment' do
      expect(subject[:environment]).to eq('ProductionSandbox')
    end

    it 'includes the bundle_id' do
      expect(subject[:bundle_id]).to eq('com.mbaasy.ios.demo')
    end

    it 'includes the creation_date' do
      expect(subject[:creation_date]).to eq(Time.parse('2015-08-13T07:50:46Z'))
    end

    it 'includes 7 transactions' do
      expect(subject[:in_app].size).to eq(7)
    end

    context 'in transaction 0' do
      it 'includes nil for expires_date' do
        expect(subject[:in_app][0][:expires_date]).to be_nil
      end

      it 'includes nil for cancellation_date' do
        expect(subject[:in_app][0][:cancellation_date]).to be_nil
      end

      it 'includes the quantity' do
        expect(subject[:in_app][0][:quantity]).to eq(1)
      end

      it 'includes the product_id' do
        expect(subject[:in_app][0][:product_id]).to eq('consumable')
      end

      it 'includes the transaction_id' do
        expect(subject[:in_app][0][:transaction_id]).to eq('1000000166865231')
      end

      it 'includes the original_transaction_id' do
        expect(subject[:in_app][0][:original_transaction_id])
          .to eq('1000000166865231')
      end
    end
  end
end
