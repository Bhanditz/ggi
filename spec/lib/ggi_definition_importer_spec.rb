describe Ggi::DefinitionImporter do

  describe '#import' do

    before do
      allow(File).to receive(:read) { '[{"a": "1"},{"a": "2"}]' }
    end

    after do
      # No specs for this because if it breaks, other specs will fail.  ;)
      Ggi::DefinitionImporter.clear_cache
    end

    subject { Ggi::DefinitionImporter.new.import }

    it 'parses the JSON from the file' do
      expect(subject).to eq([{'a' => '1'}, {'a' => '2'}])
    end

    it 'reads the right file' do
      subject
      expect(File).to have_received(:read).
        with(File.join(Sinatra::Application.root, 'public', 'eol_definitions.json'))
    end

    it 'reads the file only ONCE' do
      subject
      subject
      expect(File).to have_received(:read).once
    end

  end

end
