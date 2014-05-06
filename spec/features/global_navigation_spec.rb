feature 'Global navigation' do
  before { visit '/' }
  
  ['About', 'Help', 'Download'].each do |link|
    it "links to #{link}" do
      click_link link
      expect(page).to have_selector('h1', text: link)
    end
  end
end
