describe Ggi::Taxon do
  subject { Ggi::Taxon }

  describe '.method_missing' do
    let(:taxon) { Ggi::Taxon.find('E150313D-756C-40B0-4221-393CFAE2170C') }

    it 'can access hash values as properties' do
      expect(taxon.name).to eq 'Solanaceae'
    end

    it 'knows when methods are truly missing' do
      expect { taxon.nonsense }.to raise_error(NoMethodError)
    end
  end

  describe '.find' do
    context 'taxon_concept_id does not exist' do
      let(:taxon_concept_id) { 'whatever' }

      it 'returns nil' do
        taxon = subject.find(taxon_concept_id)
        expect(subject.find(taxon_concept_id)).to be_nil
      end
    end

    context 'taxon_concept_id exists' do
      let(:taxon_concept_id) { 'E150313D-756C-40B0-4221-393CFAE2170C' }

      it 'returns hash' do
        expect(subject.find(taxon_concept_id)).to be_a Ggi::Taxon
      end

      it 'has the name' do
        expect(subject.find(taxon_concept_id).name).to eq 'Solanaceae'
      end
    end
  end
end
