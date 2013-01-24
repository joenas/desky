# The litle project file. Reads from json
module Desky
  class Project
    # prints msg and exits!
    class ExitError < StandardError
      def initialize(msg)
        puts msg
        exit
      end
    end

    ROOT = "#{File.dirname(__FILE__)}/projects"

    def initialize(name)
      @file = "#{ROOT}/#{name}.json"
      @tasks = load_tasks
    end

    def tasks
      setup_tasks
    end

    def show_tasks(presenter)
      presenter.call tasks.map { |task| task.show }
    end

  private
    def load_tasks
      json = File.read(@file)
      JSON.parse(json)
    rescue Errno::ENOENT
      raise ExitError, "Error: File '#{@file}' doesnt exist, please create."
    rescue JSON::ParserError => error
      raise ExitError, "JSON Error: #{error.message}"
    end

    def setup_tasks
      @tasks.map { |name, options| Task.new(options) }
    end
  end
end