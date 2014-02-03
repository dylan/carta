module Carta::CLI
  # This is our book generator
  class Book
    attr_reader :meta, :thor, :book_name

    def initialize(thor, meta)
      @thor = thor
      @meta = meta
      @book_name = (meta[:title].is_a? String) ? meta[:title] : meta[:title].join(' ')
    end

    def run
      require 'carta/cli/chapter'
      thor.directory 'ebook', book_name
      thor.inside book_name do
        Carta::CLI::Chapter.new(thor, 0, "My First #{book_name} Chapter").run
      end
    end
  end
end
