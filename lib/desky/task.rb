module Desky
  # the Task thingy
  class Task
    def initialize(options, output_handler)
      @output_handler = output_handler
      @cmd, @args = options['command'], options['args']
      @wait, @verbose = options['wait'], options['verbose']
    end

    def command
      case @args
      when Array
        "#{@cmd} #{@args.join(" ")}"
      when String
        "#{@cmd} #{@args}"
      else
        @cmd
      end
    end

    def wait?
      @wait
    end

    def run
      Thread.new {
        begin
          @output_handler.output('running', "#{@cmd}\n")
          @result = `#{command}`
          print_result if @verbose
        rescue => error
          @output_handler.error @cmd, error.message
        end
      }
    end

  private
    def print_result
      format_output @result
      status = $?.success? ? 'SUCCESS' : 'FAILURE'
      @output_handler.result 'finished', "#{@cmd}: #{status}"
    end

    def format_output(output)
      output.split("\n").each do | line |
        @output_handler.output @cmd, line
      end
    end
  end
end