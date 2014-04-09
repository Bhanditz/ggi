describe '/' do

  it 'renders' do
    visit '/'
    expect(page.status_code).to eq 200
    expect(page.body).to match 'Go'
  end

  describe 'search' do 

    context 'a name found search' do

      it 'displays page for found name' do
        stub_falo
        stub_find_taxon('4437') 
        visit '/'
        fill_in('search_term', with: 'Solanaceae')
        click_button('Go')
        expect(page.status_code).to eq 200
        save_and_open_page
        expect(page.body).to match 'Family Solanaceae'
      end

    end

  end

end

