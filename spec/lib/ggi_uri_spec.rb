describe Ggi::Uri do

  it 'knows BHL' do
    expect(Ggi::Uri.bhl.short_name).to eq('BHL')
    expect(Ggi::Uri.bhl.long_name).to eq('BHL pages')
    expect(Ggi::Uri.bhl.uri).to eq('http://eol.org/schema/terms/NumberReferencesInBHL')
  end

  it 'knows BOLD' do
    expect(Ggi::Uri.bold.short_name).to eq('BOLD')
    expect(Ggi::Uri.bold.long_name).to eq('BOLD records')
    expect(Ggi::Uri.bold.uri).to eq('http://eol.org/schema/terms/NumberPublicRecordsInBOLD')
  end

end
