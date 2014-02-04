require 'yaml'
require 'thor/rake_compat'
require 'pry'
require 'mime-types'
require 'carta/cli/html_renderer'

module Carta
  class CLI::Compile
    attr_reader :thor,
                :book,
                :project_dir

    def initialize(thor)
      if Dir.exists?('manuscript')
        @project_dir = Dir.pwd
        @thor = thor
        @book = YAML.load_file("#{project_dir}/manuscript/book.yaml")
      else
        thor.error 'No book found to compile!'
      end
    end

    def run
      generate_html if Dir.exists?('manuscript')
    end

    # Generates our HTML from markdown files and creates an outline
    def generate_html
      html_renderer = Carta::CLI::HTMLRenderer.new(project_dir)
      book['html']      = html_renderer.manuscript_html
      book['outline']   = html_renderer.outline
      book['toc_html']  = html_renderer.toc_html

      generate_manifest
    end

    # Runs through our ERBs
    def render_layouts
      layout_dir = "#{project_dir}/layouts"
      build_dir  = "#{project_dir}/build"

      FileList.new("#{layout_dir}/epub/**/*.erb").each do |layout|
        filename = layout.pathmap("%{^#{layout_dir},#{build_dir}}X")
        path = filename.pathmap('%d')

        FileUtils.mkpath(path) unless File.exists? path

        template = ERB.new(File.read(layout),nil,'-')
        File.open(filename, 'w+') do |handle|
          handle.write template.result(binding)
        end
      end

    end

    def generate_manifest
      layout_dir = "#{project_dir}/layouts"

      files   = FileList.new("#{layout_dir}/epub/EPUB/*.erb")
                        .pathmap("%{^#{layout_dir}/epub/EPUB,}X")
                        .add('manuscript/figures/**/*.{tif,jpeg,jpg,png,svg,mp4,gif}',
                             'assets/fonts/**/*.{otf,ttf}',
                             'assets/css/**/*.css',
                             'assets/*.{tif,jpeg,jpg,png,svg,gif}',
                             'manuscript/cover.{jpg,png,svg,gif')
                        .pathmap('%{^assets,}p')
                        .pathmap('%{^manuscript/figures,figures}p')
                        .exclude('**/*.opf*')
                        .exclude('**/*.ncx*')

      book['manifest'] = []
      files.each do |file|
        # filename = file.pathmap("%{^#{layout_dir},build}p")
        media_type = MIME::Types.type_for(file).first.content_type
        if file.include? 'cover'
          book['cover'] = { filename: file, media_type: media_type }
        else
          book['manifest'] << { filename: file, media_type: media_type }
        end
      end
      render_layouts
    end
  end
end
