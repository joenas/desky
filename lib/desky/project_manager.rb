module Desky
  require 'desky/project'
  require 'desky/task'
  require 'json/pure'

  # not an irresponsible module
  class ProjectManager < Thor
    include Thor::Actions

    EDITOR = 'nano'
    DESKY_DIR = File.join(Dir.home, '.desky')

    def initialize
      check_project_dir
      @projects = Dir.glob("#{DESKY_DIR}/*.json").map { |file| file[/\/*(\w*)\.json/, 1] }
      super
    end

    no_tasks do
      def run_project(name)
        run_in_threads name
      rescue Interrupt
        say_status :exit, "User interrupt!\n", :red
      end

      def all
        @projects
        #Dir.glob("#{DESKY_DIR}/*.json").map { |file| file[/\/*(\w*)\.json/, 1] }
      end

      def create(name)
        create_file project_file(name),
                    { task: { command: 'ping', args: "-c 2 google.com", verbose: true, wait: true } }.to_json
      end

      def read(name)
        project_exist_or_exit name
        print_table load_project(name)
      end

      def update(name)
        project_exist_or_exit name
        system "#{EDITOR} #{project_file name}"
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
      "#{DESKY_DIR}/#{name}.json"
    end

    def load_project(name)
      json = File.read project_file(name)
      JSON.parse(json)
    rescue Errno::ENOENT
      error_and_exit("File '#{@file}' does not exist, please create.")
    rescue JSON::ParserError => error
      error_and_exit(error.message, 'JSON error')
    end

    def check_project_dir
      return if (File.exists? DESKY_DIR)
      if yes? "Directory '~/.desky' does not exist, do you want to create it?"
        Dir.mkdir(DESKY_DIR, 0700)
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
      #File.exists? project_file(name)
      @projects.include? name
    end

    def error_handler
      ->(cmd, msg) { say_status :error, "'#{cmd}': #{msg}", :red }
    end

    def output_handler
      ->(status, msg) { say_status status, msg, :blue }
    end

    # refactor to ProjectRunner (and substitute Project.rb)
    def run_in_threads(name)
      project = Project.new(load_project(name))
      @tasks = project.tasks.map { |task|
        {
          thread: task.call(output_handler, error_handler),
          wait: task.wait?
        }
      }
      @tasks.each { |task |
        task[:thread].join if task[:wait]
      }
    end
  end
end