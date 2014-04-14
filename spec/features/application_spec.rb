describe '/' do

  it 'renders' do
    visit '/'
    expect(page.status_code).to eq 200
    expect(page.body).to match 'GGI Portal'
  end

  describe 'search' do 

    context 'a name found search' do

      it 'displays page for found name' do
        stub_falo
        stub_find_taxon('4437') 
        visit '/'
        fill_in('search_term', with: 'Solanaceae')
        click_button('Search')
        expect(page.status_code).to eq 200
        expect(page.current_path).to eq '/taxon/solanaceae'
        expect(page.body).to match 'Family Solanaceae'
      end

    end

    context 'a name not found search' do

      it 'redirects to referrer' do
        stub_falo
        visit '/'
        fill_in('search_term', with: 'whatever')
        click_button('Search')
        expect(page.status_code).to eq 200
        expect(page.current_path).to eq '/'
      end

    end

    context 'autocomplete', js: true do 

      it 'searches with autocomplete' do
        stub_falo
        stub_find_taxon('4430') 
        visit '/'
        expect(page).to have_no_xpath '//ul[@id="ui-id-1"]/li[1]'
        fill_in('search_term', with: 'sol')
        expect(page).to have_xpath '//ul[@id="ui-id-1"]/li[1]'
        expect(page).to have_xpath '//li[@class="ui-menu-item"]'
        find(:xpath, '//li[@class="ui-menu-item"][1]').click
        expect(page.body).to match 'Solanales'
      end

    end

  end

end

