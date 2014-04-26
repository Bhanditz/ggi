describe '/taxon' do
  subject { page }
  context 'when valid' do
    before { visit '/taxon/E150313D-756C-40B0-4221-393CFAE2170C' }
    it { expect(subject.status_code).to eq 200 }
    it { expect(subject.body).to match /GGI Data Portal/ }
    expect_it { to have_selector('a.licenses--by-nc-sa--2-0 svg', text: '') }
    expect_it { to have_selector('h1', text: 'Solanaceae') }
    expect_it { to have_selector('img[src*=media]') }
  end
  context 'when invalid' do
    before { visit '/taxon/nonsense' }
    it { expect(subject.status_code).to eq 404 }
    it { expect(subject.body).to match /404 not found/ }
  end
  context 'with gnu licensed image' do
    before { visit '/taxon/AC9EFD94-2D6D-D1B3-56C2-08B23043DC02' }
    expect_it { to have_selector('img[src*=media]') }
    expect_it { to have_selector('a.licenses--gpl', text: 'GNU GPL') }
  end
  context 'with empty image license' do
    before { visit '/taxon/1CC1D05C-9536-7B12-81F3-8B845EC5806E' }
    expect_it { to have_selector('img[src*=media]') }
    expect_it { to_not have_selector('a[class*=licenses]') }
  end
end
