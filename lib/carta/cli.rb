require 'uuid'
require 'carta/cli/book'
require 'carta/cli/chapter'

module Carta::CLI
  # The class from which it all begins
  class Base < Thor
    include Thor::Actions
    attr_reader :meta,
                :BUILD_PATH,
                :LAYOUT_PATH,
                :MANU_PATH,
                :ASSET_PATH

    # def initialize(*args)
    #   @BUILD_PATH  = 'build'
    #   @LAYOUT_PATH = 'layouts'
    #   @MANU_PATH   = 'manuscript'
    #   @ASSET_PATH  = 'assets'
    # end

    def self.source_root
      File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
    end

    # desc 'book', 'Create a book with the given name'
    desc 'book', 'Generate a book with an optional [NAME].'
    def book(*name)
      name = name.empty? ? '' : name.join(' ')

      say("\nThis utility will walk you through creating an ebook project.")
      say("\nPress ^C at any time to quit.")

      require 'carta/cli/book'

      default_name   = name.empty? ? '' : "(#{name})"

      ask_title    = ask "Title:#{default_name}"
      ask_license  = ask 'License: (MIT)'
      ask_lang     = ask 'Language: (en-US)'
      ask_author   = ask 'Author(s): (Anonymous)'
      ask_uuid     = ask 'uuid:'

      @meta = {
        title:    ask_title.empty? ? name : ask_title,
        subtitle: ask('Subtitle: (blank)'),
        authors:  ask_author.empty? ? 'Anonymous' : ask_author,
        language: ask_lang.empty? ? 'en-US' : ask_lang,
        license:  ask_license.empty? ? 'MIT' : ask_license,
        uid:      ask_uuid.empty? ? UUID.new.generate : ask_uuid
      }
      Carta::CLI::Book.new(self, meta).run
    end

    desc 'chapter [number] [name]',
         'Create a chapter with the given name or number.'
    def chapter(number, *name)
      number, name = '00', [number].concat(name) unless /\d+/.match number
      require 'carta/cli/chapter'
      Carta::CLI::Chapter.new(self, number, name).run
    end

    desc 'compile', 'Create the final ebook'
    def compile
      require 'carta/cli/compile'
      Carta::CLI::Compile.new(self).run
    end
  end
end
