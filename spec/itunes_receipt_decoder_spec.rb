require 'base64'
require 'spec_helper'

describe ItunesReceiptDecoder do
  let(:options) { {} }
  let(:instance) { described_class.new(receipt_data, options) }
  let(:receipt_data) { File.read(receipt_path).chomp }

  shared_context :transaction_production do
    let(:receipt_path) do
      File.expand_path('../examples/transaction_production.txt', __FILE__)
    end
  end

  shared_context :transaction_sandbox do
    let(:receipt_path) do
      File.expand_path('../examples/transaction_sandbox.txt', __FILE__)
    end
  end

  shared_context :unified_sandbox do
    let(:receipt_path) do
      File.expand_path('../examples/unified_sandbox.txt', __FILE__)
    end
  end

  shared_examples 'an_exception' do
    it 'raises a DecodingError' do
      expect { subject }.to raise_error(described_class::DecodingError)
    end
  end

  describe '.new' do
    subject { described_class.new(receipt_data) }

    context 'with a transaction style receipt' do
      include_context :transaction_sandbox

      it 'returns an instance of Decode::TransactionReceipt' do
        expect(subject).to be_a(described_class::Decode::TransactionReceipt)
      end

      context 'when purchase-info can\'t be parsed' do
        let(:receipt_data) do
          plist = CFPropertyList::List.new
          plist.value = CFPropertyList.guess(
            'signature' => 'foobar',
            'purchase-info' => 'foobar'
          )
          encoded = plist.to_str(CFPropertyList::List::FORMAT_PLAIN)
          Base64.strict_encode64(encoded)
        end

        it_behaves_like 'an_exception'
      end
    end

    context 'with a unified style receipt' do
      include_context :unified_sandbox

      it 'returns an instance of Decode::UnifiedReceipt' do
        expect(subject).to be_a(described_class::Decode::UnifiedReceipt)
      end

      context 'when OpenSSL::ASN1.decode fails' do
        before do
          pkcs7_double = instance_double 'OpenSSL::PKCS7',
                                         data: 'fake',
                                         verify: true
          allow(OpenSSL::PKCS7).to receive(:new).and_return(pkcs7_double)
        end

        it_behaves_like 'an_exception'
      end
    end

    context 'when the receipt_data is not base64 encoded' do
      let(:receipt_data) { '1' }

      it_behaves_like 'an_exception'
    end

    context 'when the receipt_data is not a transaction or unified receipt' do
      let(:receipt_data) { Base64.strict_encode64('foobar') }

      it_behaves_like 'an_exception'
    end
  end

  describe '#receipt' do
    subject { instance.receipt }

    context 'with a transaction style receipt' do
      include_context :transaction_sandbox

      it 'parses the purchase info' do
        expect(subject).to include(
          :original_purchase_date_pst, :original_transaction_id,
          :bvrs, :transaction_id, :quantity, :original_purchase_date_ms,
          :product_id, :item_id, :bid, :purchase_date_ms, :purchase_date,
          :purchase_date_pst, :original_purchase_date
        )
      end
    end

    context 'with a unified style receipt' do
      include_context :unified_sandbox

      it 'parses the receipt' do
        expect(subject).to include(
          :application_version, :original_application_version, :environment,
          :bundle_id, :creation_date, :in_app
        )
      end

      it 'includes 7 transactions in :in_app' do
        expect(subject[:in_app].size).to eq(7)
      end

      it 'parses the transactions' do
        subject[:in_app].each do |transaction|
          expect(transaction).to include(
            :expires_date, :cancellation_date, :purchase_date,
            :original_purchase_date, :quantity, :product_id, :transaction_id,
            :original_transaction_id, :web_order_line_item_id
          )
        end
      end

      context 'when expand_timestamps is true' do
        let(:options) { { expand_timestamps: true } }

        it 'parses the receipt' do
          expect(subject).to include(
            :application_version, :original_application_version, :environment,
            :bundle_id, :creation_date, :creation_date_ms, :creation_date_pst,
            :in_app
          )
        end

        it 'includes 7 transactions in :in_app' do
          expect(subject[:in_app].size).to eq(7)
        end

        it 'parses the transactions' do
          subject[:in_app].each do |transaction|
            if transaction[:web_order_line_item_id] > 0
              expect(transaction).to include(
                :expires_date, :expires_date_ms, :expires_date_pst,
                :purchase_date, :purchase_date_ms, :purchase_date_pst,
                :original_purchase_date, :original_purchase_date_ms,
                :original_purchase_date_pst, :quantity, :product_id,
                :transaction_id, :original_transaction_id,
                :web_order_line_item_id
              )
            else
              expect(transaction).to include(
                :purchase_date, :purchase_date_ms, :purchase_date_pst,
                :original_purchase_date, :original_purchase_date_ms,
                :original_purchase_date_pst, :quantity, :product_id,
                :transaction_id, :original_transaction_id,
                :web_order_line_item_id
              )
            end
          end
        end
      end
    end
  end

  describe '#environment' do
    subject { instance.environment }

    context 'with a transaction style receipt from sandbox' do
      include_context :transaction_sandbox

      it 'returns :sandbox' do
        expect(subject).to eq(:sandbox)
      end
    end

    context 'with a transaction style receipt from production' do
      include_context :transaction_production

      it 'returns :production' do
        expect(subject).to eq(:production)
      end
    end

    context 'with a unified style receipt from sandbox' do
      include_context :unified_sandbox

      it 'returns :sandbox' do
        expect(subject).to eq(:sandbox)
      end
    end

    context 'with a unified style receipt from production' do
      it 'returns :production'
    end
  end

  describe '#production?' do
    subject { instance.production? }

    context 'with a transaction style receipt from production' do
      include_context :transaction_production

      it 'returns true' do
        expect(subject).to eq(true)
      end
    end

    context 'with a transaction style receipt from sandbox' do
      include_context :transaction_sandbox

      it 'returns false' do
        expect(subject).to eq(false)
      end
    end

    context 'with a unified style receipt from production' do
      it 'returns true'
    end

    context 'with a unified style receipt from sandbox' do
      include_context :unified_sandbox

      it 'returns false' do
        expect(subject).to eq(false)
      end
    end
  end

  describe '#sandbox?' do
    subject { instance.sandbox? }

    context 'with a transaction style receipt from sandbox' do
      include_context :transaction_sandbox

      it 'returns true' do
        expect(subject).to eq(true)
      end
    end

    context 'with a transaction style receipt from production' do
      include_context :transaction_production

      it 'returns false' do
        expect(subject).to eq(false)
      end
    end

    context 'with a unified style receipt from sandbox' do
      include_context :unified_sandbox

      it 'returns true' do
        expect(subject).to eq(true)
      end
    end

    context 'with a unified style receipt from production' do
      it 'returns false'
    end
  end

  describe '#style' do
    subject { instance.style }

    context 'with a transaction receipt' do
      include_context :transaction_sandbox

      it 'returns :transaction' do
        expect(subject).to eq(:transaction)
      end
    end

    context 'with a unified receipt' do
      include_context :unified_sandbox

      it 'returns :unified' do
        expect(subject).to eq(:unified)
      end
    end
  end
end
