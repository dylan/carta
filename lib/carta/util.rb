module Carta::Util
  # Takes a string and prepares it for use as a filename
  # or URL.
  # "Hello World!" -> "hello-world"
  def self.slug(string)
    string.downcase
       .strip
       .gsub(' ', '-')
       .gsub(/[^0-9A-z.\-]/, '')
  end

  # Pads at number so that it's 2 digits wide with leading
  # zeros if needed.
  # 1 -> 01
  def self.pad(number)
    sprintf('%02d', number.to_s)
  end
end
