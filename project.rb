# The litle project file. Reads from json
class Project

  # prints msg and exits!
  class ExitError < StandardError
    def initialize(msg)
      puts msg
      exit
    end
  end

  ROOT = "#{File.dirname(__FILE__)}"

  def initialize(name)
    @file = "#{ROOT}/projects/#{name}.json"
    @tasks = load_tasks
  end

  def run_tasks
    threads = setup_tasks.map {|task| task.run }
    threads.each {|tred| tred.join }
  end

private
  def load_tasks
    puts "Loading #{@file}"
    json = File.read(@file)
    JSON.parse(json)
  rescue Errno::ENOENT
    raise ExitError, "Error: File 'projects/#{@file}' doesnt exist, please create."
  rescue JSON::ParserError => error
    raise ExitError, "JSON Error: #{error.message.split("\n").first}"
  end

  def setup_tasks
    @tasks.map { |name, options| Task.new(options) }
  end
end

class Task
  def initialize(options)
    @cmd, @args = options['command'], options['args']
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
    Thread.new { `#{command}`}
  end
end