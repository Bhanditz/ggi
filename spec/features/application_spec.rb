require_relative "../spec_helper.rb"

describe '/' do
  it 'renders' do
    visit '/'
    expect(page.status_code).to eq 200
    expect(page.body).to match 'hi'
  end
end

