describe Ggi::Classification do
  before(:all) do #to avoid lazy loading of subject
    stub_falo
    gfi = Ggi::FaloImporter.new
    @classification = gfi.import
  end

  describe '.new' do
    it 'initializes' do
      expect(@classification).to be_kind_of Ggi::Classification 
    end
  end

  describe '#auto_complete' do
    
    it 'returns empty array for search from 0 to 3 characters' do
      expect(@classification.autocomplete('')).to eq []
      expect(@classification.autocomplete('m')).to eq []
      expect(@classification.autocomplete('me')).to eq []
    end

    it 'returns data matching 3 or more characters' do
      expect(@classification.autocomplete('met').size).to eq 11
      expect(@classification.autocomplete('meth').size).to eq 11
    end
  end

end
