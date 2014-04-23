describe '/taxon' do

  it 'renders with a valid ID' do
    visit '/taxon/E150313D-756C-40B0-4221-393CFAE2170C'
    expect(page.status_code).to eq 200
    expect(page.body).to match 'GGI Portal'
  end

  it 'throws a 404 for invalid IDs' do
    visit '/taxon/nonsense'
    expect(page.status_code).to eq 404
    expect(page.body).to match '404 not found'
  end

end

