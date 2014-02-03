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

      FileList.new("#{project_dir}/layouts/epub/**/*.erb").each do |layout|
        filename = layout.pathmap("%{^#{layout_dir},#{build_dir}}X")
        path = filename.pathmap('%d')

        FileUtils.mkpath(path) unless File.exists? path

        template = ERB.new(File.read(layout))
        File.open(filename, 'w+') do |handle|
          handle.write template.result(binding)
        end
      end
    end
  end
end
