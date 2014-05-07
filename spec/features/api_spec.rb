describe '/api' do

  let(:taxon) { Ggi::Taxon.find('E150313D-756C-40B0-4221-393CFAE2170C') }

  it 'returns taxonomy HTML' do
    visit '/api/taxonomy/' + taxon.id
    expect(page.status_code).to eq 200
    expect(page).to have_selector('a', text: taxon.name)
  end

  it 'return details HTML' do
    visit '/api/details/' + taxon.id
    expect(page.status_code).to eq 200
    expect(page).to have_selector('h1', text: taxon.name)
  end

end
