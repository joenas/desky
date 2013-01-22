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

  def run_tasks
    threads = setup_tasks.map {|task| task.run }
    threads.each {|tred| tred.join }
  end

  def tasks
    setup_tasks
  end

private
  def load_tasks
    #puts "Loading #{@file}"
    json = File.read(@file)
    JSON.parse(json)
  rescue Errno::ENOENT
    raise ExitError, "Error: File '#{@file}' doesnt exist, please create."
  rescue JSON::ParserError => error
    raise ExitError, "JSON Error: #{error.message.split("\n").first}"
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

  def run_in_thread(error_handler, result_handler)
    Thread.new(cmd) do |cmd|
      result = `#{command}` rescue error_handler.call(cmd)
      result_handler.call(cmd, result) if capture
      yield self if block_given?
    end
  end

  # def run
  #   lambda {
  #     ret = `#{command}` rescue say_status(:error, "#{cmd}", :red)
  #     print_result ret, cmd if capture
  #     say_status :stopping, "#{cmd}, status #{$?.exitstatus}", :blue
  #   }
  # end
end