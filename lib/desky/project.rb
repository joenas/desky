module Desky
 # The little project file. Reads from json
  class Project

    def initialize(tasks)
      #@persistor = persistor#.new(name)
      @tasks = tasks
    end

    def tasks
      setup_tasks
    end

    def show_tasks(presenter)
      presenter.call tasks.map { |task| task.show }
    end

  private

    def setup_tasks
      @tasks.map { |name, options| Task.new(options) }
    end
  end
end