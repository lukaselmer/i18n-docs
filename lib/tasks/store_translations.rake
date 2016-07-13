
namespace :i18n do

  desc "Find and list translation keys that do not exist in all locales"
  task :missing_keys => :environment do
    finder = I18nDocs::MissingKeysFinder.new(I18n.backend)
    finder.find_missing_keys
  end

  desc "Download translations from Google Spreadsheet and save them to YAML files."
  task :import_translations => :environment do

    config_file = I18nDocs::CsvToYaml.root_path.join('config', 'translations.yml')
    raise "No config file 'config/translations.yml' found." if !File.exist?(config_file)

    tmp_dir = I18nDocs::CsvToYaml.root_path.join('tmp')
    Dir.mkdir(tmp_dir) unless Dir.exist?(tmp_dir)

    translations = I18nDocs::Translations.new(config_file, tmp_dir)
    translations.download_files
    translations.store_translations
    translations.clean_up

  end

  desc "Export all language files to CSV files (only files contained in en folder are considered)"
  task :export_translations => :environment do
    source_dir  = I18nDocs::CsvToYaml.root_path.join('config', 'locales')
    output_dir  = I18nDocs::CsvToYaml.root_path.join('tmp')
    locales     = I18n.available_locales

    input_files = Dir[File.join(source_dir, ENV['locale'] || 'en', '*.yml')]

    puts ""
    puts "  Detected locales: #{locales}"
    puts "  Detected files:"
    input_files.each {|f| puts "    * #{File.basename(f)}" }

    puts ""
    puts "  Start exporting files:"

    input_files.each do |file|
      file = File.basename(file)
      exporter = I18nDocs::TranslationFileExport.new(source_dir, file, output_dir, locales)
      exporter.export
    end

    puts ""
    puts "  CSV files can be removed safely after uploading them manually to Google Spreadsheet."
    puts ""
  end

end
