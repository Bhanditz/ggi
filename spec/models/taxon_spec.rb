describe Taxon do
  subject { Taxon }
  describe '.find' do

    context 'taxon_concept_id does not exist' do
      let(:taxon_concept_id) { 'whatever' }

      it 'returns nil' do
        stub_find_taxon(0)
        taxon = subject.find(taxon_concept_id)
        expect(subject.find(taxon_concept_id)).to be_nil
      end

    end

    context 'taxon_concept_id exists' do
      let(:taxon_concept_id) { 4437 }

      it 'returns hash' do
        stub_find_taxon(taxon_concept_id)
        expect(subject.find(taxon_concept_id)).to be_a Hash
      end

      it 'has the name' do
        stub_find_taxon(taxon_concept_id)
        taxon = subject.find(taxon_concept_id)
        expect(taxon[:scientificName]).to eq 'Solanaceae'
      end

    end

  end
end
