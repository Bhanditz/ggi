describe Ggi::Autocompleter do
  describe '.search' do
    it 'finds something' do
      name = 'Something'
      names = [{name => [1], 'Other thing' => [2]}]
      expect(Ggi::Autocompleter.search(name, names)).to eq({ 1 => name})
    end
    
    it 'does not find something' do
      names = [{'Other thing' => [1]}]
      expect(Ggi::Autocompleter.search('Something', names)).to eq({})
    end
    
    it 'finds more than one thing' do
      name = 'Something'
      names = [{name => [1, 2], 'Other thing' => [2]}]
      expect(Ggi::Autocompleter.search(name, names)).to eq({ 1 => name, 2 => name})
    end
    
    it 'finds at most 10 things' do
      lots = (1..20).collect do |i|
        {"Thing#{i}" => [i]}
      end
      expect(Ggi::Autocompleter.search('Thing', lots).length).to eq(10)
    end
  end
end
