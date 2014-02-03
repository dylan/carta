require 'pry'
require 'carta/cli/book'
require 'carta/cli/chapter'

module Carta::CLI
  # The class from which it all begins
  class Base < Thor
    include Thor::Actions
    attr_reader :meta

    def self.source_root
      File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
    end

    # desc 'book', 'Create a book with the given name'
    desc 'book', 'Generate a book with an optional [NAME].'
    def book(*name)
      name = name.empty? ? '' : name.join(' ')

      say("\nThis utility will walk you through creating an ebook project.")
      say("\nPress ^C at any time to quit.\n")

      require 'carta/cli/book'
      prompt_name   = name.empty? ? '' : "(#{name})"
      ask_title = ask("Title:#{prompt_name}")
      @meta = {
        name:     ask_title.empty? ? name : ask_title,
        subtitle: ask('Subtitle: (blank)'),
        language: ask('Language: (en)'),
        authors:  ask('Authors: (blank)'),
        uid:      ask('uuid: (blank)')
      }
      Carta::CLI::Book.new(self, meta).run
    end

    desc 'chapter [number] [name]',
         'Create a chapter with the given name or number.'
    def chapter(number, *name)
      unless /\p{N}/.match number
        number, name = '00', [number].concat(name)
      end
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
