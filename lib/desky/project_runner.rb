module Desky
 # The little project file. Reads from json
  class ProjectRunner
    def initialize(project, output_handler)
      @output = output_handler
      unless project && @tasks = project['tasks']
        @output.exit_error "ProjectRunner","You have no tasks defined, check syntax in project-file."
      end
      @tasks = @tasks.reject(&:nil?).map { |options|
        unless options['command']
          @output.error('Task has no command defined', options.inspect)
          next
        end
        Task.new(options, output_handler)
      }
    end

    def run_tasks
      @threads = @tasks.reject(&:nil?).map { |task|
        {
          thread: task.run,
          wait: task.wait?
        }
      }
      @threads.each do | thread |
        thread[:thread].join if thread[:wait]
      end
    end
  end
end