require 'renderer'
require 'yaml'

module Carta
  class CLI::Compile
    attr_reader :thor

    def initialize(thor)
      @thor = thor
    end

    def run
      if Dir.exists?('manuscript')
      end
    end
  end
end
