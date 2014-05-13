require 'axlsx'

namespace 'ggi' do

  namespace 'downloads' do

    desc 'Create XSLX download file '\
         '`rake "ggi:downloads:create[2.0, 2014.05.12, public/ggi.xlsx]"`.'
    task :create, :version, :updated, :filepath do |t, args|
      Ggi::ClassificationImporter.cache_data
      args.with_defaults(
        filepath: 'public/ggi.xlsx',
        version: 'unknown',
        updated: 'unknown')
      begin
        families = Ggi::Classification.classification.taxa.select do |id, taxon|
          taxon.rank.downcase == 'family'
        end
        prefix = ['subkingdom', 'infrakingdom', 'superphylum', 'subphylum',
          'infraphylum', 'parvphylum', 'superclass', 'subclass', 'infraclass',
          'superorder' ]
        measurement_uris = {
          bhl: 'http://eol.org/schema/terms/NumberReferencesInBHL',
          bold: 'http://eol.org/schema/terms/NumberPublicRecordsInBOLD',
          eol: 'http://eol.org/schema/terms/NumberRichSpeciesPagesInEOL',
          gbif: 'http://eol.org/schema/terms/NumberRecordsInGBIF',
          genbank: 'http://eol.org/schema/terms/NumberOfSequencesInGenBank',
          ggbn: 'http://eol.org/schema/terms/NumberSpecimensInGGBN'
        }
        measurement_labels = {
          'http://eol.org/schema/terms/NumberReferencesInBHL' => 'BHL',
          'http://eol.org/schema/terms/NumberPublicRecordsInBOLD' => 'BOLD',
          'http://eol.org/schema/terms/NumberRichSpeciesPagesInEOL' => 'EOL',
          'http://eol.org/schema/terms/NumberRecordsInGBIF' => 'GBIF',
          'http://eol.org/schema/terms/NumberOfSequencesInGenBank' => 'NCBI',
          'http://eol.org/schema/terms/NumberSpecimensInGGBN' => 'GGBN'
        }
        ::Axlsx::Package.new do |package|
          package.workbook.add_worksheet(name: 'FALO plus data') do |falo_sheet|
            falo_sheet.add_row [
              'Sort',
              'SupraKingdom',
              'Kingdom',
              'Sbk',
              'Ik',
              'Superphylum',
              'Phylum',
              'Subphylum',
              'Infraphylum',
              'ParviPhylum',
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
              'GenBank',
              'GGBN',
              'BHL_Percentile',
              'BOLD_Percentile',
              'EOL_Percentile',
              'GBIF_Percentile',
              'NCBI_Percentile',
              'GGBN_Percentile',
              'GGI score',
              'REFERENCE' ]
            families.each do |id, taxon|
              ancestors = {}
              taxon.ancestors.each do |t|
                ancestors[t.rank.downcase] =
                  prefix.include?(t.rank.downcase) ?
                    "#{t.rank} #{t.name}" : t.name
              end
              measurements = Hash[ measurement_uris.map{|k,v| [v, Hash.new(0)]} ]
              taxon.measurements.each do |m|
                unless m[:score].nil?
                  m[:formattedScore] = (m[:score] * 100).ceil.to_s
                end
                measurements[m[:measurementType]] = m
              end
              falo_sheet.add_row [
                nil, # TODO: sort column
                ancestors['superkingdom'],
                ancestors['kingdom'],
                ancestors['subkingdom'],
                ancestors['infrakingdom'],
                ancestors['superphylum'],
                ancestors['phylum'],
                ancestors['subphylum'],
                ancestors['infraphylum'],
                ancestors['parvphylum'],
                ancestors['superclass'],
                ancestors['class'],
                ancestors['subclass'],
                ancestors['infraclass'],
                ancestors['superorder'],
                ancestors['order'],
                taxon.name,
                measurements[measurement_uris[:bhl]][:measurementValue],
                measurements[measurement_uris[:bold]][:measurementValue],
                measurements[measurement_uris[:eol]][:measurementValue],
                measurements[measurement_uris[:gbif]][:measurementValue],
                measurements[measurement_uris[:genbank]][:measurementValue],
                measurements[measurement_uris[:ggbn]][:measurementValue],
                measurements[measurement_uris[:bhl]][:formattedScore],
                measurements[measurement_uris[:bold]][:formattedScore],
                measurements[measurement_uris[:eol]][:formattedScore],
                measurements[measurement_uris[:gbif]][:formattedScore],
                measurements[measurement_uris[:genbank]][:formattedScore],
                measurements[measurement_uris[:ggbn]][:formattedScore],
                (taxon.score * 100).ceil.to_s,
                taxon.source
              ]
            end
          end
          package.workbook.add_worksheet(name: 'Data for pivots') do |pivot_sheet|
            pivot_sheet.add_row ['Family', 'Value', 'Source']
            families.each do |id, taxon|
              pivot_sheet.add_row [
                taxon.name,
                1,
                'FALO' ]
              taxon.measurements.each do |measurement|
                unless measurement[:score].nil?
                  pivot_sheet.add_row [
                    taxon.name,
                    measurement[:measurementValue],
                    measurement_labels[measurement[:measurementType]] ]
                end
              end
            end
          end
          package.workbook.add_worksheet(name: 'Key') do |key_sheet|
            key_sheet.add_row [
              "BASED on FALO version #{args[:version]}, "\
              "queries up to date as of #{args[:updated]}"
            ]
            key_sheet.add_row ['Term', 'URI', 'Definition']
            Ggi::ClassificationImporter::MEASUREMENT_URIS_TO_LABELS.each do |uri, term|
              key_sheet.add_row [
                term,
                uri,
                nil ]
            end
          end
          package.serialize(args[:filepath])
        end

      rescue
        raise
      end
    end

  end

end
