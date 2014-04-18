describe Ggi::ClassificationImporter do
  subject { Ggi::ClassificationImporter.new }

  describe '.new' do
    it { should be_kind_of Ggi::ClassificationImporter }
  end
  
  describe '#import' do
    it 'should return array with 5 elements' do
      res = subject.import
      expect(res).to be_kind_of Array
      expect(res.size).to eq 5
    end
  end
end
