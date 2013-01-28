module Desky
 # The little project file. Reads from json
  class Project
    def initialize(tasks)
      @tasks = tasks
    end

    def tasks
      @tasks.map { |name, options| Task.new(options) }
    end
  end
end