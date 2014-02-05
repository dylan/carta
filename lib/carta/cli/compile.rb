require 'yaml'
require 'thor/rake_compat'
require 'mime-types'
require 'rubygems'
require 'zip'
require 'carta/cli/html_renderer'
require 'pry'


module Carta
  class CLI::Compile
    attr_reader :thor,
                :book,
                :PROJECT_DIR,
                :LAYOUT_DIR,
                :MANUSCRIPT_DIR,
                :FIGURE_DIR,
                :ASSET_DIR,
                :BUILD_DIR,
                :ASSET_FILES

    def initialize(thor)
      if Dir.exists?('manuscript')
        @thor = thor
        @PROJECT_DIR    = Dir.pwd
        @BUILD_DIR      = "build"
        @LAYOUT_DIR     = "#{@PROJECT_DIR}/layouts"
        @MANUSCRIPT_DIR = "#{@PROJECT_DIR}/manuscript"
        @FIGURE_DIR     = "#{@MANUSCRIPT_DIR}/figures"
        @ASSET_DIR      = "#{@PROJECT_DIR}/assets"
        @ASSET_FILES    = 'css,otf,woff,jpeg,jpg,png,svg,gif'
        @book = YAML.load_file("#{@MANUSCRIPT_DIR}/book.yaml")
      else
        thor.error 'No book found to compile!'
      end
    end

    def run
      generate_html if Dir.exists?('manuscript')
    end

    # Generates our HTML from markdown files and creates an outline
    def generate_html
      html_renderer = Carta::CLI::HTMLRenderer.new(@PROJECT_DIR)
      # puts @MANUSCRIPT_DIR
      book['html']      = html_renderer.manuscript_html
      book['outline']   = html_renderer.outline
      book['toc_html']  = html_renderer.toc_html

      generate_manifest
    end

    # Runs through our ERBs
    def render_layouts
      FileList.new("#{@LAYOUT_DIR}/epub/**/*.erb").each do |layout|
        filename = layout.pathmap("%{^#{@LAYOUT_DIR},#{@BUILD_DIR}}X")
        path = filename.pathmap('%d')

        FileUtils.mkpath(path) unless File.exists? path

        template = ERB.new(File.read(layout), nil, '-')
        File.open(filename, 'w+') do |handle|
          handle.write template.result(binding)
        end
      end
    end

    def generate_manifest
      files   = FileList.new("#{@LAYOUT_DIR}/epub/EPUB/*.erb")
                        .pathmap("%{^#{@LAYOUT_DIR}/epub/EPUB/,}X")
                        .exclude('**/*.opf*')
                        .exclude('content.xhtml', 'nav.xhtml')
                        .exclude('**/*.ncx*')
                        .add("#{@FIGURE_DIR}/**/*.{#{@ASSET_FILES}}",
                             "#{@ASSET_DIR}/**/*.{#{@ASSET_FILES}}",
                             "#{@MANUSCRIPT_DIR}/cover.{#{@ASSET_FILES}}")
                       .pathmap("%{^#{@ASSET_DIR}/,}p")
                       .pathmap("%{^#{@FIGURE_DIR},figures}p")

      book['manifest'] = []

      files.each do |file|
        media_type = MIME::Types.type_for(file).first.content_type
        if file.include? 'cover'
          book['cover'] = { filename: file, media_type: media_type }
        else
          book['manifest'] << { filename: file, media_type: media_type }
        end
      end
      copy_files
      render_layouts
      generate_epub
    end

    def copy_files
      assets = FileList.new("#{@FIGURE_DIR}/**/*.{#{@ASSET_FILES}}",
                            "#{@ASSET_DIR}/**/*.{#{@ASSET_FILES}}",
                            "#{@MANUSCRIPT_DIR}/cover.{#{@ASSET_FILES}}")

      dest = assets.pathmap("%{^#{@ASSET_DIR},#{@BUILD_DIR}/epub/EPUB}p")
                   .pathmap("%{^#{@FIGURE_DIR},#{@BUILD_DIR}/epub/EPUB/figures}p")

      assets.each_with_index do |file, index|
        thor.copy_file file, dest[index]
      end
    end

    def generate_epub
      files = FileList.new("#{@BUILD_DIR}/epub/**/*.*")
      zip_path = files.pathmap("%{^#{@BUILD_DIR}/epub/,}p")
      zip = Zip::OutputStream.new("#{@BUILD_DIR}/#{book['title']}.epub")
      zip.put_next_entry('mimetype', nil, nil, Zip::Entry::STORED, Zlib::NO_COMPRESSION)
      zip.write "application/epub+zip"
      zip_list = {}
      zip_path.each_with_index do |value, i|
        zip_list[value] = files[i]
      end
      zip_list.keys.each do |key|
        zip.put_next_entry key, nil, nil, Zip::Entry::DEFLATED, Zlib::BEST_COMPRESSION
        zip.write IO.read(zip_list[key])
      end
      zip.close

    end
  end
end
