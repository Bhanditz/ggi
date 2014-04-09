describe Classification do
  describe '.classification' do
    it 'returns Ggi::Classification' do
      stub_falo
      expect(Classification.classification).to be_kind_of Ggi::Classification
    end
  end

  describe '#auto_complete' do
    
    it 'returns empty array for search from 0 to 3 characters' do
      expect(Classification.autocomplete('')).to eq []
      expect(Classification.autocomplete('s')).to eq []
      expect(Classification.autocomplete('so')).to eq []
    end

    it 'returns data matching 3 or more characters' do
      expect(Classification.autocomplete('sol').size).to eq 2
      expect(Classification.autocomplete('sola').size).to eq 2
    end

  end

  describe '#search' do
    
    context 'search fails' do

      it 'returns nil' do
        expect(Classification.search('meth')).to be_nil
      end

    end

    context 'search succeeds' do
      it 'returns classification node' do
        expect(Classification.search('SolaNaceae')).
          to be_kind_of Nokogiri::XML::Element
      end
    end

  end

end
