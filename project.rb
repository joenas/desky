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

  def run
    Thread.new { `#{command}` }
    #{}`#{command}`
      #return system
    #end
    #rescue Errno::ENOENT
     # puts "hej hej"
  end
end