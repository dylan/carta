require 'carta/cli/outline_renderer'
require 'pry'

module Carta
  class CLI::HTMLRenderer
    attr_accessor :markdown,
                  :manuscript_html,
                  :toc_html,
                  :outline

    def initialize(path)
      @markdown = ''
      @toc_html = ''
      @manuscript_html = ''
      @outline = nil
      load_markdown(path)
    end

    def load_markdown(path)
      FileList.new("#{path}/manuscript/**/*.md").sort.each do |md_file|
        IO.readlines(md_file).each { |line| markdown << line }
        markdown << "\n\n"
      end
      render_manuscript
    end

    def render_manuscript
      renderer = OutlineRenderer.new
      r = Redcarpet::Markdown.new(renderer)
      manuscript_html << r.render(markdown)
      @outline = renderer.outline
      render_outline
    end

    def render_outline(html_class='toc')
      final_class = "class='#{html_class}'"
      outline.each_with_index do |data, i|
        level, text, link, *children = data
        toc_html << "<ol #{final_class}>" if i == 0
        toc_html << "\n  <li><a href='##{link}'>#{text}</a>"

        if children.empty?
          toc_html << '</li>'
        else
          children.each_with_index do |child, j|
            level, text, link = child
            toc_html << "\n    <ol>" if j == 0
            toc_html << "\n      <li><a href='##{link}'>#{text}</a></li>"
            toc_html << "\n    </ol>\n  </li>" if j == children.length - 1
          end
        end
        toc_html << "\n</ol>" if i == outline.length - 1
      end
    end
  end
end
