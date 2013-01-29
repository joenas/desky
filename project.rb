# The litle project file. Reads from json
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

  def startup
    yield @cmd
  end

  def call(error_handler = default_error_handler, result_handler = default_result_handler)
    Thread.new do
      begin
        result = `#{command}`
        result_handler.call(@cmd, result) if @capture
        yield self if block_given?
      rescue => error
        error_handler.call(@cmd, error.message)
      end
    end
  end

private
  def default_result_handler
    lambda { |cmd, result|
      puts "#{cmd}: #{result}"
    }
  end

  def default_error_handler
    lambda {|cmd, msg|
      puts "Error: #{cmd} msg"
    }
  end
end