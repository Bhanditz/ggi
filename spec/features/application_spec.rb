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

    context 'a name not found search' do

      it 'displays page for found name' do
        stub_falo
        visit '/'
        fill_in('search_term', with: 'whatever')
        click_button('Go')
        expect(page.status_code).to eq 200
        save_and_open_page
        expect(page.body).to match '>Name of Site<'
      end

    end

    context 'autocomplete', js: true do 

      it 'searches with autocomplete' do
        stub_falo
        visit '/'
        expect(page).to have_no_xpath '//ul[@id="ui-id-1"]/li[1]'
        fill_in('search_term', with: 'sol')
        expect(page).to have_xpath '//ul[@id="ui-id-1"]/li[1]'
        expect(page).to have_xpath '//li[@class="ui-menu-item"]'
        find(:xpath, '//li[@class="ui-menu-item"][1]').click
        # expect(page.body).to match 'Solanaceae'
      end

    end

  end

end

