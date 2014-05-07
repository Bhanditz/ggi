describe Classification do
  describe '.classification' do
    it 'returns Ggi::Classification' do
      expect(Classification.classification).to be_kind_of Ggi::Classification
    end
  end

  describe '#auto_complete' do
    
    it 'returns empty array for search from 0 characters' do
      expect(Classification.autocomplete('')).to eq []
    end

    it 'returns data matching 1 or more characters' do
      expect(Classification.autocomplete('s').size).to eq 10
      expect(Classification.autocomplete('so').size).to eq 10
      expect(Classification.autocomplete('sol').size).to eq 10
      expect(Classification.autocomplete('sola').size).to eq 5
    end

    it 'returns data matching common names' do
      expect(Classification.autocomplete('birds').size).to eq 2
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
          to be_kind_of Ggi::Taxon
      end

      it 'can search for common names' do
        expect(Classification.search('Birds')).
          to be_kind_of Ggi::Taxon
      end
    end

  end

end
