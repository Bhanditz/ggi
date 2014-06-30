require 'axlsx'

class Ggi
  class AllFamiliesDownload

    def self.create(args = {})
      # Set defaults:
      args = {
        filepath: 'public/ggi_family_data.xlsx',
        # NOTE - The version CANNOT come from the source file, we need to ask what version FALO wants this to be known as, and when we last asked CP about
        # it, she said that 2.5 is likely to be the last version we harvest for a while, so we're hard-coding that value to reduce the risk of forgetting to
        # ask what it should be.
        version: '2.5',
        updated: 'unknown'
      }.merge(args)

      families = Ggi::Classification.classification.taxa.select do |id, taxon|
        taxon.rank.downcase == 'family'
      end
      # TODO - it's a bit clunky that we have to hard-code these in multiple places to make the code more readable (and here we needed a different label
      # anyway). It's also in the ClassificationImporter lib. That hash has URIs and labels (like the second hash here) and different labels. ...There's
      # another set for the UI (saying this is label is for this measurement in this context). We should generalize this later.
      measurement_labels = {
        'http://eol.org/schema/terms/NumberReferencesInBHL' => 'BHL',
        'http://eol.org/schema/terms/NumberPublicRecordsInBOLD' => 'BOLD',
        'http://eol.org/schema/terms/NumberRichSpeciesPagesInEOL' => 'EOL',
        'http://eol.org/schema/terms/NumberRecordsInGBIF' => 'GBIF',
        'http://eol.org/schema/terms/NumberOfSequencesInGenBank' => 'NCBI',
        'http://eol.org/schema/terms/NumberSpecimensInGGBN' => 'GGBN'
      }
      package = Axlsx::Package.new

      package.workbook.add_worksheet(name: 'FALO plus data') do |falo_sheet|
        falo_sheet.add_row [
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
          'Reference' ]
        families.each do |id, taxon|
          ancestors = Hash[ taxon.ancestors.map{|t| [t.rank.downcase, t.name]} ]
          measurements = Hash[ Ggi::Uri.uris.map { |uri| [uri, Hash.new(0)]} ]
          taxon.measurements.each do |m|
            unless m[:score].nil?
              m[:formattedScore] = (m[:score] * 100).ceil.to_s # TODO - this is in a helper, should be extracted
            end
            measurements[m[:measurementType]] = m
          end
          falo_sheet.add_row [
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
            # TODO - clearly it would be nice to have a measurement class.
            measurements[Ggi::Uri.bhl.uri][:measurementValue],
            measurements[Ggi::Uri.bold.uri][:measurementValue],
            measurements[Ggi::Uri.eol.uri][:measurementValue],
            measurements[Ggi::Uri.gbif.uri][:measurementValue],
            measurements[Ggi::Uri.ncbi.uri][:measurementValue],
            measurements[Ggi::Uri.ggbn.uri][:measurementValue],
            measurements[Ggi::Uri.bhl.uri][:formattedScore],
            measurements[Ggi::Uri.bold.uri][:formattedScore],
            measurements[Ggi::Uri.eol.uri][:formattedScore],
            measurements[Ggi::Uri.gbif.uri][:formattedScore],
            measurements[Ggi::Uri.ncbi.uri][:formattedScore],
            measurements[Ggi::Uri.ggbn.uri][:formattedScore],
            (taxon.score * 100).ceil.to_s, # TODO - this is in a helper, should be extracted
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
        defs = Ggi::DefinitionImporter.import
        Ggi::Uri.all.each do |uri|
          definition = uri.definition
          unless definition && ! definition.blank?
            new_def = defs.find { |d| d["uri"] == uri.uri }
            definition = new_def["definition"] if new_def
          end
          key_sheet.add_row [
            uri.long_name,
            uri.uri,
            definition
          ]
        end
      end
      package.serialize(args[:filepath])

    end

  end
end
