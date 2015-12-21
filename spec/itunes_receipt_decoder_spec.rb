describe ItunesReceiptDecoder do
  shared_context :transaction do
    let(:receipt_path) do
      File.expand_path('../examples/transaction_sandbox.txt', __FILE__)
    end
  end

  shared_context :unified do
    let(:receipt_path) do
      File.expand_path('../examples/unified_sandbox.txt', __FILE__)
    end
  end

  subject { described_class.new(receipt_data) }

  let(:receipt_data) { File.read(receipt_path).chomp }

  describe '.new' do
    context 'with a transaction style receipt' do
      include_context :transaction

      it 'returns an instance of Decode::TransactionReceipt' do
        expect(subject).to be_a(described_class::Decode::TransactionReceipt)
      end
    end

    context 'with a unified style receipt' do
      include_context :unified

      it 'returns an instance of Decode::UnifiedReceipt' do
        expect(subject).to be_a(described_class::Decode::UnifiedReceipt)
      end
    end

    context 'when the receipt_data is not base64 encoded' do
      let(:receipt_data) { '1' }

      it 'raises a DecodingError' do
        expect { subject }.to raise_error(described_class::DecodingError)
      end
    end

    context 'when the receipt_data is not a transaction or unified receipt' do
      let(:receipt_data) { Base64.strict_encode64('foobar') }

      it 'raises a DecodingError' do
        expect { subject }.to raise_error(described_class::DecodingError)
      end
    end
  end
end
