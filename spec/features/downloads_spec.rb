feature 'Downloads' do

  before { visit '/downloads' }

  it 'has an h1 with an appropriate keyword (for SEO)' do
    expect(page).to have_selector('h1', text: /Download/)
  end
  
  it "has a link to the GGI XLSX file" do
    expect(page).to have_selector('a[href="/ggi_family_data.xlsx"]', text: /ggi.*famil(y|ies)/i)
  end

  it "actually points to a real file" do
    expect(File.exist?(File.join(File.expand_path('../../..', __FILE__),
                                 'public',
                                 'ggi_family_data.xlsx'))).to be true
  end

end
