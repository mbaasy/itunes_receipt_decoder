require 'spec_helper'

describe ItunesReceiptDecoder do
  let(:options) { {} }
  let(:instance) { described_class.new(receipt_data, options) }
  let(:receipt_data) { File.read(receipt_path).chomp }

  shared_context :transaction_receipt do
    let(:receipt_path) do
      File.expand_path('../examples/transaction_receipt_1.txt', __FILE__)
    end
  end

  shared_context :unified_receipt do
    before :all do
      ItunesReceiptDecoder::Config.certificate_path =
        File.expand_path('../../AppleIncRootCertificate.cer', __FILE__)
    end

    let(:receipt_path) do
      File.expand_path('../examples/unified_receipt.txt', __FILE__)
    end
  end

  shared_examples '#production?' do
    context 'when the environment is Production' do
      before do
        allow(instance).to receive(:environment).and_return('Production')
      end

      it 'returns true' do
        expect(subject).to eq(true)
      end
    end

    context 'when the environment is not Production' do
      before do
        allow(instance).to receive(:environment).and_return('Whatever')
      end

      it 'returns false' do
        expect(subject).to eq(false)
      end
    end
  end

  shared_examples '#sandbox?' do
    context 'when the environment is Production' do
      before do
        allow(instance).to receive(:environment).and_return('Production')
      end

      it 'returns false' do
        expect(subject).to eq(false)
      end
    end

    context 'when the environment is not Production' do
      before do
        allow(instance).to receive(:environment).and_return('Whatever')
      end

      it 'returns true' do
        expect(subject).to eq(true)
      end
    end
  end

  describe '#decode' do
    subject { instance.decode }

    context 'with a transaction receipt' do
      include_context :transaction_receipt

      it 'returns an instance of Decode::TransactionReceipt' do
        expect(subject).to be_a(described_class::Decode::TransactionReceipt)
      end
    end

    context 'with a unified receipt' do
      include_context :unified_receipt

      it 'returns an instance of Decode::UnifiedReceipt' do
        expect(subject).to be_a(described_class::Decode::UnifiedReceipt)
      end
    end
  end

  describe '#receipt' do
    subject { instance.receipt }

    context 'with a transaction receipt' do
      include_context :transaction_receipt

      it 'parses the purchase info' do
        expect(subject).to include(
          :original_purchase_date_pst, :original_transaction_id,
          :bvrs, :transaction_id, :quantity, :original_purchase_date_ms,
          :product_id, :item_id, :bid, :purchase_date_ms, :purchase_date,
          :purchase_date_pst, :original_purchase_date
        )
      end
    end

    context 'with a unified receipt' do
      include_context :unified_receipt

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

    context 'with a transaction receipt' do
      include_context :transaction_receipt

      it 'returns the environment the payload' do
        expect(subject).to eq('Sandbox')
      end
    end

    context 'with a unified receipt' do
      include_context :unified_receipt

      it 'returns the environment from the receipt' do
        expect(subject).to eq('ProductionSandbox')
      end
    end
  end

  describe '#production?' do
    subject { instance.production? }

    context 'with a transaction receipt' do
      include_context :transaction_receipt

      it_behaves_like '#production?'
    end

    context 'with a unified receipt' do
      include_context :unified_receipt

      it_behaves_like '#production?'
    end
  end

  describe '#sandbox?' do
    subject { instance.sandbox? }

    context 'with a transaction receipt' do
      include_context :transaction_receipt

      it_behaves_like '#sandbox?'
    end

    context 'with a unified receipt' do
      include_context :unified_receipt

      it_behaves_like '#sandbox?'
    end
  end

  describe '#style' do
    subject { instance.style }

    context 'with a transaction receipt' do
      include_context :transaction_receipt

      it 'returns :transaction' do
        expect(subject).to eq(:transaction)
      end
    end

    context 'with a unified receipt' do
      include_context :unified_receipt

      it 'returns :unified' do
        expect(subject).to eq(:unified)
      end
    end
  end
end
