# The litle project file. Reads from json
module Desky
  class Project

    def initialize(persistor)
      @persistor = persistor#.new(name)
      puts @persistor.public_methods(false).inspect
      @tasks = @persistor.load_tasks
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