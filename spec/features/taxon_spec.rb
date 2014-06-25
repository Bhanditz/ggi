shared_examples 'a record not found' do
  it { expect(subject.status_code).to eq 404 }
  it { expect(subject.body).to match /Page not found/ }
end

shared_examples 'a media rich taxon' do |license, attribution|
  context 'with an image' do
    expect_it { to have_selector('figure img[src*=media]') }
    if license == 'empty'
      context 'without a license' do
        expect_it { to_not have_selector('figcaption a[class*=licenses]') }
      end
    elsif license == 'gpl'
      context 'with license' do
        expect_it { to have_selector("figcaption a.licenses--gpl[href*=gpl]",
                                     text: 'GNU GPL' ) }
      end
    elsif license
      context 'with svg license' do
        expect_it { to have_selector("figcaption "\
          "a.licenses--#{license}[href*=#{license.gsub(/--\d-\d/, '')}] svg") }
      end
    end
    if attribution == 'empty'
      context 'without attribution' do
        expect_it { to_not have_selector('figcaption p') }
      end
    elsif attribution
      context 'with attribution' do
        expect_it { to have_selector('figcaption p', text: attribution) }
      end
    end
  end
end

shared_examples 'an information rich taxon' do
  context 'with an English vernacular name' do
    expect_it { to have_selector('dt', text: 'English common name') }
    expect_it { to have_selector('dd', text: taxon.english_vernacular_name) }
  end
  context 'with a reference' do
    expect_it { to have_selector('dt', text: 'Ref:') }
    expect_it { to have_selector('dd', text: taxon.source) }
  end
end

shared_examples 'an information poor taxon' do
  context 'without a vernacular name' do
    expect_it { to_not have_selector('dt', text: 'Common name') }
  end
  context 'without a reference' do
    expect_it { to_not have_selector('dt', text: 'Reference') }
  end
end

