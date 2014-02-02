# Custom Renderer for Redcarpet
class OutlineRenderer < Redcarpet::Render::HTML
  attr_accessor :outline

  def initialize
    @outline = []
    super
  end

  # Required by Redcarpet to change behavior of the the renderer
  def header(text, header_level)
    prior_level = 1
    value = [header_level, "#{text}", "#{text_slug}"]
    if header_level <= 2
      (prior_level < header_level) ? outline.last << value : outline << value
      render_line(text, header_level, true)
    elsif header_level > 2
      render_line(text, header_level)
    end
  end

  def render_line(text, level, with_id = false)
    text_slug = text.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    if with_id
      "<h#{header_level} id='#{text_slug}'>#{text}</h#{header_level}>"
    else
      "\n<h#{header_level}>#{text}</h#{header_level}>"
    end
  end
end
