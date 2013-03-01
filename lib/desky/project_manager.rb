module Desky
  require 'desky/configuration'
  require 'desky/output'
  require 'desky/project_runner'
  require 'desky/task'

  # not an irresponsible module
  class ProjectManager < Thor
    include Thor::Actions

    PROJECT_TEMPLATE = { 'tasks' => [ { 'command' => 'ping', 'args' => "-c 2 google.com", 'options' => 'verbose wait' } ] }

    def initialize
      check_project_dir
      @config = config
      @projects = Dir.glob("#{config[:projects_dir]}/*.#{config[:format]}").map { |file| file[/\/*(\w*)\.#{config[:format]}/, 1] }
      super
    end

    no_tasks do

      def config
        @config ||= Configuration.new
      end

      def run_project(name)
        output = Output.new output_handler, error_handler
        project_runner = ProjectRunner.new load_project(name), output
        project_runner.run_tasks
      rescue Interrupt
        say_status :exit, "User interrupt!\n", :red
      end

      def all
        @projects
      end

      def create(name)
        create_file project_file(name), Psych.dump(PROJECT_TEMPLATE)
      end

      def read(name)
        project_exist_or_exit name
        print_table load_project(name)
      end

      def update(name)
        project_exist_or_exit name
        system "#{config[:editor]} #{project_file name}"
      end

      def delete(name)
        remove_file project_file name
      end
    end

  private
    def error(msg)
      say_status :error, msg, :red
    end

    def error_and_exit(msg = 'Something went wrong!', status = :error, color = :red)
      say_status status, msg, color
      exit 1
    end

    def project_file(name)
      "#{config[:projects_dir]}/#{name}.yml"
    end

    def load_project(name)
      Psych.load_file( project_file(name) )
      rescue Errno::ENOENT
        error_and_exit("File '#{name}' does not exist, please create.")
      rescue Psych::SyntaxError => error
        error_and_exit(error.message, 'YAML error')
    end

    def check_project_dir
      return if (File.exists? config[:projects_dir])
      if yes? "Directory '~/.desky' does not exist, do you want to create it?"
        Dir.mkdir(config[:projects_dir], 0700)
      else
        error_and_exit("Desky needs a homedir to work!", :exiting)
      end
    end

    def self.source_root
      File.dirname(__FILE__)
    end

    def project_exist_or_exit(name)
      error_and_exit("Project '#{name}' does not exist.") unless project_exists? name
    end

    def project_exists?(name)
      @projects.include? name
    end

    def error_handler
      ->(cmd, msg) { say_status :error, "'#{cmd}': #{msg.chomp}\n", :red }
    end

    def output_handler
      ->(status, msg) { say_status status, "#{msg.chomp}\n", :blue }
    end
  end
end

