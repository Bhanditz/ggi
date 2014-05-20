describe 'routes' do

  context 'unknown route' do
    it 'throws a 404' do
      visit '/nonsense'
      expect(page.status_code).to eq 404
      expect(page.body).to match 'Page not found'
    end
  end

end
