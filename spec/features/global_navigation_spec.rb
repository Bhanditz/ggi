feature 'Global navigation' do
  scenario 'user browses all pages' do
    visit '/'
    click_link 'About'
    expect(page).to have_selector('h1', text: 'About')
    click_link 'Help'
    expect(page).to have_selector('h1', text: 'Help')
    click_link 'Download'
    expect(page).to have_selector('h1', text: 'Download')
  end
end
