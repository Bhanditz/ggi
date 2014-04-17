describe Ggi do

  describe '.version' do
    it 'returns version number' do
      expect(Ggi.version).to match /^\d+\.\d+.\d+$/
    end

    it 'returns version number on instances' do
      expect(Ggi.new.version).to match /^\d+\.\d+.\d+$/
    end
  end

end
