module Desky
  # the Task thingy
  class Task
    attr_accessor :cmd, :wait, :capture, :args

    def initialize(options)
      @cmd, @args = options['command'], options['args']
      @wait, @capture = options['wait'], options['capture']
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

    def show
      ["  #{@cmd}", @args]
    end

    def wait?
      @wait
    end

    def call(output_handler = default_output_handler, error_handler = default_error_handler)
      Thread.new {
        begin
          output_handler.call('running', "#{@cmd}\n")
          result = `#{command}`
          format_output result, output_handler if @capture
          status = $?.success? ? 'SUCCESS' : 'FAILURE'
          output_handler.call('finished', "#{@cmd}: #{status}")
        rescue => error
          error_handler.call(@cmd, error.message)
        end
      }
    end

  private

    def format_output(output, output_handler)
      output.split("\n").each do | line |
        output_handler.call(@cmd, line)
      end
    end

    def default_output_handler
      lambda { |cmd, result|
        puts "#{cmd}: #{result}"
      }
    end

    def default_error_handler
      lambda {|cmd, msg|
        puts "Error: #{cmd} #{msg}"
      }
    end
  end
end