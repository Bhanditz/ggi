describe Ggi::Uri do

  before(:all) do
    @known_uris = {
      'BHL' => 'http://eol.org/schema/terms/NumberReferencesInBHL',
      'BOLD' => 'http://eol.org/schema/terms/NumberPublicRecordsInBOLD',
      'EOL' => 'http://eol.org/schema/terms/NumberRichSpeciesPagesInEOL',
      'GBIF' => 'http://eol.org/schema/terms/NumberRecordsInGBIF',
      'NCBI' => 'http://eol.org/schema/terms/NumberOfSequencesInGenBank',
      'GGBN' => 'http://eol.org/schema/terms/NumberSpecimensInGGBN'
    }

    @long_names = {
      'BHL' => 'BHL pages',
      'BOLD' => 'BOLD records',
      'EOL' => 'EOL rich pages',
      'GBIF' => 'GBIF records',
      'NCBI' => 'GenBank sequences',
      'GGBN' => 'GGBN records'
    }
  end

  ['BHL', 'BOLD', 'EOL', 'GBIF', 'NCBI', 'GGBN'].each do |name|
    describe name do
      subject { Ggi::Uri.send(name.downcase.to_sym) }
      it "knows the short name" do
        expect(subject.short_name).to eq(name)
      end
      it "knows the long name" do
        expect(subject.long_name).to eq(@long_names[name])
      end
      it "knows the short name" do
        expect(subject.uri).to eq(@known_uris[name])
      end
    end
  end

  it 'lists all URIs' do
    @known_uris.values.each do |uri|
      expect(Ggi::Uri.uris).to include uri
    end
  end

  it 'lists all short names' do
  end

end
