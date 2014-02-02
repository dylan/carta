module Carta::CLI
  # A class for chapter generation
  class Chapter
    attr_reader :thor,
                :chapter_number,
                :pretty_number,
                :chapter_name,
                :sub_chapter_name,
                :level

    def initialize(thor, chapter_number, *chapter_name)
      @thor = thor
      @chapters = chapter_number.to_s.split('.')
      @chapters[0] = Carta::Util.pad(@chapters[0])

      if @chapters.length > 1
        @chapters[1] = Carta::Util.pad(@chapters[1])
      else
        @chapters[1] = '01'
      end

      @chapter_name = chapter_name.join(' ')
      @dasherized_name = Carta::Util.slug(@chapter_name)
      @handy_chapter_name    = "#{@chapters[0]}-#{@dasherized_name}"
      @handy_subchapter_name = "#{@chapters[1]}-#{@dasherized_name}"
    end

    def run
      if Dir.exists?('manuscript')
        target_dir = Dir.glob("manuscript/#{@chapters[0]}*")
        if target_dir.empty?
          path = "manuscript/#{@handy_chapter_name}/#{@handy_subchapter_name}.md"
        else
          path = "#{target_dir[0]}/#{@handy_subchapter_name}.md"
        end
        thor.create_file path do
          level = @chapters[2].nil? ? '##' : '#' * (@chapters[2].to_i + 1)
          contents = "#{level} #{chapter_name}"
          contents << "\nLorem ipsum dolor sit amet, consectetur adipisicing elit."
        end
      else
        thor.say('Please create a book first.',:red)
        thor.help
      end
    end
  end
end
