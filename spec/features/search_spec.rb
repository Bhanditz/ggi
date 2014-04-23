describe 'search' do
  context 'a name found search' do
    it 'displays page for found name' do
      visit '/'
      fill_in('search_term', with: 'Solanaceae')
      click_button('Search')
      expect(page.status_code).to eq 200
      expect(page.current_path).to eq '/taxon/E150313D-756C-40B0-4221-393CFAE2170C'
      expect(page.body).to match 'Family Solanaceae'
    end
  end

  context 'a name not found search' do
    it 'throws a 404' do
      visit '/'
      fill_in('search_term', with: 'whatever')
      click_button('Search')
      expect(page.status_code).to eq 404
      expect(page.body).to match '404 not found'
    end
  end
end