require 'thor'
require 'pathname'

module Desky
  APP_ROOT = File.dirname(Pathname.new(__FILE__).realpath+"../")

  require 'desky/project_manager'


  class Desky < Thor
    include Thor::Actions
    #APP_ROOT = File.dirname(Pathname.new(__FILE__).realpath)

    map "-o" => :open
    map "-d" => :delete
    map "-e" => :edit
    map "-n" => :new
    map "-c" => :new
    map "-s" => :show

    desc 'open PROJECT (-o)', 'Opens your project!'
    def open(name)
      project_exist_or_exit name
      say_status :open, project_file(name)
      run_in_threads name
      rescue Interrupt
        say_status :exit, "User interrupt!\n", :red
    end

    desc 'list', "Lists all your projects."
    def list
      print_in_columns ProjectManager.new.all
    end

    desc 'show PROJECT (-s)', 'show a project and its tasks.'
    def show(name)
      #project_exist_or_exit name
      #project = Project.new(name)
      pm = ProjectManager.new(project_error_handler)
      project = pm.find(name)
#      project.tasks
#      say "Project:\n  #{name} - #{project_file(name)}\n\nTasks:"
      #project.show_tasks task_presenter
      say "\n"
    end

    desc 'new PROJECT (-n|-c)', 'Make a new project.'
    def new(name)
      pm = ProjectManager.new
      file = pm.project_file name
      create_file file
    end

    desc 'edit PROJECT (-e)', 'Edit your project. '
    def edit(name)
      pm = ProjectManager.new
      pm.edit name
    end

    desc 'delete PROJECT (-d)', 'Delete a project. '
    def delete(name)
      pm = ProjectManager.new
      file = pm.project_file name
      remove_file file
    end

  private
    def project_error_handler
      ->(msg) { say_status :error, msg, :red }
    end

    def task_presenter
      lambda { |array| print_table array }
    end

    def error_handler
      ->(cmd, msg) { say_status :error, "'#{cmd}': #{msg}", :red }
    end

    def output_handler
      ->(status, msg) { say_status status, msg, :blue }
    end

    def self.source_root
      File.dirname(__FILE__)
    end

    def run_in_threads(name)
      project = Project.new(name)
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

Desky::Desky.start
