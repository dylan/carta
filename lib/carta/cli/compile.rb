require 'yaml'
require 'thor/rake_compat'
require 'carta/cli/html_renderer'

module Carta
  class CLI::Compile
    attr_reader :thor,
                :book,
                :project_dir

    def initialize(thor)
      @project_dir = Dir.pwd
      @thor = thor
      @book = YAML.load_file("#{project_dir}/manuscript/book.yaml")
    end

    def run
      if Dir.exists?('manuscript')
        generate_html
      else
        thor.error 'No book found to compile!'
      end
    end

    # Generates our HTML from markdown files and creates an outline
    def generate_html
      html_renderer = Carta::CLI::HTMLRenderer.new(project_dir)
      book['html']      = html_renderer.manuscript_html
      book['outline']   = html_renderer.outline
      book['toc_html']  = html_renderer.toc_html

      render_layouts
    end

    # Runs through our ERBs
    def render_layouts
      layout_dir = "#{project_dir}/layouts"
      build_dir  = "#{project_dir}/build"

      FileList.new("#{layout_dir}/epub/**/*.erb").each do |layout|
        filename = layout.pathmap("%{^#{layout_dir},#{build_dir}}X")
        path = filename.pathmap('%d')

        FileUtils.mkpath(path) unless File.exists? path

        template = ERB.new(File.read(layout))
        File.open(filename, 'w+') do |handle|
          handle.write template.result(binding)
        end
      end
      generate_manifest
    end

    def generate_manifest
      layout_dir = "#{project_dir}/layouts"

      files   = FileList.new("#{layout_dir}/epub/EPUB/*.erb")
                      .exclude('**/*.opf*')
      figures = FileList.new('manuscript/figures/**/*.{jpg,png,svg,mp4,gif}')
      fonts  = FileList.new('assets/fonts/**/*.{otf,ttf}')
      css  = FileList.new('assets/css/**/*.css')

      files.each do |file|
        filename = file.pathmap("%{^#{layout_dir},build}X")
        puts "file: #{filename}"
      end
      figures.each do |file|
        filename = file.pathmap("%{^manuscript/figures,build/epub/EPUB/figures}p")
        puts "figure: #{filename}"
      end
      fonts.each do |file|
        filename = file.pathmap("%{^assets/fonts,build/epub/EPUB/}p")
        puts "font: #{filename}"
      end
      css.each do |file|
        filename = file.pathmap("%{^assets/css,build/epub/EPUB/}p")
        puts "css: #{filename}"
      end
    end
  end
end
