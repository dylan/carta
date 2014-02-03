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
    text_slug = sluggize(text)
    value = [header_level, text, text_slug]
    if header_level <= 2
      (prior_level < header_level) ? outline.last << value : outline << value
      with_id = true
    elsif header_level > 2
      with_id = false
    end
    return render_line(header_level, text, text_slug, with_id)
  end

  def render_line(header_level, text, text_slug, with_id = false)
    id = "id='#{text_slug}'" if with_id
    "<h#{header_level} #{id}>#{text}</h#{header_level}>"
  end

  def sluggize(text)
    text.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
  end
end
