module Desky
 # The little project file. Reads from json
  class ProjectRunner
    def initialize(tasks, output_handler)
      @output = output_handler
      @tasks = tasks.map { |name, options| Task.new(options, output_handler) }
    end

    def run_tasks
      @threads = @tasks.map { |task|
        {
          thread: task.run,
          wait: task.wait?
        }
      }
      @threads.each { | thread |
        thread[:thread].join if thread[:wait]
      }
    end
  end
end