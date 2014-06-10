feature 'Global navigation' do

  before { visit '/' }
  
  [ { link: 'About',     head: 'Global Genome Initiative' },
    { link: 'Help',      head: 'Help' },
    { link: 'Downloads', head: 'Download' }
  ].each do |page_info|
    it "links to #{page_info[:link]} with heading #{page_info[:head]}" do
      click_link page_info[:link]
      expect(page).to have_selector('h1', text: page_info[:head])
    end
  end
end
