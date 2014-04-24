describe 'autocomplete', js: true do
  it 'shows the proper results' do
    visit '/'
    expect(page).to have_no_xpath '//ul[@id="ui-id-1"]/li[1]'
    fill_in('search_term', with: 'sol')
    expect(page).to have_xpath '//ul[@id="ui-id-1"]/li[1]'
    expect(page).to have_xpath '//li[@class="ui-menu-item"]'
    find(:xpath, '//li[@class="ui-menu-item"][1]').click
    expect(page).to have_selector 'h1', text: 'Order Solirubrobacterales'
  end

  it 'shows the matched name when necessary' do
    visit '/'
    expect(page).to have_no_xpath '//ul[@id="ui-id-1"]/li[1]'
    fill_in('search_term', with: 'birds')
    # Since birds was the search term, and Birds will be displayed with the
    # search result, we don't need to show an alternative name
    expect(page).to have_xpath '//ul[@id="ui-id-1"]/li[1]', text: 'Eukaryota > Tetrapoda'
    expect(page).to have_xpath '//ul[@id="ui-id-1"]/li[1]', text: 'Aves'
    expect(page).to have_xpath '//ul[@id="ui-id-1"]/li[1]', text: 'Birds'
    expect(page).to have_no_xpath '//ul[@id="ui-id-1"]/li[1]', text: 'Alternative name'
    # the search term 'birds' is not part of the scientific name or 'bird-of-paradise'
    # so we show an 'alternative name' which is the actual match that includes 'birds'
    expect(page).to have_xpath '//ul[@id="ui-id-1"]/li[2]', text: 'Eukaryota > Passeriformes'
    expect(page).to have_xpath '//ul[@id="ui-id-1"]/li[2]', text: 'Paradisaeidae'
    expect(page).to have_xpath '//ul[@id="ui-id-1"]/li[2]', text: 'Bird-of-paradise'
    expect(page).to have_xpath '//ul[@id="ui-id-1"]/li[2]', text: 'Alternative name: Birds of paradise'
  end

  it 'shows a message when there are no results' do
    visit '/'
    expect(page).to have_no_xpath '//ul[@id="ui-id-1"]/li[1]'
    fill_in('search_term', with: 'nonsense')
    expect(page).to have_xpath '//ul[@id="ui-id-1"]/li[1]', text: 'No results'
  end
end
