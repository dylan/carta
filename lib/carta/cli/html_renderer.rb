require 'carta/cli/outline_renderer'

module Carta
  class CLI::HTMLRenderer
    attr_accessor :markdown,
                  :manuscript_html,
                  :epub_toc_html,
                  :html_toc_html,
                  :outline

    def initialize(path)
      @markdown = ''
      @epub_toc_html = ''
      @html_toc_html = ''
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
      @epub_toc_html = render_outline
      @html_toc_html = render_outline('toc',true)


    end

    def render_outline(html_class = 'toc', for_html = false)
      final_class = "class='#{html_class}'"
      html = ''
      outline.each_with_index do |data, i|
        level, text, link, *children = data
        html << "<ol #{final_class}>" if i == 0
        if for_html
          html << "\n  <li><a href='##{link}'>#{text}</a>"
        else
          html << "\n  <li><a href='content.xhtml##{link}'>#{text}</a>"
        end

        if children.empty?
          html << '</li>'
        else
          children.each_with_index do |child, j|
            level, text, link = child
            html << "\n    <ol>" if j == 0
            if for_html
              html << "\n      <li><a href='##{link}'>#{text}</a></li>"
            else
              html << "\n      <li><a href='content.xhtml##{link}'>#{text}</a></li>"
            end
            html << "\n    </ol>\n  </li>" if j == children.length - 1
          end
        end
        html << "\n</ol>" if i == outline.length - 1
      end
      return html
    end
  end
end
