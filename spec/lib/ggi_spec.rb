describe Ggi do

  describe '.version' do
    it 'returns version number' do
      expect(Ggi.version).to match /^\d+\.\d+.\d+$/
    end
  end

end
