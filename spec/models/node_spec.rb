describe Node do
  describe '.get' do

    context 'when file is missing' do

      it 'raises an error' do
        expect { Node.get('not_found') }.to raise_error
      end

    end

    context 'when reading animalia' do

      subject { Node.get('mammalia') }

      it { should be_a Node }

      it { should respond_to :json }

      # NOTE - this depends on the format of the file; we're assuming it's
      # stable for now.
      it 'has the name' do
        expect(subject.json["scientificName"]).to eq("Mammalia")
      end

    end

  end
end
