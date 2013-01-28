module Desky
  require 'json/pure'

  class ProjectFilePersistor
    def initialize(name)
      @file = "/home/jon/Projects/gems/desky/projects/#{name}.json"
    end

    def load_tasks
      load_project
    end
  private
    def load_project
      json = File.read(@file)
      JSON.parse(json)
    rescue Errno::ENOENT
      raise ExitError, "Error: File '#{@file}' doesnt exist, please create."
    rescue JSON::ParserError => error
      raise ExitError, "JSON Error: #{error.message}"
    end
  end
end