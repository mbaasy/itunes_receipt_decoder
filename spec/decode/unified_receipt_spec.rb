describe ItunesReceiptDecoder::Decode::UnifiedReceipt do
  shared_context :production do
    let(:receipt_file) { 'unified_production' }
  end

  shared_context :sandbox do
    let(:receipt_file) { 'unified_sandbox' }
  end

  subject { described_class.new(receipt, options) }

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
  let(:options) { {} }

  describe '.new' do
    include_context :sandbox

    context 'when OpenSSL::ASN1.decode fails' do
      before do
        pkcs7_double = instance_double 'OpenSSL::PKCS7',
                                       data: 'fake',
                                       verify: true
        allow(OpenSSL::PKCS7).to receive(:new).and_return(pkcs7_double)
      end

      it 'raises a DecodingError' do
        expect { subject }.to raise_error(ItunesReceiptDecoder::DecodingError)
      end
    end
  end

  describe '#receipt' do
    include_context :sandbox

    subject { super().receipt }

    it 'parses the receipt' do
      expect(subject).to include(json)
    end

    context 'when expand_timestamps is true' do
      let(:options) { { expand_timestamps: true } }

      it 'parses the receipt' do
        expect(subject).to include(
          :creation_date, :creation_date_ms, :creation_date_pst
        )
      end

      it 'parses the transactions' do
        subject[:in_app].each do |transaction|
          if transaction[:web_order_line_item_id] > 0
            expect(transaction).to include(
              :expires_date, :expires_date_ms, :expires_date_pst,
              :purchase_date, :purchase_date_ms, :purchase_date_pst,
              :original_purchase_date, :original_purchase_date_ms,
              :original_purchase_date_pst
            )
          else
            expect(transaction).to include(
              :purchase_date, :purchase_date_ms, :purchase_date_pst,
              :original_purchase_date, :original_purchase_date_ms,
              :original_purchase_date_pst
            )
          end
        end
      end
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
      it 'returns :production'
    end
  end

  describe '#production?' do
    subject { super().production? }

    context 'with a receipt from production' do
      it 'returns true'
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

    context 'with a receipt from sandbox' do
      include_context :sandbox

      it 'returns true' do
        expect(subject).to eq(true)
      end
    end

    context 'with a receipt from production' do
      it 'returns false'
    end
  end

  describe '#style' do
    include_context :sandbox

    subject { super().style }

    it 'returns :unified' do
      expect(subject).to eq(:unified)
    end
  end

  describe '#uuid_valid?' do
    include_context :sandbox

    subject { super().uuid_valid?(uuid) }

    context 'with the correct uuuid' do
      let(:uuid) { '3F27583E-3E39-4865-A9F2-98256C105CDF' }
      it 'returns true' do
        expect(subject).to eq(true)
      end
    end

    context 'with an incorrect uuid' do
      let(:uuid) { '4F27583E-3E39-4865-A9F2-98256C105CDF' }

      it 'returns false' do
        expect(subject).to eq(false)
      end
    end
  end
end