shared_examples 'a rank higher than family' do
  ['GenBank', 'EOL', 'GGBN', 'GBIF', 'BOLD', 'BHL'].each do |label|
    expect_it { to_not have_selector('th', text: /#{label}/) }
  end
  expect_it { to have_selector('dt', text: /^GGI score/i) }
  expect_it { to have_selector('dt', text: /^number of families:$/i) }
  expect_it { to have_selector('p', text: 'For a more detailed assessment of knowledge, choose a family') }
end

shared_examples 'a root node' do
  expect_it { to_not have_selector('dt', text: 'Classification') }
  it_behaves_like 'a rank higher than family'
end

shared_examples 'a non root node' do
  expect_it { to have_selector('dt', text: 'Classification') }
end

shared_examples 'a family' do
  ['GenBank', 'EOL', 'GGBN', 'GBIF', 'BOLD', 'BHL'].each do |label|
    expect_it { to have_selector('th', text: /#{label}/) }
  end
  ['Source', 'Count', '% score'].each do |label|
    expect_it { to have_selector('th', text: /#{label}/) }
  end
  expect_it { to have_selector('th', text: /^GGI score/i) }
  it_behaves_like 'a non root node'
end

shared_examples 'a taxon' do
  it { expect(subject.status_code).to eq 200 }
  expect_it { to have_selector('h1', text: /^#{taxon.rank} #{taxon.name}$/) }
  expect_it { to have_selector('h3', text: 'Legend') }
  expect_it { to have_xpath("//a[@title='Explanation of score']") }
  expect_it { to have_xpath("//a[@title='Explanation of assessment scale']") }
  ['good', 'average', 'poor'].each do |legend_item|
    expect_it { to have_selector('dt', text: /#{legend_item}/i) }
  end
  expect_it { to have_selector('dd', text: /0 to 50/) }
  expect_it { to have_selector('dd', text: /51 to 80/) }
  expect_it { to have_selector('dd', text: /81 to 100/) }
end

describe '/taxon' do
  subject { page }
  let(:solanaceae) { Ggi::Classification.classification.search('solanaceae') }
  let(:alisphaeraceae) { Ggi::Classification.classification.search('alisphaeraceae') }
  let(:korarchaeota) { Ggi::Classification.classification.search('korarchaeota') }
  let(:eukaryota) { Ggi::Classification.classification.search('eukaryota') }
  let(:image) { solanaceae.image.clone }

  context 'is a high scoring family' do
    before { visit "/taxon/#{solanaceae.id}" }
    it_behaves_like 'a taxon' do
      let(:taxon) { solanaceae }
    end
    it_behaves_like 'a family'
    it_behaves_like 'an information rich taxon' do
      let(:taxon) { solanaceae }
    end
  end

  context 'is a poor scoring family' do
    before do
      allow_any_instance_of(Ggi::Taxon).to receive(:english_vernacular_name).and_return(nil)
      allow_any_instance_of(Ggi::Taxon).to receive(:source).and_return(nil)
      allow_any_instance_of(Ggi::Taxon).to receive(:image).and_return(nil)
      visit "/taxon/#{alisphaeraceae.id}"
    end
    it_behaves_like 'a taxon'  do
      let(:taxon) { alisphaeraceae }
    end
    it_behaves_like 'an information poor taxon'
    it_behaves_like 'a family'
    context 'without an image' do
      expect_it { to_not have_selector('img[src*=media]') }
    end
  end

  # Test different image licenses are rendered correctly
  { 'gpl' => 'http://www.gnu.org/licenses/gpl.html',
    'by-nc-sa--2-0' => 'http://creativecommons.org/licenses/by-nc-sa/2.0/',
    'by-sa--3-0' => 'http://creativecommons.org/licenses/by-sa/3.0/',
    'empty' => '' }.each do |license, value|
    context "with #{license} licensed image" do
      before do
        allow_any_instance_of(Ggi::Taxon).to receive(:image)
          .and_return(image.merge( { license: value } ))
        visit "/taxon/#{solanaceae.id}"
      end
      it_behaves_like 'a media rich taxon', license
    end
  end

  # Test different combinations of attribution are rendered correctly
  { 'just rights holder' => {
      attribution:  "By Rights Holder",
      image: { rightsHolder: "Rights Holder", agents: [] } },
    'rights holder and provider' => {
      attribution:  "By Rights Holder via Provider",
      image: { rightsHolder: "Rights Holder", agents: [
        { full_name: 'Provider', role: 'provider' } ] } },
    'photographer and provider' => {
      attribution:  "By Photographer via Provider",
      image: { rightsHolder: nil, agents: [
        { full_name: 'Creator', role: 'creator' },
        { full_name: 'Provider', role: 'provider' },
        { full_name: 'Photographer', role: 'photographer' } ] } },
    'just provider' => {
      attribution:  "Via Provider",
      image: { rightsHolder: nil, agents: [
        { full_name: 'Provider', role: 'provider' } ] } },
    'just photographer' => {
      attribution:  "By Photographer",
      image: { rightsHolder: nil, agents: [
        { full_name: 'Photographer', role: 'photographer' } ] } },
    'an agent other than photographer and provider' => {
      attribution:  "By Creator via Provider",
      image: { rightsHolder: nil, agents: [
        { full_name: 'Creator', role: 'creator' },
        { full_name: 'Provider', role: 'provider' } ] } },
    'empty' => {
      attribution:  'empty',
      image: { rightsHolder: nil, agents: [] } }
  }.each do |attribution, options|
    context "with #{attribution} image attribution" do
      before do
        allow_any_instance_of(Ggi::Taxon).to receive(:image)
          .and_return(image.merge(options[:image].merge({
            license: 'http://creativecommons.org/licenses/by-sa/3.0/'})))
        visit "/taxon/#{solanaceae.id}"
      end
      it_behaves_like 'a media rich taxon', 'by-sa--3-0', options[:attribution]
    end
  end

  context 'is a class' do
    before { visit "/taxon/#{korarchaeota.id}" }
    it_behaves_like 'a taxon' do
      let(:taxon) { korarchaeota }
    end
    it_behaves_like 'a rank higher than family'
    it_behaves_like 'a non root node'
  end

  context 'is a root node' do
    before { visit "/taxon/#{eukaryota.id}" }
    it_behaves_like 'a taxon' do
      let(:taxon) { eukaryota }
    end
    it_behaves_like 'a root node'
  end

  context 'does not exist' do
    before { visit '/taxon/nonsense' }
    it_behaves_like 'a record not found'
  end

end
