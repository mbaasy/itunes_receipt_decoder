describe ItunesReceiptDecoder::Decode::TransactionReceipt do
  shared_context :production do
    let(:receipt_file) { 'transaction_production' }
  end

  shared_context :sandbox do
    let(:receipt_file) { 'transaction_sandbox' }
  end

  subject { described_class.new(receipt) }

  let(:receipt) do
    data = File.read(
      File.expand_path("../../examples/#{receipt_file}.txt", __FILE__)
    ).chomp
    Base64.decode64(data)
  end
  let(:json) do
    data = File.read(
      File.expand_path("../../examples/#{receipt_file}.json", __FILE__)
    )
    JSON.parse(data, symbolize_names: true)
  end

  describe '.new' do
    context 'when purchase-info can\'t be parsed' do
      let(:receipt) do
        plist = CFPropertyList::List.new
        plist.value = CFPropertyList.guess(
          'signature' => 'foobar',
          'purchase-info' => 'foobar'
        )
        encoded = plist.to_str(CFPropertyList::List::FORMAT_PLAIN)
        Base64.strict_encode64(encoded)
      end

      it 'raises a DecodingError' do
        expect { subject }.to raise_error(ItunesReceiptDecoder::DecodingError)
      end
    end
  end

  describe '#receipt' do
    include_context :sandbox

    subject { super().receipt }

    it 'parses the purchase info' do
      expect(subject).to eq(json)
    end
  end

  describe '#signature_valid?' do
    include_context :sandbox

    subject { super().signature_valid? }

    it 'returns true' do
      expect(subject).to eq(true)
    end
  end

  describe '#environment' do
    subject { super().environment }

    context 'with a receipt from sandbox' do
      include_context :sandbox

      it 'returns :sandbox' do
        expect(subject).to eq(:sandbox)
      end
    end

    context 'with a receipt from production' do
      include_context :production

      it 'returns :production' do
        expect(subject).to eq(:production)
      end
    end
  end

  describe '#production?' do
    subject { super().production? }

    context 'with a receipt from production' do
      include_context :production

      it 'returns true' do
        expect(subject).to eq(true)
      end
    end

    context 'with a receipt from sandbox' do
      include_context :sandbox

      it 'returns false' do
        expect(subject).to eq(false)
      end
    end
  end

  describe '#sandbox?' do
    subject { super().sandbox? }

    context 'with a transaction style receipt from sandbox' do
      include_context :sandbox

      it 'returns true' do
        expect(subject).to be_truthy
      end
    end

    context 'with a transaction style receipt from production' do
      include_context :production

      it 'returns false' do
        expect(subject).to eq(false)
      end
    end
  end

  describe '#style' do
    subject { super().style }

    include_context :sandbox

    it 'returns :transaction' do
      expect(subject).to eq(:transaction)
    end
  end
end
