describe Ggi::FaloImporter do
  subject { Ggi::FaloImporter.new }

  describe '.new' do
    it 'initializes' do
      expect(subject).to be_kind_of Ggi::FaloImporter
    end
  end

  describe '#import' do
    it 'creates classification tree in memory' do
      stub_request(:get, Ggi.config.falo_url).
         to_return(status: 200, body: get_falo_csv)
      tree = subject.import
      expect(tree).to be_kind_of Ggi::Classification
    end
  end

end
