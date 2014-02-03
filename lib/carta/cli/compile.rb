require 'yaml'
require 'thor/rake_compat'
require 'carta/cli/html_renderer'

module Carta
  class CLI::Compile
    attr_reader :thor, :book, :project_dir

    def initialize(thor)
      @project_dir = Dir.pwd
      @thor = thor
      @book = YAML.load_file("#{project_dir}/manuscript/book.yaml")
    end

    def run
      if Dir.exists?('manuscript')
        html_renderer = Carta::CLI::HTMLRenderer.new(project_dir)

        book['html']      = html_renderer.manuscript_html
        book['outline']   = html_renderer.outline
        book['toc_html']  = html_renderer.toc_html

        FileList.new("#{project_dir}/layouts/epub/**/*.erb").each do |layout_filepath|
          filename = layout_filepath.pathmap("%{^#{project_dir}/layouts,#{project_dir}/build}X")
          path = filename.pathmap('%d')

          FileUtils.mkpath(path) unless File.exists? path

          template = ERB.new(File.read(layout_filepath))
          File.open(filename, 'w+') do |handle|
            handle.write template.result(binding)
          end
        end
      else
        thor.error 'No book found to compile!'
      end
    end
  end
end
