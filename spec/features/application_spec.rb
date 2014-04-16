describe '/' do

  it 'renders' do
    visit '/'
    expect(page.status_code).to eq 200
    expect(page.body).to match 'GGI Portal'
  end

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

      it 'redirects to referrer' do
        visit '/'
        fill_in('search_term', with: 'whatever')
        click_button('Search')
        expect(page.status_code).to eq 200
        expect(page.current_path).to eq '/'
      end

    end

    context 'autocomplete', js: true do 

      it 'searches with autocomplete' do
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

