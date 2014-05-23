
describe Ggi::AllFamiliesDownload do

  describe '#create' do

    before do
      @xeno_fam =  Ggi::Classification.classification.taxa["BC5220A9-06E0-45A5-D776-20D6E909D25A"]
      @asco_fam =  Ggi::Classification.classification.taxa["E817BB93-3905-3D4B-82CE-43C39513603D"]
      @subphylum = Ggi::Classification.classification.taxa["B2B7712A-55A5-0929-823C-A44EBCE3D456"]
      @package = Axlsx::Package.new # NOTE - can't use #let; recursive.
      allow(Axlsx::Package).to receive(:new) { @package } 
      allow(@package).to receive(:serialize) { true }
      allow(Ggi::Classification.classification).to receive(:taxa) { {
        "BC5220A9-06E0-45A5-D776-20D6E909D25A" => @xeno_fam,
        "E817BB93-3905-3D4B-82CE-43C39513603D" => @asco_fam,
        "B2B7712A-55A5-0929-823C-A44EBCE3D456" => @subphylum
      } }
    end

    subject { Ggi::AllFamiliesDownload.create }

    it 'completes' do
      expect { subject }.to_not raise_error
    end

    it 'reads measurements from (only) the families' do
      allow(@xeno_fam).to receive(:measurements) { [] }
      allow(@asco_fam).to receive(:measurements) { [] }
      allow(@subphylum).to receive(:measurements) { [] }
      subject
      expect(@xeno_fam).to have_received(:measurements).at_least(:once)
      expect(@asco_fam).to have_received(:measurements).at_least(:once)
      expect(@subphylum).to_not have_received(:measurements)
    end

    it 'serializes public/ggi.xlsx by default' do
      subject
      expect(@package).to have_received(:serialize).with('public/ggi_family_data.xlsx')
    end

    it 'serializes first argument if given' do
      Ggi::AllFamiliesDownload.create(filepath: 'foo/bar.baz')
      expect(@package).to have_received(:serialize).with('foo/bar.baz')
    end

    it 'creates a valid package' do
      subject
      expect(@package.validate).to be_empty
    end

    it 'creates the three worksheets we expect' do
      subject
      expect(@package.workbook.worksheets.map(&:name)).to eq([
        "FALO plus data",
        "Data for pivots",
        "Key"
      ])
    end

    describe 'FALO plus data worksheet (with only one row)' do

      subject do
        Ggi::AllFamiliesDownload.create
        @package.workbook.worksheets.first
      end

      let(:headers) { [
        'Sort',
        'Superkingdom',
        'Kingdom',
        'Subkingdom',
        'Infrakingdom',
        'Superphylum',
        'Phylum',
        'Subphylum',
        'Infraphylum',
        'Parvphylum',
        'Superclass',
        'Class',
        'Subclass',
        'Infraclass',
        'Superorder',
        'Order',
        'Family',
        'BHL',
        'BOLD',
        'EOL',
        'GBIF',
        'NCBI',
        'GGBN',
        'BHL_Percentile',
        'BOLD_Percentile',
        'EOL_Percentile',
        'GBIF_Percentile',
        'NCBI_Percentile',
        'GGBN_Percentile',
        'GGI score',
        'Reference'
      ] }

      before do
        # We're doing this so that we know which row to read, since it will be
        # the only row:
        allow(Ggi::Classification.classification).to receive(:taxa) { {
          "E817BB93-3905-3D4B-82CE-43C39513603D" => @asco_fam
        } }
      end

      it 'has all expected columns' do
        expect(subject.rows.first.cells.map(&:value)).to \
          eq(headers)
      end

      # TODO - if one of these is missing, we should check that it does the right thing
      it 'reads all of the ancestors from a family' do
        ancestors = []
        letters = ('A'..'Z').to_a
        # NOTE - 15 is just the index of the last ancestor rank (before family)
        headers[1..15].each_with_index do |rank, i|
          ancestors << double(Ggi::Taxon, rank: rank.downcase, name: letters[i])
        end
        allow(@asco_fam).to receive(:ancestors) { ancestors }
        # NOTE: using row[1] because the 0th row is headers
        # NOTE: starting with cell 1 because the 0th row is a sort column
        end_row = @asco_fam.ancestors.count
        expect(subject.rows[1].cells[1..end_row].map(&:value)).to \
          eq(letters[0..ancestors.length-1])
      end

      it 'puts in the taxon name' do
        expect(subject.rows[1].cells[headers.find_index('Family')].value).to \
          eq(@asco_fam.name)
      end

      it 'puts in the measurements' do
        measurements = []
        Ggi::Uri.all.each_with_index do |uri, i|
          measurements << { measurementValue: i+2, score: (i+1) * 0.01, name: uri.short_name, measurementType: uri.uri }
        end
        allow(@asco_fam).to receive(:measurements) { measurements }
        measurements.each do |measurement|
          column_name = measurement[:name].to_s.upcase
          expect(subject.rows[1].cells[headers.find_index(column_name)].value).to \
            eq(measurement[:measurementValue])
          expect(subject.rows[1].cells[headers.find_index("#{column_name}_Percentile")].value).to \
            eq(measurement[:score] * 100)
        end
      end

      it 'puts in the taxon score' do
        allow(@asco_fam).to receive(:score) { 0.34 }
        expect(subject.rows[1].cells[headers.find_index('GGI score')].value).to \
          eq(34)
      end

      it 'puts in the taxon source' do
        allow(@asco_fam).to receive(:source) { 'This thing' }
        expect(subject.rows[1].cells[headers.find_index('Reference')].value).to \
          eq('This thing')
      end

    end

    describe 'Data for pivots worksheet (with one row of data)' do

      subject do
        Ggi::AllFamiliesDownload.create
        @package.workbook.worksheets[1]
      end

      let(:headers) { [
        'Family',
        'Value',
        'Source'
      ] }

      before do
        # We're doing this so that we know which row to read, since it will be
        # the only row:
        allow(Ggi::Classification.classification).to receive(:taxa) { {
          "E817BB93-3905-3D4B-82CE-43C39513603D" => @asco_fam
        } }
      end

      it 'has all expected columns' do
        expect(subject.rows.first.cells.map(&:value)).to \
          eq(headers)
      end

      it 'adds a row which has the name' do
        allow(@asco_fam).to receive(:name) { 'This name' }
        expect(subject.rows[1].cells[0].value).to eq('This name')
      end

      it 'adds a row which has a value of 1' do
        expect(subject.rows[1].cells[headers.find_index('Value')].value).to eq(1)
      end

      it 'adds a row which has a source of FALO' do
        expect(subject.rows[1].cells[headers.find_index('Source')].value).to eq('FALO')
      end

      it 'adds rows for each measurement' do
        allow(@asco_fam).to receive(:measurements) { [
          { score: 1, measurementValue: 'first', measurementType: Ggi::Uri.bhl.uri },
          { score: 1, measurementValue: 'then', measurementType: Ggi::Uri.gbif.uri }
        ] }
        expect(subject.rows[2].cells.map(&:value)).to \
          eq([@asco_fam.name, 'first', 'BHL'])
        expect(subject.rows[3].cells.map(&:value)).to \
          eq([@asco_fam.name, 'then', 'GBIF'])
      end

      # NOTE - if this spec scares you, try changing the nil to a number and see it fail.
      it 'ignores measurements with no score' do
        allow(@asco_fam).to receive(:measurements) { [
          { score: 1, measurementValue: 'first', measurementType: Ggi::Uri.bhl.uri },
          { score: nil, measurementValue: 'bad', measurementType: Ggi::Uri.gbif.uri }
        ] }
        subject.rows.each do |row|
          expect(row.cells[1].value).to_not eq('bad')
        end
      end

    end

    describe 'Key worksheet (with one row of data)' do

      subject do
        Ggi::AllFamiliesDownload.create
        @package.workbook.worksheets[2]
      end

      let(:headers) { [
        'Term',
        'URI',
        'Definition'
      ] }

      before do
        # We're doing this so that we know which row to read, since it will be
        # the only row:
        allow(Ggi::Classification.classification).to receive(:taxa) { {
          "E817BB93-3905-3D4B-82CE-43C39513603D" => @asco_fam
        } }
      end

      it 'has all expected columns' do
        # NOTE - this is checking the SECOND row because there are notes in the first.
        expect(subject.rows[1].cells.map(&:value)).to \
          eq(headers)
      end

      it 'includes the FALO version' do
        expect(subject.rows.first.cells.first.value).to \
          match(/^BASED on FALO version 2.5/)
      end

      it 'includes an unknown default query date' do
        expect(subject.rows.first.cells.first.value).to \
          match(/queries up to date as of unknown$/)
      end

      # NOTE that this spec definitely assumes the Ggi::Uri class is correct!
      it 'adds a row for each URI term' do
        Ggi::Uri.all.each_with_index do |uri, i|
          expect(subject.rows[ i + 2 ].cells.map(&:value)).to \
            eq([uri.long_name, uri.uri, uri.definition])
        end
      end

    end

  end

end
