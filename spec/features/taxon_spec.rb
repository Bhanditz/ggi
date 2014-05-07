shared_examples 'a record not found' do
  it { expect(subject.status_code).to eq 404 }
  it { expect(subject.body).to match /404 not found/ }
end

shared_examples 'a family' do
  ['GenBank', 'EOL', 'GGBN', 'GBIF', 'BOLD', 'BHL'].each do |label|
    expect_it { to have_selector('th', text: /#{label}/) }
  end
end

shared_examples 'a taxon' do |valid, image, license|
  if valid
    context 'that is valid' do
      it { expect(subject.status_code).to eq 200 }
      expect_it { to have_selector('h1', text: /^#{taxon.rank} #{taxon.name}$/) }
      expect_it { to have_selector('h3', text: 'Legend') }
      ['good', 'average', 'poor'].each do |legend_item|
        expect_it { to have_selector('dt', text: /#{legend_item}/i) }
      end
      expect_it { to have_selector('dd', text: /0 to 33/) }
      expect_it { to have_selector('dd', text: /34 to 66/) }
      expect_it { to have_selector('dd', text: /67 to 100/) }
    end
  else
    context 'that is not valid' do
      it_behaves_like 'a record not found'
    end
  end
  if image
    context 'with an image' do
      expect_it { to have_selector('img[src*=media]') }
    end
  end
  case license
  when 'by-nc-sa--2-0'
    context 'with by-nc-sa 2.0 licensed image' do
      expect_it { to have_selector('a.licenses--by-nc-sa--2-0 svg') }
      expect_it { to have_selector('a[href*=by-nc-sa]') }
    end
  when 'by-nc--3-0'
    context 'with by-nc 3.0 licensed image' do
      expect_it { to have_selector('a.licenses--by-nc--3-0 svg') }
      expect_it { to have_selector('a[href*=by-nc]') }
    end
  when 'gpl'
    context 'with gpl licensed image' do
      expect_it { to have_selector('a.licenses--gpl', text: 'GNU GPL') }
      expect_it { to have_selector('a[href*=gpl]') }
    end
  when ''
    context 'with no image license' do
      expect_it { to_not have_selector('a[class*=licenses]') }
    end
  end
end

describe '/taxon' do
  subject { page }
  let(:eukaryota) { Ggi::Classification.classification.search('eukaryota') }
  let(:solanaceae) { Ggi::Classification.classification.search('solanaceae') }
  let(:martyniaceae) { Ggi::Classification.classification.search('martyniaceae') }
  let(:korarchaeota) { Ggi::Classification.classification.search('korarchaeota') }
  let(:bacillariophyceae) { Ggi::Classification.classification.search('bacillariophyceae') }
  let(:alisphaeraceae) { Ggi::Classification.classification.search('alisphaeraceae') }

  context 'when high scoring family solanaceae' do
    before { visit "/taxon/#{solanaceae.id}" }
    it_behaves_like 'a taxon', true, true, 'by-nc-sa--2-0' do
      let(:taxon) { solanaceae }
    end
    it_behaves_like 'a family'
  end

  context 'when poor scoring family alisphaeraceae' do
    before { visit "/taxon/#{alisphaeraceae.id}" }
    it_behaves_like 'a taxon', true, false, nil  do
      let(:taxon) { alisphaeraceae }
    end
    it_behaves_like 'a family'
  end

  context 'when family martyniaceae' do
    before { visit "/taxon/#{martyniaceae.id}" }
    it_behaves_like 'a taxon', true, true, 'gpl' do
      let(:taxon) { martyniaceae }
    end
    it_behaves_like 'a family'
  end

  context 'when superkingdom eukaryota' do
    before { visit "/taxon/#{eukaryota.id}" }
    it_behaves_like 'a taxon', true, true, 'by-nc-sa--2-0' do
      let(:taxon) { eukaryota }
    end
  end

  context 'when class korarchaeota' do
    before { visit "/taxon/#{korarchaeota.id}" }
    it_behaves_like 'a taxon', true, true, '' do
      let(:taxon) { korarchaeota }
    end
  end

  context 'when class bacillariophyceae' do
    before { visit "/taxon/#{bacillariophyceae.id}" }
    it_behaves_like 'a taxon', true, true, 'by-nc--3-0' do
      let(:taxon) { bacillariophyceae }
    end
    context 'with empty image owner' do
      expect_it { to have_selector('figcaption p', text: 'Via biopix') }
    end
  end

  context 'when does not exist' do
    before { visit '/taxon/nonsense' }
    it_behaves_like 'a taxon', false, false, nil
  end

end
