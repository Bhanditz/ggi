describe 'autocomplete', js: true do

  def expect_number_of_children(which, count)
    expect(page).to have_selector("#{which}:nth-child(#{count})")
    expect(page).to_not have_selector("#{which}:nth-child(#{count+1})")
  end

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
    fill_in('search_term', with: 'racc')
    expect(page).to have_xpath '//ul[@id="ui-id-1"]/li[1]', text: 'Eukaryota > Carnivora'
    expect(page).to have_xpath '//ul[@id="ui-id-1"]/li[1]', text: 'Procyonidae'
    expect(page).to have_xpath '//ul[@id="ui-id-1"]/li[1]', text: 'Coatis, raccoons, and relatives'
    expect(page).to have_xpath '//ul[@id="ui-id-1"]/li[1]', text: 'Alternative name: Raccoon, coati & olingo'
  end

  it 'shows a message when there are no results' do
    visit '/'
    expect(page).to have_no_xpath '//ul[@id="ui-id-1"]/li[1]'
    fill_in('search_term', with: 'nonsense')
    expect(page).to have_xpath '//ul[@id="ui-id-1"]/li[1]', text: 'No results'
  end

  it 'returns the default batch size' do
    visit '/'
    expect(page).to have_no_xpath '//ul[@id="ui-id-1"]/li[1]'
    fill_in('search_term', with: 'b')
    expect_number_of_children("ul.ui-autocomplete li", 7)
  end

end
